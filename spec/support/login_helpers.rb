require 'rails_helper'

module LoginHelpers
  def login(user)
    visit account_login_path
    fill_login(user.unix_id)
  end

  def fill_login(username, password = "doesntmatter")
    fill_in "username", :with => username
    fill_in "password", :with => password
    click_button "Login"
  end

  def logout
    click_link "Logout"
  end
end
