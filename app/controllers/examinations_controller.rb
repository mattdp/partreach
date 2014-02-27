class ExaminationsController < ApplicationController
	before_filter :examiner_user

	def setup_examinations
		case params[:name] 
		when "reviews"
			@name = "review"
			@questionables = Review.quantity_for_examination(20)
		when "suppliers"
			@name = "supplier"
			@questionables = Supplier.quantity_by_tag_id(20,Tag.find_by_name("datadump").id)
		when "contact_information"
			@name = "contact_information"
			@questionables = Supplier.missing_contact_information(20)
		end
	end

	#faster if batch load suppliers
	def submit_examinations
		note = "Didn't submit to a model name. Error in code."
		if params[:model_examined] == "supplier"
			datadump_id = Tag.find_by_name("datadump").id
			if params[:suppliers]
				params[:suppliers].each do |s_id,v|
					supplier = Supplier.find(s_id)
					if v == "duplicate"
						supplier.destroy
					elsif v == "not_duplicate"
						supplier.update_attributes({name: params[:supplier_names][s_id]})
						supplier.create_or_update_address({ country: params[:supplier_countries][s_id], 
																								state: params[:supplier_states][s_id],
																								zip: params[:supplier_zips][s_id]
																							})
						supplier.remove_tags(datadump_id)
					end
				end
			end
			note = "Suppliers submitted"
		elsif params[:model_examined] == "review"
			note = "Reviews submitted"
			if params[:reviews]
				params[:reviews].each do |r_id, v|
					review = Review.find(r_id)
					review.supplier_id = params[:review_supplier_id][r_id] if params[:review_supplier_id] and params[:review_supplier_id][r_id]					
					if v == "display"
						review.displayable = true
					elsif v == "no_display"
						review.displayable = false
					else
						note = "At least one review had an incorrect display/no_display value"
					end
					review.save
				end
			end
		elsif params[:model_examined] == "contact_information"
			note = "Contact information for suppliers submitted"
			if params[:suppliers]
				params[:suppliers].each do |s_id, v|
					supplier = Supplier.find(s_id)
					supplier.create_or_update_address({ country: v["country"], 
																		state: v["state"],
																		zip: v["zip"]
																	})
					supplier.rfq_contact.update_attributes({email: v["email"], phone: v["phone"]})
				end
			end
		end 

		redirect_to setup_examinations_path(params[:model_examined]), notice: note
	end

end