class MachinesController < ApplicationController
	before_filter :admin_user

	def new
		@machine = Machine.new
		@machines = Machine.all.sort_by{ |m| [m.manufacturer,m.name] }
	end

	def create
		@machine = Machine.new(machine_params)

		saved_ok = @machine.save
		if saved_ok
			note = "Saved OK!" 
		else 
			note = "Saving problem."
		end

		redirect_to analytics_machines_path, notice: note
	end

  private

    def machine_params
      params.require(:machine).permit(:name,:manufacturer)
    end	

end