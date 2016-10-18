class FrontController < ApplicationController

  def index
    @announcements = Announcement.alive.take(5)
    @exchanges = Exchange.take(5)
    @lostfounds = LostFound.take(5)
    @jobs = Job.take(5)
    @threads = Discussion.alive.take(5)
    @rides = Ride.alive.take(5)
  end

  def search
    # Optionally limit to particular models
    #@scope = params[:scope].downcase
    q = params[:search]

    if true || @scope.nil? || @scope == "facebook"
      search = User.search { fulltext q }
      @users = search.results
    end

    if @scope.nil? || @scope == "factrak"
    end
  end
  
end

