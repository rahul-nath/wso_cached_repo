require "rails_helper"

feature "Login" do

  before(:each) do
    visit account_login_path
  end

  context "with existing account" do
    let(:user)           { Fabricate(:student) }
    let(:pass)           { "doesntmatter" }
    let(:incorrect_pass) { "wrongpass" }

    before(:each) do
      allow(WsoTools::Auth).to receive(:oit_auth?).with(user.unix_id, pass).and_return(true)
      allow(WsoTools::Auth).to receive(:oit_auth?).with(user.unix_id, incorrect_pass).and_return(false)
    end

    context "and valid password" do
      before(:each) { fill_login(user.unix_id, pass) }

      it "redirects to index" do
        expect(current_path).to eq(root_path)
      end

      it "has logout link" do
        expect(page).to have_link("Logout")
      end
    end

    context "and wrong password" do
      before(:each) { fill_login(user.unix_id, incorrect_pass) }

      it "stays on login page" do
        expect(current_path).to eq("/account/login")
      end

      it "flashes error message" do
        expect(page).to have_content("Incorrect username or password")
      end
    end
  end

  context "with current OIT unix not yet in db" do
    let(:unix) { "ml10" }
    let(:pass) { "beepboop" }

    before(:each) do
      allow(User).to receive(:ldap_lookup).with(unix).and_return(
        [{
          :unix_id => "ml10",
          :name => "Matthew LaRose",
          :williams_email => "matthew.larose@williams.edu",
          :class_year => 2016,
          :visible => true
        }]
      )
    end

    context "with valid password" do
      before(:each) do
        WsoTools::Auth.stub(:oit_auth?).with(unix, pass) { true }
        fill_login(unix, pass)
      end

      it "redirects to index" do
        expect(current_path).to eq(root_path)
      end

      it "has logout link" do
        expect(page).to have_link("Logout")
      end
    end

    context "with wrong password" do
      before(:each) do
        WsoTools::Auth.stub(:oit_auth?).with(unix, "wrong") { false }
        fill_login(unix, "wrong")
      end

      it "stays on login page" do
        current_path.should eq("/account/login")
      end

      it "flashes error message" do
        expect(page).to have_content("Incorrect username or password")
      end
    end
  end

  context "with invalid unix" do
    let(:unix) { "catdog" }
    let(:pass) { "winslowsucks" }

    before(:each) do
      WsoTools::Auth.stub(:oit_auth?).with(unix, pass) { false }
      fill_login(unix, pass)
    end

    it "stays on login page" do
      current_path.should eq("/account/login")
    end

    it "flashes error message" do
      expect(page).to have_content("Incorrect username or password")
    end
  end

  context "when already logged in" do
    before(:each) do
      user = Fabricate(:student)
      login(user)
      visit account_login_path
    end

    it "renders already_logged_in page" do
      expect(page).to have_content("already logged in")
    end
  end
end


feature "Logout" do

  before do
    user = Fabricate(:student)
    login(user)
  end

  context "when user clicks logout link" do
    before { click_link "Logout" }

    it "page shows login link" do
      expect(page).to have_link("Login")
    end

    it "redirects to index" do
      expect(current_path).to eq(root_path)
    end
  end
end
