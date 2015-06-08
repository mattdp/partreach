class ExperimentsController < ApplicationController

  def ultem
    render layout: "old_layout"
  end

  def sls_vs_fdm
    @title = "SLS vs FDM"
    render layout: "old_layout"
  end

end