require 'rails_helper'

RSpec.describe Factrak::FactrakAgreementsController do
  it_behaves_like "factrak restricted"

  describe "#new" do
    include_context "student who has accepted factrak policy"

    let(:survey) { Fabricate(:factrak_survey) }

    context "and user agrees" do
      before(:each) do
        post :create, format: :js, factrak_survey_id: survey.id, agrees: 1
      end

      it "increments agree count" do
        agrees = survey.agreements.select { |a| a.agrees? }.size
        expect(agrees).to eq(1)
      end

      it "does not increment disagree count" do
        disagrees = survey.agreements.select { |a| !a.agrees? }.size
        expect(disagrees).to eq(0)
      end
    end

    context "and user disagrees" do
      before(:each) do
        post :create, format: :js, factrak_survey_id: survey.id, agrees: 0
      end

      it "does not increment agree count" do
        agrees = survey.agreements.select { |a| a.agrees? }.size
        expect(agrees).to eq(0)
      end

      it "increments disagree count" do
        disagrees = survey.agreements.select { |a| !a.agrees? }.size
        expect(disagrees).to eq(1)
      end
    end

    context "and user changes from agree to disagree" do
      before(:each) do
        post :create, format: :js, factrak_survey_id: survey.id, agrees: 1
        post :create, format: :js, factrak_survey_id: survey.id, agrees: 0
      end

      it "should decrement agrees" do
        agrees = survey.agreements.select { |a| a.agrees? }.size
        expect(agrees).to eq(0)
      end

      it "should increment disagrees" do
        disagrees = survey.agreements.select { |a| !a.agrees? }.size
        expect(disagrees).to eq(1)
      end

      it "should not create a new agreement" do
        expect(FactrakAgreement.count).to eq(1)
      end
    end

    context "and user changes from disagree to agree" do
      before(:each) do
        post :create, format: :js, factrak_survey_id: survey.id, agrees: 0
        post :create, format: :js, factrak_survey_id: survey.id, agrees: 1
      end

      it "should increment agrees" do
        agrees = survey.agreements.select { |a| a.agrees? }.size
        expect(agrees).to eq(1)
      end

      it "should decrement disagrees" do
        disagrees = survey.agreements.select { |a| !a.agrees? }.size
        expect(disagrees).to eq(0)
      end
    end
  end
end
