require 'wso_tools'

class ApplicationController < ActionController::Base
  protect_from_forgery
  skip_before_action :verify_authenticity_token, if: :json_request?
  # Filters added to this controller will be run for all controllers in the
  # application.
  # Likewise, all the methods added will be available for all controllers.

  # Filter methods are divided into the actual filter (ensure_something) and the
  # helper which does the work (something?). When you want to || filters, you must
  # use the something? helper. Note the helpers cannot be used as a filter, because
  # if you had a before_action :on_campus? for example that returns false, it wouldn't matter
  # because Rails only cares about whether the filter redirects. So ensure_on_campus redirects

  include ApplicationHelper

  protected

  def return_unavailable_status
    render '503', status: :service_unavailable
  end

  ## Filters

  # Expects a header HTTP_AUTHORIZATION (or just AUTHORIZATION if you're using curl)
  # with the value "Token token=\"#{token}\""
  # def token_authenticated
  #   token_header = request.headers['HTTP_AUTHORIZATION']
  #   @token = token_header.split('"').second if token_header
  #   @current_user = User.with_access_token(@token)
  #   @current_user
  # end

  # We can access resources if we're on campus, logged in, or have a valid access token
  def ensure_authorization
    if json_request?
      ensure_token
    else
      unless logged_in? || on_campus? #|| ensure_token
        login_first
      end
    end
  end

  def ensure_authorization_for_index
    if json_request?
      ensure_token(true)
    else
      unless logged_in? || on_campus? #|| ensure_token(true)
        login_first
      end
    end
  end

  # def ensure_token(json_array_request=false)
  #   case request.format
  #   when Mime::JSON
  #     unless token_authenticated
  #       if json_array_request
  #         render json: [{ error: :invalid_token }]
  #       else
  #         render json: { error: :invalid_token }
  #       end
  #     end
  #   end
  # end

  def ensure_user
    login_first unless logged_in?
  end

  def ensure_campus_or_at_williams
    login_first unless on_campus? || at_williams?
  end

  def ensure_on_campus
    forbidden "You must at least be on campus to access this" unless on_campus?
  end

  ## Ensures the viewer has a current Williams OIT account.
  def ensure_at_williams
    forbidden "You are not logged in as a current student or faculty/staff member." unless at_williams?
  end

  def ensure_student
    forbidden "You must be a current student to access this service. (If you are a current student, please email us)" unless student?
  end

  def ensure_admin
    forbidden "Not so fast. Admins only." unless admin?
  end

  def ensure_dormtrak_policy_acceptance
    render template: "dormtrak/policy" unless current_user.try(:has_accepted_dormtrak_policy?)
  end

  ## Requires user to login first, then redirects to where they were trying to go
  def login_first
    redirect_to account_login_path(dest: (params[:dest] || request.path))
  end

  def forbidden(reason)
    flash[:notice] = reason
    if request.referer.nil? || request.referer.match(account_login_path)
      redirect_to root_path
    else
      redirect_to request.referer
    end
  end

  def cache_dir
    "#{RAILS_ROOT}/cache"
  end

end
