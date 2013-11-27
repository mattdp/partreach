class MachinesController < ApplicationController
	before_filter :admin_user

	def new
		@machine = Machine.new
		@machines = Machine.all.sort_by{ |m| [m.manufacturer.name.downcase,m.name.downcase] }
	end

	def create
		@machine = Machine.new(machine_params)
		@machine.manufacturer_id = Manufacturer.create_or_reference_manufacturer(params[:manufacturer])

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
		@machines = Machine.all.sort_by{ |m| [m.manufacturer,m.name] }
	end

	def update
		@machine = Machine.find(params[:id])
		@manufacturer = @machine.manufacturer

		saved_ok = @machine.update_attributes(machine_params)
		@manufacturer.name = params[:manufacturer]
		saved_ok = (@manufacturer.save and saved_ok)

		if saved_ok
			note = "Saved OK!" 
		else 
			note = "Saving problem."
		end		

		redirect_to analytics_machines_path, notice: note
	end

  private

    def machine_params
      params.require(:machine).permit(:name)
    end

    def manufacturer_params
    	params.require(:machine).permit(:manufacturer)
    end

end