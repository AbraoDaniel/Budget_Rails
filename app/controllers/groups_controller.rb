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

    @group_types = [
      {'name' => 'Alimentação', 'source' => '/icons/carrinho-de-compras.png'},
      {'name' => 'Moradia', 'source' => 'icons/casa.png'},
      {'name' => 'Lazer', 'source' => '/icons/controle.png'},
      {'name' => 'Saúde', 'source' => '/icons/estetoscopio.png' },
      {'name' => 'Transporte', 'source' => '/icons/carro.png'},
      {'name' => 'Outros', 'source' => '/icons/rede.png'}
    ]
  end

  # GET /groups/1/edit
  def edit; end

  # POST /groups or /groups.json
  def create
    @group = current_user.groups.new(group_params)
    if params[:group][:group_type].present?
      @group.icon = params[:group][:group_type]
    end
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
        format.html { redirect_to groups_path, notice: 'Group was successfully updated.' }
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
