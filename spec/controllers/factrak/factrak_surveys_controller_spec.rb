require 'rails_helper'

RSpec.describe Factrak::FactrakSurveysController do
  it_behaves_like "factrak restricted"

  context "student who has accepted factrak policy" do
    include_context "student who has accepted factrak policy"

    describe "#index" do
    end

    describe "#create" do
      let!(:prof) { Fabricate(:professor) }
      let!(:csci) { Fabricate(:area_of_study, abbrev: "CSCI") }
      let(:form) do
        { comment: "a"*100, professor_id: prof.id }
      end

      context "dept abbrev omitted" do
        it "does not create a survey" do
          before_count = FactrakSurvey.count
          post :create, format: :js, factrak_survey: form.merge(aos_abbrev: "", course_num: "101")
          expect(FactrakSurvey.count).to eq(before_count)
        end
      end

      context "course num omitted" do
        it "does not create a survey" do
          before_count = FactrakSurvey.count
          post :create, format: :js, factrak_survey: form.merge(aos_abbrev: "CSCI", course_num: "")
          expect(FactrakSurvey.count).to eq(before_count)          
        end       
      end

      context "course num and dept abbrev omitted" do
        it "does not create a survey" do
          before_count = FactrakSurvey.count
          post :create, format: :js, factrak_survey: form.merge(aos_abbrev: "", course_num: "")
          expect(FactrakSurvey.count).to eq(before_count)          
        end        
      end

      context "course num and dept abbrev present" do
        it "does create a survey" do
          before_count = FactrakSurvey.count
          post :create, format: :js, factrak_survey: form.merge(aos_abbrev: "CSCI", course_num: "101")
          expect(FactrakSurvey.count).to eq(before_count + 1)          
        end           
      end
    end

    describe "#edit" do
      context "when current user is owner" do
      end

      context "when current user is admin" do
      end

      context "when current user is not owner" do
        # should render 403
      end
    end

    describe "#update" do
      it "should change the right survey" do
      end

      it "should require proper permission" do
      end
    end

    describe "#delete" do
      it "should decrement factrak_surveys.count" do
      end

      it "should delete the right survey" do
      end

      it "should require proper permission" do
      end
    end
  end
end
