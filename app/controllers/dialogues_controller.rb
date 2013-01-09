class DialoguesController < ApplicationController
  # GET /dialogues
  # GET /dialogues.json
  def index
    @dialogues = Dialogue.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dialogues }
    end
  end

  # GET /dialogues/1
  # GET /dialogues/1.json
  def show
    @dialogue = Dialogue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dialogue }
    end
  end

  # GET /dialogues/new
  # GET /dialogues/new.json
  def new
    @dialogue = Dialogue.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dialogue }
    end
  end

  # GET /dialogues/1/edit
  def edit
    @dialogue = Dialogue.find(params[:id])
  end

  # POST /dialogues
  # POST /dialogues.json
  def create
    @dialogue = Dialogue.new(params[:dialogue])

    respond_to do |format|
      if @dialogue.save
        format.html { redirect_to @dialogue, notice: 'Dialogue was successfully created.' }
        format.json { render json: @dialogue, status: :created, location: @dialogue }
      else
        format.html { render action: "new" }
        format.json { render json: @dialogue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /dialogues/1
  # PUT /dialogues/1.json
  def update
    @dialogue = Dialogue.find(params[:id])

    respond_to do |format|
      if @dialogue.update_attributes(params[:dialogue])
        format.html { redirect_to @dialogue, notice: 'Dialogue was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @dialogue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dialogues/1
  # DELETE /dialogues/1.json
  def destroy
    @dialogue = Dialogue.find(params[:id])
    @dialogue.destroy

    respond_to do |format|
      format.html { redirect_to dialogues_url }
      format.json { head :no_content }
    end
  end
end
