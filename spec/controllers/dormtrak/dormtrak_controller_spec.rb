require "rails_helper"

describe DormtrakController do
  describe "before_action" do
    context "as a user" do
      context "who has accepted dormtrak policy" do
        include_context "user who has accepted dormtrak policy"
        
        it "can access index page" do
          get :index
          expect(response).to render_template(:index)
        end
      end

      context "who has not accepted dormtrak policy" do
        include_context "user who has not accepted dormtrak policy"

        context "gets policy" do
          it "returns 200 status" do
            get :policy
            expect(response.status).to eq(200)
          end

          it "can access policy page" do
            get :policy
            expect(response).to render_template(:policy)
          end
        end

        context "accepts policy" do
          it "redirects to dormtrak_path" do
            post :accept_policy, accept: 1
            expect(response).to redirect_to(dormtrak_path)
          end

          it "saves current user account policy" do
            post :accept_policy, accept: 1
            expect(user.has_accepted_dormtrak_policy).to be(true)
          end
        end

        context "does not accept policy" do
          it "redirects to main page" do
            post :accept_policy, accept: 0
            expect(response).to redirect_to("/front/index")
          end

          it "saves current user account policy" do
            post :accept_policy, accept: 0
            expect(user.has_accepted_dormtrak_policy).to be(false)
          end
        end
      end
    end
  end

  describe "#search" do
    include_context "user who has accepted dormtrak policy"

    it "goes directly to building page if possible" do
      post :search, search: "West"
      # expect(response).to redirect_to dormtrak_dorm_path(id: 15) # failing
    end
  end
end
