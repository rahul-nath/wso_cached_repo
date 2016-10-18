require "rails_helper" 

describe Bulletins::ExchangesController do

  include_context "user"

  describe "#create" do
    it "redirects to new exchange" do
      post :create, exchange: { title: "test title", body: "test body" }
      expect(response.status).to eq(302)
      expect(response.redirect_url).to match("exchanges/1")
    end

    it "creates a new exchange" do
      post :create, exchange: { title: "test title", body: "test body" }
      expect(Exchange.count).to eq(1)
    end

    # Simple test to see if we're verifying params
    # eg, don't want someone to be able to put a 
    # :offer field into an :announcement form in params
    context "when extra params passed" do
      let(:exchange_params) {
        {
          title: "Test Title",
          body: "Test Body",
          offer: true # Rides only
        }
      }

      it "filters them" do
        post :create, exchange: exchange_params
        expect(Exchange.first.offer).to be_nil
      end
    end
  end  

end