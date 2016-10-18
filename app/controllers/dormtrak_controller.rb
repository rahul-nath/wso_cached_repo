class DormtrakController < ApplicationController
  # TODO: Auto update if everything is anonymous, but
  # all expired..
  include DormtrakHelper

  before_action :ensure_user
  before_action :ensure_dormtrak_policy_acceptance, except: [:accept_policy, :policy]

  def policy
  end

  def index
    @neighborhoods = Neighborhood.all
    @reviews = DormtrakReview.commented.limit(10)
    # Nicer for forms. Abridges long reviews...
    @abridged = true
  end

  def search
    q = params[:search]
    @dorms = Dorm.trakked.where("lower(name) LIKE ?", "%#{q.downcase}%")
    redirect_to [:dormtrak, @dorms.first] if @dorms.length == 1
  end

  def accept_policy
    if params[:accept] == "1"
      current_user.has_accepted_dormtrak_policy = true
      current_user.save
      redirect_to request.referer || { :action => :index }
    else
      redirect_to "/front/index"
    end
  end

end
