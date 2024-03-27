class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy]
  before_action :authenticate_user!

  # GET /groups or /groups.json
  def index
    @groups = Group.where(user_id: current_user.id)
  end

  # GET /groups/1 or /groups/1.json
  def show; end

  # GET /groups/new
  def new
    @group = Group.new

    @icons = [
      { 'name' => 'Teste', 'source' => '/icons/travels.png' }
      # {'name' => 'Mercado', 'source' => '/icons/carrinho-de-compras.png'},
      # { 'name' => 'Food', 'source' => '/icons/Accomodation.png' },
      # { 'name' => 'Home appliances', 'source' => '/icons/appliances.png' },
      # { 'name' => 'Clothing', 'source' => '/icons/clothing.png' },
      # { 'name' => 'Children', 'source' => '/icons/kids.png' },
      # { 'name' => 'Transportation', 'source' => '/icons/travels.png' },
      # { 'name' => 'Others', 'source' => '/icons/others.png' }
    ]
  end

  # GET /groups/1/edit
  def edit; end

  # POST /groups or /groups.json
  def create
    @group = current_user.groups.new(group_params)
    # @group.user = @user

    respond_to do |format|
      if @group.save
        format.html { redirect_to groups_url, notice: 'Group was successfully created.' }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to group_url(@group), notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    if @group.present?
      @group.destroy
      respond_to do |format|
        format.html { redirect_to groups_url, notice: 'Group was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.require(:group).permit(:name, :icon)
  end
end
