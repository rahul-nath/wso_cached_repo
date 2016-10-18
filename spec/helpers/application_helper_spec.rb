require 'rails_helper'

describe ApplicationHelper do
  
  def stub_current_user(user = nil)
    allow(helper).to receive(:current_user).and_return(user || Fabricate.build(:user))
  end

  def stub_request_ip(ip)
    allow_any_instance_of(ActionController::TestRequest).to receive(:remote_ip).and_return(ip)    
  end

  describe "logged_in?" do
    subject { helper.logged_in? }

    context "when current_user is nil" do
      it "returns false" do
        expect(subject).to be_falsy
      end
    end

    describe "when current_user is not nil" do      
      it "returns true" do
        stub_current_user
        expect(subject).to be_truthy
      end
    end
  end

  describe "on_campus?" do
    subject { helper.on_campus? }

    it "returns true if williams ip" do
      stub_request_ip("137.165.5.5")
      expect(subject).to be_truthy
    end

    it "returns false if not williams ip" do
      stub_request_ip("137.166.5.5")
      expect(subject).to be_falsy
    end
  end

  describe "student?" do
    subject { helper.student? }

    [:alum, :professor, :staff].each do |non_student_type|
      let(:user) { Fabricate.build(non_student_type) }

      it "should return false for explicit #{non_student_type}" do
        stub_current_user(user)
        expect(subject).to be_falsy
      end
    end

    context "when explicit Student type" do
      context "and student has graduated" do
        let(:student) { Fabricate.build(:student, class_year: Time.zone.now.year - 1) }

        it "returns false" do
          stub_current_user(student)          
          expect(subject).to be_falsy
        end
      end

      context "and student has not graduated" do
        let(:student) { Fabricate.build(:student, class_year: Student.senior_year) }
        
        it "returns true" do
          stub_current_user(student)
          expect(subject).to be_truthy
        end
      end
    end
  end

  describe "admin?" do
    subject { helper.admin? }

    context "when current_user is admin" do
      let(:admin) { Fabricate.build(:student, admin: true) }
      
      it "returns true" do
        stub_current_user(admin)
        expect(subject).to be_truthy
      end
    end

    context "when current_user not admin" do
      let(:user) { Fabricate.build(:user, admin: false) }
      
      it "returns false" do
        stub_current_user(user)
        expect(subject).to be_falsy
      end
    end
  end

  describe "set_current_user_from_unix_id" do
    context "when nonexistent unix" do
      before do
        helper.set_current_user_from_unix_id("abc123")
      end

      it "sets session[:current_user_id] to nil" do
        expect(session[:current_user_id]).to be_nil
      end

      it "causes current_user to be nil" do
        expect(helper.current_user).to be_nil
      end
    end

    context "when unix exists" do
      let(:user) { Fabricate(:user) }
      
      before do
        helper.set_current_user_from_unix_id(user.unix_id)
      end

      it "sets session[:current_user_id] to that user's id" do
        expect(session[:current_user_id]).to eq(user.id)
      end

      it "causes current_user to return the user" do
        expect(helper.current_user).to eq(user)
      end
    end
  end

  describe "unix_from_email" do
    context "when @williams.edu provided" do
      it "returns just unix" do
        email = "ml10@williams.edu"
        unix = helper.unix_from_email(email)
        expect(unix).to eq("ml10")
      end
    end

    context "when just unix" do
      it "returns just unix" do
        email = "ml10"
        unix = helper.unix_from_email(email)
        expect(unix).to eq("ml10")
      end      
    end
  end
end
