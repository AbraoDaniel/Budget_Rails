class Registration < ApplicationRecord 
  # belongs_to :user 
  # has_many :operations, dependent: :destroy
  # validates :name, presence: true

  # def self.created_by_current_user(current_user) 
  #   where(user_id: current_user.id).order(created_at: :desc) 
  # end
end 
