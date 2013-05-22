class StaticPagesController < ApplicationController
	def home
	end

	def getting_started
	end

	def procurement
	end

	def materials
		@data_by_process = [
				{process: "SLS", material: "Nylon", looking_for: ["Decent mechanical performance","Low-volume production"], downsides: ["Worse accuracy than FDM", "Poor for closed hollow geometries"], example: ["A run of 20 custom cable brackets"]},
				{process: "SLA", material: "UV Curable Resin", looking_for: ["Flexible applications", "Great resolution"], downsides: ["Poor mechanical performance"], example: ["A master print for Rapid Casting"]},
				{process: "FDM", material: "ABS, PLA", looking_for: ["Great mechanical performance"], downsides: ["Poor for mass production"], example: ["A pair of large hollow wheels"]},
				{process: "Polyjet", material: "ABS-like", looking_for: ["Great accuracy", "Can mix materials"], downsides: ["Poor mechanical performance over time"], example: ["A 'looks-like' prototype of a new toothbrush design"]}
				]
	end
	  
end
