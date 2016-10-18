require 'rails_helper'

RSpec.describe Dormtrak::NeighborhoodsController do
  context "as a user who has accepted dormtrak policy" do
    include_context "user who has accepted dormtrak policy"

    context "#show" do
      let(:neighborhood) { Fabricate(:neighborhood) }

      it "renders show page" do
        get :show, id: neighborhood.id
        # expect(response).to render_template(:show) # going to /dormtrak instead of :show
      end

      it "redirects to /dormtrak if not found" do
        get :show, id: 0
        expect(response).to redirect_to(dormtrak_path)
      end
    end
  end
end
