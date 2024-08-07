class OperationsController < ApplicationController
  before_action :authenticate_user!

  def new
    @group = Group.find(params[:group_id].to_i)
    @operation = Operation.new
    @operation_types = [
      { 'name' => 'Receita', 'source' => '0' },
      { 'name' => 'Despesa', 'source' => '1' }
    ]
  end

  def edit
    @group = Group.find(params[:group_id].to_i)
    @operation = Operation.find(params[:id].to_i)
    @operation_types = [
      { 'name' => 'Receita', 'source' => '0' },
      { 'name' => 'Despesa', 'source' => '1' }
    ]
  end

  def index
    @group = Group.find(params[:group_id].to_i)
    session = NEO4J_DRIVER.session
    @operations = session.run("MATCH (o:Operation {group_id: $group_id}) RETURN o ORDER BY o.created_at ASC", group_id: @group.id).map do |result|
      Operation.new(result["o"].properties)
    end
    session.close

    respond_to do |format|
      format.html
      format.json { render json: @operations }
    end
  end

  def create
    @group = Group.find(params[:group_id].to_i)
    @operation = Operation.new(operation_params.merge(group_id: @group.id, author_id: current_user.id))
    if @operation.valid? && params[:operation][:amount].to_f > 0
      session = NEO4J_DRIVER.session
      begin
        result = session.run("CREATE (o:Operation {name: $name, amount: $amount, group_id: $group_id, author_id: $author_id, operation_type: $operation_type, created_at: $created_at, updated_at: $updated_at}) RETURN id(o)",
                             name: @operation.name, 
                             amount: @operation.amount, 
                             operation_type: @operation.operation_type, 
                             group_id: @group.id,
                             author_id: current_user.id,
                             created_at: DateTime.now,
                             updated_at: DateTime.now)
        o_id = result.single[0]
        @operation.id = o_id if o_id.present?
  
        if @operation.id
          session.run("MATCH (o:Operation) WHERE id(o) = $id SET o.operation_id = $operation_id",
              id: @operation.id,
              operation_id: @operation.id)

          session.run("MATCH (o:Operation), (g:Group) WHERE id(o) = $operation_id AND id(g) = $group_id CREATE (g)-[:HAS_OPERATION]->(o)",
                      operation_id: @operation.id, group_id: @group.id)
          apply_transaction_logic
          redirect_to group_operations_path(@group.id), notice: 'Operation was successfully created.'
        else
          render :new, alert: 'Failed to create operation.'
        end
      ensure
        session.close
      end
    else
      render :new, alert: 'Invalid operation data.'
    end
  end

  def update_operation
    @group = Group.find(params[:group_id].to_i)
    @operation = Operation.find(params[:id].to_i)
    if @operation
      session = NEO4J_DRIVER.session
      begin
        
        session.run("MATCH (o:Operation) WHERE id(o) = $id SET o += {name: $name, amount: $amount, operation_type: $operation_type, updated_at: $updated_at}",
                    id: @operation.id,
                    name: params[:operation][:name],
                    amount: params[:operation][:amount],
                    operation_type: params[:operation][:operation_type],
                    updated_at: DateTime.now)
        
        
        apply_transaction_logic if params[:operation][:amount].to_f > 0
  
        flash[:notice] = 'Operation was successfully updated.'
        redirect_to group_operations_path(@group.id)
      rescue => e
        flash[:alert] = "Failed to update operation: #{e.message}"
        render :edit
      ensure
        session.close
      end
    else
      flash[:alert] = "Operation not found."
      redirect_to group_operations_path(@group.id)
    end
  end

  def delete_operation
    @group = Group.find(params[:id].to_i)
    operation_id = params[:operation_id]
  
    session = NEO4J_DRIVER.session
    begin
      query = """
        MATCH (o:Operation)
        WHERE ID(o) = $operation_id
        DETACH DELETE o
      """
      session.run(query, operation_id: operation_id.to_i)
  
      flash[:notice] = 'Operation was successfully deleted.'
      redirect_to group_operations_path(@group.id)
    rescue => e
      flash[:alert] = "Failed to delete operation: #{e.message}"
      redirect_to group_operations_path(@group.id)
    ensure
      session.close
    end
  end

  private

  def apply_transaction_logic
    session = NEO4J_DRIVER.session
    begin
      new_amount = if @operation.operation_type == '0' 
                     @group.group_amount.to_f + @operation.amount.to_f
                   else 
                     @group.group_amount.to_f - @operation.amount.to_f
                   end
  
      session.run("MATCH (g:Group) WHERE id(g) = $group_id SET g.group_amount = $new_amount",
                  group_id: @group.id, new_amount: new_amount)
    ensure
      session.close
    end
  end

  def operation_params
    params.require(:operation).permit(:name, :amount, :operation_type)
  end
end
