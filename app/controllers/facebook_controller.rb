class FacebookController < ApplicationController
  include FacebookHelper

  before_action :ensure_authorization_for_index, only: :index
  before_action :ensure_user, except: :index

  def index
    @searched = false # for making display options disappear and appear
    @tagline = "search"

    @results = Array.new

    # set the view mode
    if params[:mode]
      session[:facebook_results_mode] = params[:mode]
    else
      session[:facebook_results_mode] ||= "auto"
    end
    
    # If we got a nonempty, non whitespace search query, search.
    if params[:search] and !params[:search].strip.empty?
      @searched = true # for making display options disappear and appear
      # If we're searching within a previous query and we have a previous query, do so.
      if params[:subsearch] and session[:facebook_query]
        if session[:facebook_query] != params[:search].strip
          session[:facebook_query] = "( #{session[:facebook_query]} ) & ( #{params[:search].strip} )"
        end
      else
        session[:facebook_query] = params[:search].strip
      end
      @search = true
     @results = User.search(session[:facebook_query])

    else
      session[:facebook_query] = nil
    end

    if @results.length == 1
      redirect_to @results.first
    end  	
  end

  def help
  end

  def edit
  end

end
