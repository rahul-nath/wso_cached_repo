require 'rails_helper'

RSpec.describe ApplicationController do

  # This is a dummy controller because we need to test private
  # methods. This allows us to test the ensure_x type methods by
  # creating simple methods that are blocked by a corresponding ensure_x.
  # ie, #test_ensure_x tests the filter #ensure_x, which tests the one
  # in ApplicationController since we aren't overriding them
  controller(ApplicationController) do
    # Need to metaprogram this away
    before_filter :ensure_user, only: :test_ensure_user
    before_filter :ensure_campus_or_at_williams, only: :test_ensure_campus_or_at_williams
    before_filter :ensure_on_campus, only: :test_ensure_on_campus
    before_filter :ensure_at_williams, only: :test_ensure_at_williams
    before_filter :ensure_student, only: :test_ensure_student
    before_filter :ensure_admin, only: :test_ensure_admin
    before_filter :ensure_dormtrak_policy_acceptance, only: :test_ensure_dormtrak_policy_acceptance

    def test_ensure_user
      render :text => "OK"
    end

    def test_ensure_campus_or_at_williams
      render :text => "OK"
    end

    def test_ensure_on_campus
      render :text => "OK"
    end

    def test_ensure_at_williams
      render :text => "OK"
    end

    def test_ensure_student
      render :text => "OK"
    end

    def test_ensure_admin
      render :text => "OK"
    end

    def test_ensure_dormtrak_policy_acceptance
      render :text => "OK"
    end

    def test_login_first
      login_first
    end

    def test_forbidden
      forbidden("reason")
    end
  end

  before(:each) do
    # This will automatically create the routes for each of the
    # methods defined in the anonymous controller above
    # This is horrifying
    all_routes = controller.class.instance_methods(false).map do |action|
      "get \"#{action}\" => \"anonymous##{action}\""
    end.join("; ")
    routes.draw { eval(all_routes) }
  end


  shared_examples_for "not login filtered" do
    it "does not redirect" do
      expect(subject).not_to redirect_to account_login_path
    end

    it "renders text" do
      expect(subject.body).to eq("OK")
    end
  end

  shared_examples_for "login filtered" do
    it "redirects to login" do
      expect(subject.redirect_url).to match(account_login_path)
    end

    it "does not render text" do
      expect(subject.body).not_to eq("OK")
    end
  end


  shared_examples_for "redirect filtered" do
    it "redirects to root" do
      expect(subject).to redirect_to root_path
    end

    it "does not render text" do
      expect(subject.body).not_to eq("OK")
    end
  end

  shared_examples_for "not redirect filtered" do
    it "redirects to root" do
      expect(subject).not_to redirect_to root_path
    end

    it "renders text" do
      expect(subject.body).to eq("OK")
    end
  end


  describe "#ensure_user" do
    subject { get :test_ensure_user}

    context "when logged in" do
      include_context "user"
      it_behaves_like "not login filtered"
    end

    context "when not logged in" do
      it_behaves_like "login filtered"
    end
  end

  describe "#ensure_campus_or_at_williams" do
    subject { get :test_ensure_campus_or_at_williams }

    context "when on campus AND at williams" do
      include_context "on campus and at williams"
      it_behaves_like "not login filtered"
    end

    context "when just on campus" do
      include_context "on campus"
      it_behaves_like "not login filtered"
    end

    context "when just at williams" do
      include_context "at williams"
      it_behaves_like "not login filtered"
    end

    context "when neither on campus nor at williams" do
      it_behaves_like "login filtered"
    end
  end

  describe "#ensure_on_campus" do
    subject { get :test_ensure_on_campus }

    context "when on campus" do
      include_context "on campus"
      it_behaves_like "not redirect filtered"
    end

    context "when not at williams" do
      it_behaves_like "redirect filtered"
    end
  end

  describe "#ensure_at_williams" do
    subject { get :test_ensure_at_williams}

    context "when at williams" do
      include_context "at williams"
      it_behaves_like "not redirect filtered"
    end

    context "when not at williams" do
      it_behaves_like "redirect filtered"
    end
  end

  describe "#ensure_student" do
    subject { get :test_ensure_student }

    context "as a student" do
      include_context "student"
      it_behaves_like "not redirect filtered"
    end

    [:professor, :alum, :staff].each do |user_type|
      context "as a #{user_type}" do
        include_context "#{user_type}"
        it_behaves_like "redirect filtered"
      end
    end

    context "as a guest" do
      it_behaves_like "redirect filtered"
    end
  end

  describe "#ensure_admin" do
    subject { get :test_ensure_admin }

    context "when admin" do
      include_context "admin"
      it_behaves_like "not redirect filtered"
    end

    context "when not admin" do
      include_context "user"
      it_behaves_like "redirect filtered"
    end

    context "when guest" do
      it_behaves_like "redirect filtered"
    end
  end

  describe "#ensure_dormtrak_policy_acceptance" do
    subject { get :test_ensure_dormtrak_policy_acceptance }

    context "when user has accepted dormtrak policy" do
      include_context "user who has accepted dormtrak policy"

      it "does not render the dormtrak policy" do
        expect(subject).not_to render_template("dormtrak/policy")
      end

      it "renders OK" do
        expect(subject.body).to eq("OK")
      end
    end

    context "when user has not accepted dormtrak policy" do
      include_context "user who has not accepted dormtrak policy"

      it "renders the dormtrak policy" do
        expect(subject).to render_template("dormtrak/policy")
      end
    end

    context "when guest" do
      # Need to think about what this should do
    end
  end

  describe "#login_first" do
    subject { get :test_login_first }
    it_behaves_like "login filtered" # in fact it defines it
  end

  describe "#forbidden" do
    subject { get :test_forbidden }
    it_behaves_like "redirect filtered" # and in fact defines it
  end
end
