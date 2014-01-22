module ProfilesHelper

	def panel_no_data(tab_reference)
		return "No #{tab_reference} yet!"
	end

	def allowed_to_see?(model)
		return false if model.nil?
		return true if model.profile_visible
		return true if !model.profile_visible and current_user.admin?
		(return true if !model.profile_visible and current_user.supplier_id == supplier.id) if model.class.to_s == "Supplier"
		return false
	end

	def meta_for_supplier(supplier)
    #http://stackoverflow.com/questions/6806473/rails-3-is-there-a-way-to-use-pluralize-inside-a-model-seems-to-only-work-in		
		potential_includes = []
    potential_includes << "a custom description" if supplier.description.present?
    potential_includes << "machines listed" if supplier.owners.present?
    potential_includes << "reviews from previous buyers" if supplier.reviews.present?
    return potential_includes
	end

end
