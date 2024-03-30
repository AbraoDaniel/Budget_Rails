class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :groups, dependent: :destroy
  has_many :operations, dependent: :destroy, foreign_key: 'author_id'

  def admin?
    role == 'admin'
  end
end
