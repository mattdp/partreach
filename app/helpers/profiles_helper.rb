module ProfilesHelper

	def panel_no_data(tab_reference)
		return "No #{tab_reference} yet!"
	end

	def allowed_to_see_supplier_profile?(supplier)
		return false if supplier.nil?
		return true if supplier.profile_visible
		return false if !supplier.profile_visible and current_user.nil?
		return true if !supplier.profile_visible and (current_user.admin? or current_user.supplier_id == supplier.id)
	end

end
