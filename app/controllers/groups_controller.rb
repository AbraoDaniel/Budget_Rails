class GroupsController < ApplicationController
  # before_action :set_group, only: %i[show edit update destroy]
  before_action :authenticate_user!

  # GET /groups or /groups.json
  def index
    @groups = current_user.groups
  end

  # GET /groups/1 or /groups/1.json
  def show; end

  # GET /groups/new
  def new
    @group = Group.new
    set_group_types
  end

  # GET /groups/1/edit
  def edit
    set_group_types
  end

  # POST /groups or /groups.json
  def create
    combined_params = group_params.merge(icon: params[:group][:group_type])
    @group = current_user.create_group(combined_params)
    if @group
      redirect_to groups_url, notice: 'Group was successfully created.'
    else
      render :new, alert: 'Failed to create group.'
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def update
    set_icon
    if @group.update(group_params)
      redirect_to groups_path, notice: 'Group was successfully updated.'
    else
      render :edit, alert: 'Failed to update group.'
    end
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    @group.destroy
    redirect_to groups_url, notice: 'Group was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find_by(id: params[:id])
  end

  def set_group_types
    @group_types = [
      {'name' => 'Alimentação', 'source' => '/icons/salada.png'},
      {'name' => 'Moradia', 'source' => '/icons/casa-icon.png'},
      {'name' => 'Lazer', 'source' => '/icons/coco.png'},
      {'name' => 'Saúde', 'source' => '/icons/cuidados-de-saude.png'},
      {'name' => 'Transporte', 'source' => '/icons/onibus-escolar.png'},
      {'name' => 'Outros', 'source' => '/icons/outros.png'}
    ]
  end

  def set_icon
    @group.icon = params[:group][:group_type] if params[:group][:group_type].present?
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.require(:group).permit(:name, :icon, :group_amount)
  end
end
