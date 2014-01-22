class MachinesController < ApplicationController
	#should be all but show
	before_filter :admin_user, only: [:new, :create, :edit, :update]

	def new
		@machine = Machine.new
		@machines = Machine.all.sort_by{ |m| [m.manufacturer.name.downcase,m.name.downcase] }
		@manufacturer = Manufacturer.new
	end

	def create
		@machine = Machine.new(machine_params)
		@machine.manufacturer_id = Manufacturer.create_or_reference_manufacturer(manufacturer_params).id
		@machine.name_for_link = Machine.proper_name_for_link(@machine.name)

		saved_ok = @machine.save
		if saved_ok
			note = "Saved OK!" 
		else 
			note = "Saving problem."
		end

		redirect_to analytics_machines_path, notice: note
	end

	def edit
		@machine = Machine.find(params[:id])
		@manufacturer = @machine.manufacturer
		@machines = Machine.all.sort_by{ |m| [m.manufacturer.name.downcase,m.name.downcase] }
	end

	def update
		@machine = Machine.find(params[:id])
		@manufacturer = @machine.manufacturer

		saved_ok = @machine.update_attributes(machine_params)
		saved_ok = (@manufacturer.update_attributes(manufacturer_params) and saved_ok)

		if saved_ok
			note = "Saved OK!"
		else 
			note = "Saving problem."
		end		

		redirect_to analytics_machines_path, notice: note
	end

	def suppliers_with_machine
		@machine = Machine.find(params[:machine_id])
		owners = Owner.where("machine_id = ?",params[:machine_id])
		if owners.present?
			ids = owners.map{|o| o.supplier_id}
			@suppliers = ids.uniq.map{|id| Supplier.find(id)}
		else
			@suppliers = nil
		end

	end

  private

    def machine_params
      params.require(:machine).permit(:name,:bv_height,:bv_width,:bv_length,:z_height,\
      																:materials_possible)
    end

    def manufacturer_params
    	params.require(:manufacturer).permit(:name)
    end

end