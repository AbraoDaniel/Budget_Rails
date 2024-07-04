class ReportsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @report_types = [
      {"name" => "Visão geral de transações", "source" => "generate_all_values"}, 
      {"name" => "Valor de transações por categoria", "source" => "values_per_groups"},
      {"name" => "Valor de transações por mês", "source" => "values_per_month"}
    ]
  end

  def generate_operation_report
    start_date = params[:start_date].values.first
    end_date = params[:end_date].values.first
    report_type = params[:report_type]

    case report_type
    when 'generate_all_values'
      if start_date.present? && end_date.present?
        total_amount_value = get_total_operations_in_range(start_date, end_date, current_user.id)
        redirect_to reports_path, flash: { total_revenue: total_amount_value[:total_revenue], total_spent: total_amount_value[:total_spent], start_date: start_date, end_date: end_date}
      end
    when 'values_per_groups'
      if start_date.present? && end_date.present?
        report_values = get_total_operations_per_group(start_date, end_date, current_user.id)
        redirect_to reports_path, flash: { report_values: report_values, start_date: start_date, end_date: end_date}
      end
    when 'values_per_month'
      report_values = get_total_operations_per_month(current_user.id)
      redirect_to reports_path, flash: { report_month_values: report_values}
    end
  end

  private

  # Adapting original ActiveRecord queries to Cypher queries for Neo4j
  def get_total_operations_in_range(start_date, end_date, user_id)
    session = NEO4J_DRIVER.session
    query = """
      MATCH (o:Operation)
      WHERE o.author_id = $author_id AND date(o.created_at) >= date($start_date) AND date(o.created_at) <= date($end_date)
      RETURN 
        SUM(CASE WHEN o.operation_type = '0' THEN toInteger(o.amount) ELSE 0 END) AS total_revenue,
        SUM(CASE WHEN o.operation_type = '1' THEN toInteger(o.amount) ELSE 0 END) AS total_spent
    """
    result = session.run(query, author_id: user_id, start_date: start_date, end_date: end_date).single
    session.close
    { total_revenue: result['total_revenue'], total_spent: result['total_spent'] }
  end

  def get_total_operations_per_group(start_date, end_date, user_id)
    session = NEO4J_DRIVER.session
    query = """
    MATCH (g:Group)-[:HAS_OPERATION]->(o:Operation)
    WHERE o.author_id = $author_id AND datetime(o.created_at) >= datetime($start_date) AND datetime(o.created_at) <= datetime($end_date)
    RETURN g.name AS group_name, g.icon AS group_icon,
    SUM(CASE WHEN o.operation_type = '0' THEN toInteger(o.amount) ELSE 0 END) AS total_revenue,
    SUM(CASE WHEN o.operation_type = '1' THEN toInteger(o.amount) ELSE 0 END) AS total_spent
    """
    results = session.run(query, author_id: user_id, start_date: start_date, end_date: end_date).map do |record|
      {
        group_name: record[:group_name],
        group_icon: record[:group_icon],
        total_revenue: record[:total_revenue],
        total_spent: record[:total_spent]
      }
    end
    session.close
    results
  end

  def get_total_operations_per_month(user_id)
    session = NEO4J_DRIVER.session
    query = """
      MATCH (o:Operation)
      WHERE o.author_id = $author_id
      RETURN
      CASE SUBSTRING(toString(o.created_at), 6, 1)
        WHEN '1' THEN 'Janeiro'
        WHEN '2' THEN 'Fevereiro'
        WHEN '3' THEN 'Março'
        WHEN '4' THEN 'Abril'
        WHEN '5' THEN 'Maio'
        WHEN '6' THEN 'Junho'
        WHEN '7' THEN 'Julho'
        WHEN '8' THEN 'Agosto'
        WHEN '9' THEN 'Setembro'
        WHEN '10' THEN 'Outubro'
        WHEN '11' THEN 'Novembro'
        WHEN '12' THEN 'Dezembro'
      ELSE 'Desconhecido'
      END AS month,
        SUM(CASE WHEN o.operation_type = '0' THEN toInteger(o.amount) ELSE 0 END) AS total_revenue,
        SUM(CASE WHEN o.operation_type = '1' THEN toInteger(o.amount) ELSE 0 END) AS total_spent
    """
    results = session.run(query, author_id: user_id).map do |record|
      {
        month: record[:month],
        total_revenue: record[:total_revenue],
        total_spent: record[:total_spent]
      }
    end
    session.close
    results
  end
end
