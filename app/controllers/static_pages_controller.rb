class StaticPagesController < ApplicationController
	def home
	end

	def getting_started
	end

	def procurement
	end

	def materials
		@data_by_process = [
				{process: "SLS", material: "Nylon", looking_for: ["Good mechanical performance","Mass production capability"], downsides: ["Worse accuracy than FDM"]},
				{process: "SLA", material: "UV Curable Resin", looking_for: ["Flexible applications","Mass production ", "Great resolution"], downsides: ["Poor mechanical performance"]},
				{process: "FDM", material: "ABS, PLA", looking_for: ["Great accuracy", "Great mechanical performance"], downsides: ["Poor for mass production"]},
				{process: "Polyjet", material: "ABS-like", looking_for: ["Great accuracy", "Great prototyping"], downsides: ["Poor for production", "Poor mechanical performance"]}
				]
	end
	  
end
