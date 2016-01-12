class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new        # guest user (not logged in)
    if user.admin
      can :manage, :all
    else
      can :index, :welcome
      if user.activated
        # can [:index, :show, :with_answers, :without_answers], Question
        can :manage, Question
        cannot :destroy, Question
        can :manage, Answer, user_id: user.id
      end
    end
  end
end
