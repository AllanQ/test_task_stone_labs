class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new        # guest user (not logged in)
    if user.admin
      can :manage, :all
    else
      can :index, :welcome
      if user.activated
        can    :show,          Question
        cannot :destroy,       Question
        can   [:index, :show], QuestionCategory
        cannot :destroy,       QuestionCategory
        can    :manage,        Answer, user_id: user.id
      end
    end
  end
end
