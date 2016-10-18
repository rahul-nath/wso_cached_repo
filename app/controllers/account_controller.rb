require 'wso_tools'

class AccountController < ApplicationController

  ## GET account/login
  def login_page
    if logged_in?
      flash[:notice] = "You're already logged in"
      redirect_to request.referer || root_path
    else
      render :login
    end
  end

  ## POST account/login
  def login
    respond_to do |format|
      format.json { api_login }
      format.html do
        if login_successful?
          redirect_to params[:dest] || root_path
        else
          flash[:login_message] = "Incorrect username or password"
        end
      end
    end
  end

  def logout
    respond_to do |format|
      format.html do
        @current_user = nil
        session.delete :current_user_id
        redirect_to root_path
      end
    end
  end


  private

  def login_successful?
    unix = unix_from_email(params[:username])
    if WsoTools::Auth.oit_auth?(unix, params[:password])
      set_current_user_from_unix_id(unix)
      true
    else
      false
    end
  end

  def json_login
    if WsoTools::Auth.oit_auth?(unix, params[:password])
      if user.api_key
        if !user.api_key.expired?
          # user's api key is still good -- no need to make a new one
          set_current_user_from_unix_id(unix)
          render json: {
            success: true,
            message: 'user already has api key',
            api_key: user.api_key,
            user: user
          }
          return
        else
          # user's api key is stale -- destroy the old one, make a new one
          user.api_key.destroy!
        end
      end

      # make a new api key (either no api_key, or api_key expired )
      api_key = ApiKey.new(user: user)
      if api_key.save && user.save
        set_current_user_from_unix_id(unix)
        render json: {
          success: true,
          message: 'created api key',
          status: :created_api_key,
          api_key: api_key,
          user: user
        }
        return
      else
        # could not save API key -- weird error -- shouldn't ever happen
        render json: {
          success: false,
          message: 'could not save api key'
        }
        return
      end

    else
      # Invalid password -- could not login
      render json: {
        success: false,
        message: 'Invalid password',
        status: :invalid_password
      }
      return
    end
  end

end
