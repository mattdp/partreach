class StaticPagesController < ApplicationController
	def home
	end

	def getting_started
	end

	def procurement
	end

	def be_a_supplier
	end

	def terms
	end

	def privacy
	end

	def materials
		@data_by_process = [
				{process: "SLS", material: "Nylon (with various blends), ceramics, metals", looking_for: ["Decent mechanical performance","Low-volume production", "Thinner wall thickness than FDM", "Surface detail"], downsides: ["Dimensional stability lower than FDM", "Trapped powder with hollow object", "Porous"], example: ["A run of 20 custom cable brackets"]},
				{process: "SLA", material: "UV Curable Resin", looking_for: ["Flexible applications", "Great resolution"], downsides: ["Increased brittleness", "Degrades over time due with UV exposure"], example: ["A master print for Rapid Casting"]},
				{process: "Industrial FFF (aka FDM)", material: "ABS (with various blends), Polycarbonate, Nylon, Ultem", looking_for: ["Great mechanical performance", "Low-volume production"], downsides: ["Striations from print visible", "Surface detail worse than SLS (unless post-processed)"], example: ["Functional prototype"]},
				{process: "Hobbyist FFF (desktop 3D printers)", material: "ABS, PLA, Nylon", looking_for: ["Cheap to make", "Quickest method (at low resolution)"], downsides: ["Low accuracy", "Striations from print visible", "Low surface detail (unless post-processed)", "Poor as an end-use part"], example: ["A pair of large hollow wheels"]},
				{process: "Polyjet", material: "Proprietary materials that range from soft rubber to brittle acrylic", looking_for: ["Great accuracy", "Can mix materials"], downsides: ["Poor for end-use parts"], example: ["A 'looks-like' prototype of a new toothbrush design"]}
				]
	end
	  
end
