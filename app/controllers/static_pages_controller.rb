class StaticPagesController < ApplicationController
	def home
	end

	def getting_started
	end

	def procurement
	end

	def materials
		@data_by_process = [
				{process: "SLS", material: "Nylon", looking_for: ["Good for mechanical performance","Good for mass production"], downsides: ["Worse than FDM for accuracy"]},
				{process: "SLA", material: "UV Curable Resin", looking_for: ["Application flexible","Good for mass production", "Great resolution"], downsides: ["Poor for mechanical performance"]},
				{process: "FDM", material: "ABS, PLA", looking_for: ["Great for accuracy", "Great for mechanical performance"], downsides: ["Poor for mass production"]},
				{process: "Polyjet", material: "ABS-like", looking_for: ["Great for accuracy", "Great for prototyping"], downsides: ["Poor for production", "Poor for mechanical performance"]}
				]
	end
	  
end
