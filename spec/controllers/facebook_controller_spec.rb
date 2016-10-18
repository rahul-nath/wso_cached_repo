require 'rails_helper'

RSpec.describe FacebookController do

  context "#index" do
    context "when not logged in" do
      # can't think of anything right now to test
      # for when on campus. it should just...er...work

      context "when not on campus" do
        include_context "off campus guest"

        it "should redirect to login" do
          get :index
          expect(response.redirect_url).to match account_login_path
        end
      end
    end
  end

  # Test filtering. Both equivalent at the moment,
  # since they just serve static pages
  [:edit, :help].each do |action|
    context "##{action}" do
      context "when logged in" do
        include_context "user"
        # Again need to think of something to test
      end

      context "when not logged in" do
        it "redirects to login" do
          get action
          expect(response.redirect_url).to match account_login_path
        end
      end
    end
  end
end
