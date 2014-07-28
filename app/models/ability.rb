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

    can :print, Registration do |registration|
      user.try(:is_agency_user?) or ((registration.user == user) and owe_nothing?(registration))
    end

    can :read, Registration do |registration|
      if user
        user.is_agency_user? || user.email == registration.accountEmail
      else
        false
      end
    end

    can :update, Registration do |registration|
      if user
        # 
        # Note: This is a negative check for neither financeBasic or financeAdmin, thus any other role can perform updates
        # 
        if user.email == registration.accountEmail 
          true
        elsif user.is_agency_user?
          isEitherFinance = user.has_any_role?({ :name => :Role_financeBasic, :resource => AgencyUser }, { :name => :Role_financeAdmin, :resource => AgencyUser })
          !isEitherFinance
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
    if !user.nil? and user.is_agency_user?
#      can :manage, Payment
      can :read, Payment
    end
    
	if !user.nil? and user.is_agency_user? and user.has_role? :Role_ncccRefund, AgencyUser
	  can :newRefund, Payment
	end
	
	if !user.nil? and user.is_agency_user? and user.has_any_role?({ :name => :Role_ncccRefund, :resource => AgencyUser }, { :name => :Role_financeBasic, :resource => AgencyUser })
	  can :writeOffPayment, Payment
	end
	
	if !user.nil? and user.is_agency_user? and user.has_role? :Role_financeBasic, AgencyUser
	  can :enterPayment, Payment
	end
	
	if !user.nil? and user.is_agency_user? and user.has_role? :Role_financeAdmin, AgencyUser
	  # TMP: make tests pass re:review tests once roles correct?
	  can :writeOffPayment, Payment
	  
	  can :writeOffOrder, Order
	  can :enterPayment, Payment
	  can :newRefund, Order
	end	

  end #initialize

private

  def owe_nothing? registration
    registration.lower? or (registration.upper? and registration.paid_in_full?)
  end

end
