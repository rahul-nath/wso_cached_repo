require "rails_helper" 

describe Bulletins::RidesController do

  def most_recent
    Ride.order("id DESC").first
  end

  include_context "user"

  describe "#create" do
    let(:ride_params) { 
      {
        body: "test body",
        offer: 1,
        source: "Williamstown",
        destination: "New York",
        start_date: Date.today.strftime("%b %d")
      }
    }

    it "redirects to new exchange" do
      post :create, ride: ride_params
      expect(response.status).to eq(302)
      expect(response.redirect_url).to match("rides/1")
    end

    it "creates a new ride" do
      post :create, ride: ride_params
      expect(Ride.count).to eq(1)
    end

    context "offer is false" do
      ["0", 0, "false"].each do |f|
        let(:ride_params) { 
          {
            body: "test body",
            offer: f,
            source: "Williamstown",
            destination: "New York",
            start_date: Date.today.strftime("%b %d")
          }
        }

        it "creates request ride" do
          post :create, ride: ride_params
          expect(most_recent.offer).to be_falsy
        end
      end
    end

    context "offer is true" do
      ["1", 1, "true"].each do |t|
        let(:ride_params) { 
          {
            body: "test body",
            offer: t,
            source: "Williamstown",
            destination: "New York",
            start_date: Date.today.strftime("%b %d")
          }
        }

        it "creates offer ride" do
          post :create, ride: ride_params
          expect(most_recent.offer).to be_truthy
        end
      end
    end
  end  
end
