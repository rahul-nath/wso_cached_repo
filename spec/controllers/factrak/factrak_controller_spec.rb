require "rails_helper"

RSpec.describe FactrakController do

  it_behaves_like "factrak restricted" # support/factrak_restricted_spec.rb

  context "as a student" do
    context "who has accepted factrak policy" do
      include_context "student who has accepted factrak policy"

      it "cannot moderate" do
        get :moderate
        expect(response).to redirect_to factrak_path
      end

      it "can access index page" do
        get :index
        expect(response).to render_template(:index)
      end

      it "can flag reviews" do
        survey = Fabricate(:factrak_survey)
        post :flag, format: :js, id: survey.id
        # fuck you rspec
        expect(FactrakSurvey.find(survey.id).flagged?).to be_truthy
      end

      it "cannot unflag reviews" do
        survey = Fabricate(:factrak_survey)
        post :flag, format: :js, id: survey.id
        post :unflag, format: :js, id: survey.id
        expect(FactrakSurvey.find(survey.id).flagged?).to be_truthy
      end
    end

    context "who has not accepted factrak policy" do
      include_context "student who has not accepted factrak policy"

      context "get policy" do
        it "returns 200 status" do
          get :policy
          expect(response.status).to eq(200)
        end

        it "can access page" do
          get :policy
          expect(response).to render_template(:policy)
        end

        it "cannot flag reviews" do
          post :flag, format: :js, id: 1
          expect(response).to redirect_to factrak_policy_path
        end

        it "cannot unflag reviews" do
          post :unflag, format: :js, id: 1
          expect(response).to redirect_to factrak_policy_path
        end
      end

      context "post accept_policy" do
        context "when accept" do
          it "redirects to factrak index" do
            post :accept_policy, accept: 1
            expect(response).to redirect_to(factrak_path)
          end

          it "saves current user accept policy" do
            post :accept_policy, accept: 1
            expect(user.has_accepted_factrak_policy).to be(true)
          end
        end

        context "when reject" do
          it "redirects to root" do
            post :accept_policy, accept: 0
            expect(response).to redirect_to root_path
          end

          it "saves current user accept policy" do
            post :accept_policy, accept: 0
            expect(user.has_accepted_factrak_policy).to be(false)
          end
        end
      end
    end
  end

  context "as an admin" do
    include_context "factrak admin"

    describe "moderate" do
      it "can access" do
        get :moderate
        expect(response).to render_template(:moderate)
      end

      it "sets @flagged" do
        get :moderate
        expect(assigns(:flagged)).not_to be_nil
      end
    end

    it "can unflag reviews" do
      survey = Fabricate(:factrak_survey)
      post :flag, format: :js, id: survey.id
      post :unflag, format: :js, id: survey.id
      expect(FactrakSurvey.find(survey.id).flagged?).to be_falsy
    end
  end

  describe "autocomplete methods" do
    include_context "student who has accepted factrak policy"

    describe "#autocomplete" do
      (1..3).each { |i| let!("john#{i}") { Fabricate(:professor, name: "John Last#{i}") } }
      let(:johns) { [john1, john2, john3] }
      3.times { |i| let!("bob#{i}") { Fabricate(:professor, name: "Bob Last#{i}") } }

      it "returns 200 status" do
        get :autocomplete, q: "john", format: :json
        expect(response.status).to eq(200)
      end

      it "returns correct result for profs" do
        get :autocomplete, q: "john", format: :json
        expect(JSON.parse(response.body)).to match_array(JSON.parse(johns.to_json))
      end

      let!(:econ) { Fabricate(:area_of_study, abbrev: "ECON") }
      (1..3).each { |i| let!("econ#{i}") { Fabricate(:course,
                                                       number: i,
                                                       area_of_study: econ) } }
      let!(:econ_courses) { [econ1, econ2, econ3].map { |c| { :title => c.to_s, :id => c.id} } }
      let!(:csci) { Fabricate(:area_of_study, abbrev: "CSCI") }
      (1..3).each { |i| let!("csci#{i}") { Fabricate(:course,
                                                       number: i,
                                                       area_of_study: csci) } }
      let!(:csci_courses) { [csci1, csci2, csci3].map { |c| { :title => c.to_s, :id => c.id} } }

      it "returns correct result for courses" do
        get :autocomplete, q: "csci", format: :json
        expect(JSON.parse(response.body)).to match_array(JSON.parse(csci_courses.to_json))
      end
    end

    describe "#find_depts_autocomplete" do
      let!(:econ) { Fabricate(:area_of_study, abbrev: "ECON") }
      let!(:csci) { Fabricate(:area_of_study, abbrev: "CSCI") }

      it "returns 200 status" do
        get :find_depts_autocomplete, format: :json
        expect(response.status).to eq(200)
      end

      it "returns correct result(s)" do
        get :find_depts_autocomplete, q: "c", format: :json
        expect(JSON.parse(response.body)).to match_array(["CSCI"])
      end
    end
  end


end
