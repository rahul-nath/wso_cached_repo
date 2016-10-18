require "rails_helper" 

describe Bulletins::LostFoundsController do

  include_context "user"

  describe "#create" do
    it "redirects to new lost_found" do
      post :create, lost_found: { title: "test title", body: "test body" }
      expect(response.status).to eq(302)
      expect(response.redirect_url).to match("lost_and_found/1")
    end

    it "creates a new lost_found" do
      post :create, lost_found: { title: "test title", body: "test body" }
      expect(LostFound.count).to eq(1)
    end

    # Simple test to see if we're verifying params
    # eg, don't want someone to be able to put a 
    # :offer field into an :announcement form in params
    context "when extra params passed" do
      let(:lost_found_params) {
        {
          title: "Test Title",
          body: "Test Body",
          offer: true # Rides only
        }
      }

      it "filters them" do
        post :create, lost_found: lost_found_params
        expect(LostFound.first.offer).to be_nil
      end
    end
  end  

end