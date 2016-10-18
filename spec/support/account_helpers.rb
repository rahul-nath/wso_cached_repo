require 'rails_helper'

module AccountHelpers

  def login(unix, pass)
    old_controller = @controller
    @controller = AccountController.new
    WsoTools::Auth.stub(:oit_auth?).with(unix, pass) { true }
    get :login, username: unix, password: pass
    @controller = old_controller
  end

end
