class ReportsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @report_types = [{"name" => "Visão geral de transações", "source" => "generate_all_values"}, 
    {"name" => "Valor de transações por categoria", "source" => "values_per_groups"},
    {"name" => "Valor de transações por mês", "source" => "values_per_month"}
    ]
  end

  def generate_operation_report
    start_date = params[:start_date].values.first
    end_date = params[:end_date].values.first
    report_type = params[:report_type]
    total_amount_value = 0
    case report_type
      when 'generate_all_values'
        if start_date.present? && end_date.present?
          total_amount_value = Operation.get_total_operations_in_range(start_date, end_date,  current_user.id)
          redirect_to reports_path, flash: { total_revenue: total_amount_value[:total_revenue], total_spent: total_amount_value[:total_spent], start_date: start_date, end_date: end_date}
        end
      when 'values_per_groups'
        if start_date.present? && end_date.present?
          report_values = Operation.get_total_operations_per_group(start_date, end_date,  current_user.id)
          redirect_to reports_path, flash: { report_values: report_values, start_date: start_date, end_date: end_date}
        end
      when 'values_per_month'
        report_values = Operation.get_total_operations_per_mounth(current_user.id)
        redirect_to reports_path, flash: { report_month_values: report_values}
    end
  end
end
