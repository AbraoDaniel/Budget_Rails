class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy]
  before_action :authenticate_user!

  # GET /groups or /groups.json
  def index
    @groups = Group.where(user_id: current_user.id)
    # raise @groups.inspect
  end

  # GET /groups/1 or /groups/1.json
  def show; end

  # GET /groups/new
  def new
    @group = Group.new

    @group_types = [
      {'name' => 'Alimentação', 'source' => '/icons/salada.png'},
      {'name' => 'Moradia', 'source' => '/icons/casa-icon.png'},
      {'name' => 'Lazer', 'source' => '/icons/coco.png'},
      {'name' => 'Saúde', 'source' => '/icons/cuidados-de-saude.png' },
      {'name' => 'Transporte', 'source' => '/icons/onibus-escolar.png'},
      {'name' => 'Outros', 'source' => '/icons/outros.png'}
    ]
  end

  # GET /groups/1/edit
  def edit; 
    @group_types = [
      {'name' => 'Alimentação', 'source' => '/icons/salada.png'},
      {'name' => 'Moradia', 'source' => '/icons/casa-icon.png'},
      {'name' => 'Lazer', 'source' => '/icons/coco.png'},
      {'name' => 'Saúde', 'source' => '/icons/cuidados-de-saude.png' },
      {'name' => 'Transporte', 'source' => '/icons/onibus-escolar.png'},
      {'name' => 'Outros', 'source' => '/icons/outros.png'}
    ]
  end

  # POST /groups or /groups.json
  def create
    @group = current_user.groups.new(group_params)
    if params[:group][:group_type].present?
      @group.icon = params[:group][:group_type]
    end
    if @group.save
      redirect_to groups_url
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def update
    if params[:group][:group_type].present?
      @group.icon = params[:group][:group_type]
    end
    if @group.update(group_params)
      redirect_to groups_path
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
    params.require(:group).permit(:name, :icon, :group_amount)
  end
end
