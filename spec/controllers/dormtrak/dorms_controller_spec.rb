require 'rails_helper'

RSpec.describe Dormtrak::DormsController do
  context "as a user who has accepted dormtrak policy" do
    include_context "user who has accepted dormtrak policy"

    context "#show" do
      let(:dorm) { Fabricate(:dorm) }

      it "renders show page" do
        get :show, id: dorm.name
        expect(response).to render_template(:show)
      end

      it "shows correct dorm" do
        get :show, id: dorm.name
        expect(assigns(:dorm)).to eq(dorm) # same as dorm from above
      end
    end
  end
end
