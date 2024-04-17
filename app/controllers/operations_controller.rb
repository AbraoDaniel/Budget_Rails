class OperationsController < ApplicationController
  before_action :set_operation, only: %i[show edit update destroy new create]
  before_action :authenticate_user!

  respond_to :html, :json

  def index
    @group = Group.find(params[:group_id])
    @operations = Operation.all.where("group_id = ?", @group.id).order(created_at: :asc) rescue nil
  end

  def show; end

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
    if @operation.present? && params[:amount].to_f > 0
      if @operation.operation_type == 0
        sumAmount = @group.group_amount.to_f + params[:amount].to_f
      else
        sumAmount = @group.group_amount.to_f - params[:amount].to_f
      end
      @group.update_columns(group_amount: sumAmount)
      if @operation.save
        redirect_to group_operations_path(@group.id)
      end
    end
  end

  def update_operation
    @operation = Operation.find_by(id: params[:id]) rescue nil
    @group_id = @operation.group_id
    if @operation.update(operation_params)
      redirect_to group_operations_path(@group_id)
    end
  end

  def delete_operation
    @operation = Operation.find_by(id: params[:operation_id]) rescue nil
    @group = Group.find(@operation.group_id)
    if @operation.present?
      if @operation.operation_type == 0
        sumAmount = @group.group_amount.to_f - @operation.amount.to_f
      else
        sumAmount = @group.group_amount.to_f + @operation.amount.to_f
      end
      @group.update_columns(group_amount: sumAmount)
    end
    if @operation.destroy
      redirect_to group_operations_path(@group.id)
    end
  end

  private

  def set_operation
  end

  def operation_params
    params.require(:operation).permit(:name, :amount, :operation_type, :group_id)
  end
end
