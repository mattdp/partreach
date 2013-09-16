class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper

	#http://stackoverflow.com/questions/1183506/make-blank-params-nil
  def clean_params
  	@clean_params ||= HashWithIndifferentAccess.new.merge blank_to_nil( params )
	end

	def blank_to_nil(hash)
	  hash.inject({}){|h,(k,v)|
	    h.merge(
	      k => case v
	      when Hash
	      	blank_to_nil v
	      when Array
	      	v.map{|e| e.is_a?( Hash ) ? blank_to_nil(e) : e}
	      else 
	      	v == "" ? nil : v
	      end
	    )
	  }
	end

end
