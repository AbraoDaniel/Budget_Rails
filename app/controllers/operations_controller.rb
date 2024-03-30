class OperationsController < ApplicationController
  before_action :set_operation, only: %i[show edit update destroy new create]
  before_action :authenticate_user!

  def index
    @group = Group.find(params[:group_id])
    @operations = Operation.all.where("group_id = ?", @group.id).order(created_at: :desc) rescue nil
  end

  # GET /operations/1 or /operations/1.json
  def show; end

  # GET /operations/new
  def new
    @operation = Operation.new
    @operations = Operation.all
    @groups = Group.created_by_current_user(current_user)

    @operation_types = [
      { 'name' => 'Receita', 'source' => '0' },
      { 'name' => 'Despesa', 'source' => '1' }
    ]
  end

  def edit; end

  def create
    @group = Group.find(params[:group_id])
    params = operation_params
    @operation = Operation.new(name: params[:name], amount: params[:amount], operation_type: params[:operation_type], group_id: @group.id)
    @operation.author = current_user
    respond_to do |format|
      if @operation.save
        format.html do
          redirect_to group_operations_url(@group.id), notice: 'Transaction was successfully created.'
        end
        format.json { render :show, status: :created, location: @operation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @operation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /operations/1 or /operations/1.json
  def update
    respond_to do |format|
      if @operation.update(operation_params)
        format.html { redirect_to group_operations_url(@operation), notice: 'Operation was successfully updated.' }
        format.json { render :show, status: :ok, location: @operation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @operation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /operations/1 or /operations/1.json
  def destroy
    raise @operation.inspect
    @operation.destroy

    respond_to do |format|
      format.html do
        redirect_to group_operations_url(@operation.groups.first.id), notice: 'Transaction was successfully deleted.'
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_operation
    # @group = groups.operations.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def operation_params
    params.require(:operation).permit(:name, :amount, :operation_type, :group_id)
  end
end
