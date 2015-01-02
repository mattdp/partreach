class ExperimentsController < ApplicationController

  def sde

    #make sure to link to suppliers that have it in v2, after benchmarking
    @block =
        {
          title: "Stratasys Dimensions Elite - Machine Profile",
          description: "The Stratasys Dimensions Elite is a 3D printer from Stratasys, that additively manufactures objects through the FDM (Fused Deposition Modeling) process",
          example_project: "A client used a Dimension Elite to make a small plastic chair prototype",
          when_use: ["rough surface finish","rigid plastic","proprietary Stratasys materials","prototyping"],
          why_buy_text: "We bought this machine so that we could 3D print objects",
          why_buy_supplier: "Fake Supplier Inc.",
          manufacturer: "Stratasys",
          process_tags: [Tag.find_by_name("FDM")],
          materials: ["ABS M30","ABS ESD7"],
          filetypes: ["STL"],
          build_chamber_xyz: "3x4x5"
        }

  end

  def sla

    #make sure to link to suppliers that have it in v2, after benchmarking
    @block =
        {
          title: "3D Systems iPro 8000 - Machine Profile",
          description: "This printer is in 3D Systems' midrange production SLA machines. SLA offers high tolerance and smooth surface finish.",
          example_project: "A SupplyBetter client used an iPro 8000 to prototype a perpetual motion device",
          when_use: ["smooth surface finish","durability not required","proprietary 3D Systems materials","prototyping"],
          why_buy_text: "We bought this machine so that we could 3D print objects",
          why_buy_supplier: "Not A Real Company Inc.",
          manufacturer: "3D Systems",
          process_tags: [Tag.find_by_name("SLA")],
          materials: ["Accura Sapphire, Accura 55"],
          filetypes: ["STL","IGES"],
          build_chamber_xyz: "3x6x10"
        }

  end

  def ultem

  end

  def sls_vs_fdm
    @title = "SLS vs FDM"
  end

  def solid_concepts
    @supplier = Supplier.find_by_name_for_link("solidconcepts")

    @tags = @supplier.visible_tags if @supplier
    @machines_quantity_hash = @supplier.machines_quantity_hash
    @num_machines = @machines_quantity_hash.sum{|k,v| v}
    @num_reviews = @supplier.visible_reviews.count

    @meta = ""
    @meta += "Tags for #{@supplier.name} include " + andlist(@tags.take(3).map{ |t| "\"#{t.readable}\""}) + ". " if @tags.present?
    profile_factors = andlist(meta_for_supplier(@supplier))
    @meta += "The #{@supplier.name} profile has " + andlist(meta_for_supplier(@supplier)) + ". " if profile_factors.present?
    @meta = @meta.present? ? @meta : "#{@supplier.name} - Supplier profile"
    render "profile"
  end

end