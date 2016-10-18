require 'rails_helper'

RSpec.describe Dormtrak::DormtrakReviewsController do
  context "as a user who has accepted dormtrak policy" do
    include_context "user who has accepted dormtrak policy"

    context "#create" do
      let(:review) { Fabricate(:dormtrak_review) }

      it "creates a dormtrak review" do
        before_count = DormtrakReview.count
        post :create, params: review.attributes
        expect(DormtrakReview.count).to eq(before_count+1)
      end
    end

    pending "and already created a review" do
      let(:review) { Fabricate(:dormtrak_review) }

      before do
        post :create, params: review.attributes
      end

      context "#update" do
        complaint = "my neighbors are always playing music"

        before do
          review.noise = complaint
        end

        it "keeps the same number of total reviews" do
          before_count = DormtrakReview.count
          put :update, dormtrak_review: review
          expect(DormtrakReview.count).to eq(before_count)
        end

        it "updates the appropriate field" do
        end
      end

      context "#destroy" do
        it "decrements the review count" do
          before_count = DormtrakReview.count
          post :destroy, dormtrak_review: review
          expect(DormtrakReview.count).to eq(before_count-1)
        end

        it "deletes the right review" do
        end
      end
    end
  end
end
