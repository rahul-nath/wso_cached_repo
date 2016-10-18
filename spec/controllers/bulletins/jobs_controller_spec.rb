require "rails_helper" 

describe Bulletins::JobsController do

  include_context "user"

  describe "#create" do
    it "redirects to new job" do
      post :create, job: { title: "test title", body: "test body" }
      expect(response.status).to eq(302)
      expect(response.redirect_url).to match("jobs/1")
    end

    it "creates a new job" do
      post :create, job: { title: "test title", body: "test body" }
      expect(Job.count).to eq(1)
    end

    # Simple test to see if we're verifying params
    # eg, don't want someone to be able to put a 
    # :offer field into an :announcement form in params
    context "when extra params passed" do
      let(:job_params) {
        {
          title: "Test Title",
          body: "Test Body",
          offer: true # Rides only
        }
      }

      it "filters them" do
        post :create, job: job_params
        expect(Job.first.offer).to be_nil
      end
    end
  end  

end