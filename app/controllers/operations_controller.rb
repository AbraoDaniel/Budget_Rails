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
    @group = Group.find(params[:group_id])
    @operation = Operation.new
    @operations = Operation.all

    @operation_types = [
      { 'name' => 'Receita', 'source' => '0' },
      { 'name' => 'Despesa', 'source' => '1' }
    ]
  end

  def edit
    @group = Group.find(params[:group_id])
    @operation = Operation.find_by(id: params[:id]) rescue nil
    @operation_types = [
      { 'name' => 'Receita', 'source' => '0' },
      { 'name' => 'Despesa', 'source' => '1' }
    ]
  end

  def create
    @group = Group.find(params[:group_id])
    params = operation_params
    @operation = Operation.new(name: params[:name], amount: params[:amount], operation_type: params[:operation_type], group_id: @group.id)
    @operation.author = current_user
    if @operation.present?
      if @operation.operation_type == 0
        sumAmount = @group.group_amount + params[:amount].to_f
      else
        sumAmount = @group.group_amount - params[:amount].to_f
      end
      @group.update_columns(group_amount: sumAmount)
    end
    respond_to do |format|
      if @operation.save
        format.html do
          redirect_to group_operations_path(@group.id), notice: 'Transaction was successfully created.'
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
    @operation = Operation.find_by(id: params[:id]) rescue nil
    @group_id = @operation.group_id
    respond_to do |format|
      if @operation.update(operation_params)
        format.html { redirect_to group_operations_path(group_id), notice: 'Operation was successfully updated.' }
        format.json { render :show, status: :ok, location: @operation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @operation.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete_operation
    @operation = Operation.find_by(id: params[:operation_id]) rescue nil
    group_id = @operation.group_id
    if @operation.destroy
      respond_to do |format|
        format.html do
          redirect_to group_operations_url(group_id), notice: 'Transaction was successfully deleted.'
          format.json { head :no_content }
        end
      end
    end
  end

  # DELETE /operations/1 or /operations/1.json
  def destroy
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
