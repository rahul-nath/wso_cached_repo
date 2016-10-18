require "rails_helper"

describe Bulletins::AnnouncementsController do

  include_context "user"

  describe "#create" do
    it "redirects to new announcement" do
      post :create, announcement: { title: "test title", body: "test body" }
      expect(response.status).to eq(302)
      expect(response.redirect_url).to match("announcements/1")
    end

    ["%b %d", "%m/%d", "%b/%d"].each do |format|
      let!(:announcement_params) { 
        { 
           start_date: Date.today.strftime(format),
           title: "Test Title",
           body: "Test Body" 
        }
      }
      
      context "when date format #{format}" do
        it "creates new announcement" do
          expect { post :create, announcement: announcement_params }
            .to change{ Announcement.count }.by(1)
        end

        it "createst announcement with correct date" do
          post :create, announcement: announcement_params
          expect(Announcement.first.start_date.to_date).to eq(Date.today)
        end
      end
    end


    # Simple test to see if we're verifying params
    # eg, don't want someone to be able to put a 
    # :offer field into an :announcement form in params
    context "when extra params passed" do
      let(:announcement_params) {
        {
          title: "Test Title",
          body: "Test Body",
          offer: true # Rides only
        }
      }

      it "filters them" do
        post :create, announcement: announcement_params
        expect(Announcement.first.offer).to be_nil
      end
    end
  end

end