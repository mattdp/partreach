class OwnersController < ApplicationController
	before_filter :admin_user

	def new
		@supplier = Supplier.find(params[:supplier_id])
		@machines_quantity_hash = @supplier.machines_quantity_hash
		@machines = Machine.all.sort_by{ |m| [m.manufacturer,m.name] }
	end

	def create
		supplier = Supplier.find(params[:supplier_id])
		saved_ok = supplier.add_machine(params[:machine_id],params[:quantity].to_i)
		if saved_ok
			note = "Saved OK!" 
		else 
			note = "Saving problem."
		end

		redirect_to new_owner_path(supplier.id), notice: note
	end

	def destroy
		supplier = Supplier.find(params[:supplier_id])
		if saved_ok = supplier.remove_machines(params[:machine_id])
			note = "Saved OK!" 
		else 
			note = "Saving problem."
		end

		redirect_to new_owner_path(supplier.id)
	end

end