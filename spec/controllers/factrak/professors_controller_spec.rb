require 'rails_helper'

RSpec.describe Factrak::ProfessorsController do
  it_behaves_like "factrak restricted"

  context "student who has accepted factrak policy" do
    include_context "student who has accepted factrak policy"

    context "get show" do
      let!(:prof) { Fabricate(:professor) }

      it "should return 200" do
        get :show, id: prof.id
        expect(response.status).to eq(200)
      end

      it "should set @prof" do
        get :show, id: prof.id
        expect(assigns(:prof)).not_to be_nil
      end

      it "finds prof's comments" do
        get :show, id: prof.id
        expect(assigns(:comments)).to eq(prof.surveys.commented)
      end

      it "prepares new survey" do
        get :show, id: prof.id
        expect(assigns(:survey)).not_to be_nil
      end
    end
  end
end
