class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    return unless user.present?

    can :manage, Group, user_id: user.id
    can :manage, Operation, author_id: user.id

    can :manage, :all
  end
end
