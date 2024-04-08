class Operation < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  has_and_belongs_to_many :groups, dependent: :destroy

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
end
