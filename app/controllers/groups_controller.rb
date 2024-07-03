class GroupsController < ApplicationController
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
    set_group
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
    @group = Group.find(params[:id].to_i)
    if @group
      session = NEO4J_DRIVER.session
      begin
        session.run("MATCH (g:Group) WHERE id(g) = $id SET g += {name: $name, icon: $icon, updated_at: $updated_at}",
                    id: @group.id,
                    name: group_params[:name],
                    icon: params[:group][:group_type],
                    updated_at: DateTime.now)
        flash[:notice] = 'Group was successfully updated.'
        redirect_to groups_path
      rescue => e
        flash[:alert] = "Failed to update group: #{e.message}"
        render :edit
      ensure
        session.close
      end
    else
      flash[:alert] = "Group not found."
      redirect_to groups_path
    end
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    set_group
    session = NEO4J_DRIVER.session
    begin
      query = """
        MATCH (g:Group) WHERE ID(g) = $group_id
        DETACH DELETE g
      """
      session.run(query, group_id: @group.id.to_i)
      session.close
      redirect_to groups_url, notice: 'Group was successfully destroyed.'
    rescue => e
      session.close
      flash[:alert] = "Failed to destroy group: #{e.message}"
      redirect_to groups_url
    end
  end

  private

  def set_group
    @group = Group.find(params[:id].to_i)
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

  def group_params
    params.require(:group).permit(:name, :icon, :group_amount)
  end
end
