class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    can :read, Registration do |registration|
      if user
        user.is_agency_user? || user.email == registration.accountEmail
      else
        false
      end
    end

    can :update, Registration do |registration|
      isEitherFinance = user.has_any_role?({ :name => :Role_financeBasic, :resource => AgencyUser }, { :name => :Role_financeAdmin, :resource => AgencyUser })
      if user
        # 
        # Note: This is a negative check for neither financeBasic or financeAdmin, thus any other role can perform updates
        # 
        if !(isEitherFinance)
          user.is_agency_user? || user.email == registration.accountEmail
        else
          false
        end
      else
        false
      end
    end
    
    #
    # TODO: Adjust this later if a particular agency user is not allowed to add payments
    #
    can :update, Payment if user.is_agency_user?

  end #initialize

end
