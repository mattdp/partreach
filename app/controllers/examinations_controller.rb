class ExaminationsController < ApplicationController
	before_filter :examiner_user

	def setup_examinations
		@questionables = Supplier.quantity_by_tag_id(50,Tag.find_by_name("datadump").id)
	end

	#faster if batch load suppliers
	def submit_examinations
		datadump_id = Tag.find_by_name("datadump").id
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

		redirect_to setup_examinations_path, notice: "Examinations submitted."
	end

end