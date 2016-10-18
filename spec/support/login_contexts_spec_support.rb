[:student, :professor, :staff, :alum].each do |user_type|
  shared_context "#{user_type}" do
    let(:user) { Fabricate(user_type) }

    before(:each) do
      allow(controller).to receive(:current_user).and_return(user)
    end
  end
end

shared_context "student who has not accepted factrak policy" do
  let(:user) { Fabricate(:student, has_accepted_factrak_policy: false) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
  end
end

shared_context "user" do
  let(:user) { Fabricate(:user) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
  end
end

shared_context "student who has accepted factrak policy" do
  let(:user) { Fabricate(:student, has_accepted_factrak_policy: true) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller.request).to receive(:referer).and_return(factrak_path)
  end
end

shared_context "senior" do
  let(:user) { Fabricate(:student, class_year: Time.now.month > 7 ? Time.now.year + 1 : Time.now.year) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
  end
end

shared_context "underclassman" do
  let(:user) { Fabricate(:student, class_year: Time.now.year - 1) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
  end
end

shared_context "factrak admin" do
  let(:admin) { Fabricate(:student,
                          has_accepted_factrak_policy: true,
                          factrak_admin: true) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(admin)
  end
end

shared_context "admin" do
  let(:user) { Fabricate(:user, admin: true) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
  end
end

shared_context "at williams" do
  include_context "user"

  before(:each) do
    allow(controller).to receive(:at_williams?).and_return(true)
  end
end

shared_context "on campus" do
  before(:each) do
    allow(controller).to receive(:on_campus?).and_return(true)
  end
end

shared_context "on campus and at williams" do
  include_context "user"

  before(:each) do
    allow(controller).to receive(:at_williams?).and_return(true)
    allow(controller).to receive(:on_campus?).and_return(true)    
  end
end

shared_context "off campus" do
  before(:each) do
    controller.stub(:on_campus?) { false }
  end
end

shared_context "off campus guest" do
  before(:each) do
    controller.stub(:on_campus?) { false }
  end
end

shared_context "user who has accepted dormtrak policy" do
  let(:user) { Fabricate(:user, has_accepted_dormtrak_policy: true) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
  end
end

shared_context "user who has not accepted dormtrak policy" do
  let(:user) { Fabricate(:user, has_accepted_dormtrak_policy: false) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
  end
end
