class Operation < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :groups, class_name: 'Group', foreign_key: 'group_id'

  validates :name, :amount, :group_id, presence: true

  def timelapse
    start_time = created_at
    end_time = Time.now

    TimeDifference.between(start_time, end_time).humanize
  end

  def self.get_total_operations_in_range start_date, end_date, current_user_id
    @operations = Operation.all.where("author_id = ? AND DATE(created_at) BETWEEN ? AND ?", current_user_id, start_date, end_date)
    total_revenue_amount = 0
    total_spent_amount = 0
    @operations.each do |operation| 
      if operation.operation_type == 0
        total_revenue_amount += operation.amount
      else
        total_spent_amount += operation.amount
      end
    end
    return {total_revenue: total_revenue_amount, total_spent: total_spent_amount}
  end

  def self.get_total_operations_per_group start_date, end_date, current_user_id
    transactions_per_group = self.select("
          operations.group_id,
          groups.name as group_name,
          groups.icon as group_icon,
          SUM(CASE WHEN operation_type = 0 THEN amount ELSE 0 END) AS total_revenue,
          SUM(CASE WHEN operation_type = 1 THEN amount ELSE 0 END) AS total_spent
        ")
        .joins("JOIN groups ON operations.group_id = groups.id")
        .where("author_id = ? AND DATE(operations.created_at) BETWEEN ? AND ?", current_user_id, start_date, end_date)
        .group("operations.group_id, groups.id")
    report_data = transactions_per_group.map(&:attributes)
    return {report_data: report_data}
  end

  def self.get_total_operations_per_mounth current_user_id
    transactions_per_mounth = self.select("
    (CASE WHEN EXTRACT('MONTH' FROM operations.created_at) = 1 THEN 'Janeiro'
    WHEN EXTRACT('MONTH' FROM operations.created_at) = 2 THEN 'Fevereiro'
    WHEN EXTRACT('MONTH' FROM operations.created_at) = 3 THEN 'Março'
    WHEN EXTRACT('MONTH' FROM operations.created_at) = 4 THEN 'Abril'
    WHEN EXTRACT('MONTH' FROM operations.created_at) = 5 THEN 'Maio'
    WHEN EXTRACT('MONTH' FROM operations.created_at) = 6 THEN 'Junho'
    WHEN EXTRACT('MONTH' FROM operations.created_at) = 7 THEN 'Julho'
    WHEN EXTRACT('MONTH' FROM operations.created_at) = 8 THEN 'Agosto'
    WHEN EXTRACT('MONTH' FROM operations.created_at) = 9 THEN 'Setembro'
    WHEN EXTRACT('MONTH' FROM operations.created_at) = 10 THEN 'Outubro'
    WHEN EXTRACT('MONTH' FROM operations.created_at) = 11 THEN 'Novembro'
    WHEN EXTRACT('MONTH' FROM operations.created_at) = 12 THEN 'Dezembro' ELSE 'Desconhecido' END) AS mounth, 
    SUM(CASE WHEN operation_type = 0 THEN amount ELSE 0 END) AS total_revenue,
    SUM(CASE WHEN operation_type = 1 THEN amount ELSE 0 END) AS total_spent")
    .where("author_id = ?", current_user_id)
    .group("EXTRACT('MONTH' FROM operations.created_at)")
    report_data = transactions_per_mounth.map(&:attributes)
    return {report_data: report_data}
  end
end
