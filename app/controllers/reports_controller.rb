class ReportsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    # @group = Group.find(params[:group_id])
    # @operations = Operation.all.where("group_id = ?", @group.id).order(created_at: :desc) rescue nil
  end

  def generate_operation_report
    start_date = params[:start_date].values.first
    end_date = params[:end_date].values.first
    total_amount_value = 0
    if start_date.present? && end_date.present?
      total_amount_value = Operation.get_total_operations_in_range(start_date, end_date,  current_user.id)
    end

    redirect_to reports_path, flash: { total_revenue: total_amount_value[:total_revenue], total_spent: total_amount_value[:total_spent], start_date: start_date, end_date: end_date}
  end
end
