require "rails_helper"

RSpec.describe AccountController do

  context "get login[_page]" do
    it "has a 200 status code" do
      get :login_page
      expect(response.status).to eq(200)
    end

    it "renders login page" do
      get :login_page
      expect(response).to render_template(:login)
    end
  end

  let(:unix) { "ml10" }
  let!(:user) { Fabricate(:user, unix_id: unix)}
  let(:pass) { "pass" }
  let(:wrongpass) { "wrongpass" }

  context "get login" do
    before(:each) do
      #WsoTools::Auth.stub(:oit_auth?).with(unix, pass) { true }
      allow(WsoTools::Auth).to receive(:oit_auth?).with(unix, pass).and_return(true)
      #WsoTools::Auth.stub(:oit_auth?).with(unix, wrongpass) { false }
      allow(WsoTools::Auth).to receive(:oit_auth?).with(unix, wrongpass).and_return(false)
    end

    context "when correct password" do
      it "sets current_user to correct user" do
        get :login, username: unix,  password: pass
        expect(assigns(:current_user)).to eq(user)
      end
    end

    context "when wrong password" do
      it "does not set current_user" do
        get :login, username: unix, password: wrongpass
        expect(assigns(:current_user)).to be_nil
      end
    end
  end

  context "get logout" do
    before(:each) do
      get :login, username: unix, password: pass
    end

    it "sets current_user to nil" do
      get :logout
      expect(assigns(:current_user)).to be_nil
    end
  end
end
