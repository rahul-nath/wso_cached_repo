require 'rails_helper'

describe DormtrakReview do

  it "has a valid factory" do
    expect(Fabricate.build(:dormtrak_review)).to be_valid
  end

  [:user, :dorm_room].each do |owner|
    it "validates presence of #{owner}" do
      expect(Fabricate.build(:dormtrak_review, owner => nil)).not_to be_valid
    end
  end

  # Has to be separate because it pulls dorm from dorm room
  it "validates presence of dorm room" do
    review = Fabricate.build(:dormtrak_review)
    review.dorm_room = nil
    expect(review).not_to be_valid
  end

  let(:review) { Fabricate(:dormtrak_review) }

  context "#after_save" do
    it "calls .refresh" do
      expect(review).to receive(:refresh)
      review.save
    end
  end

  context "#after_destroy" do
    it "calls .refresh" do
      expect(review).to receive(:refresh)
      review.destroy      
    end    
  end

  context ".refresh" do
    it "refreshes dorm room" do
      expect(review.dorm_room).to receive(:refresh)
      review.send(:refresh)
    end

    it "refreshes dorm" do
      expect(review.dorm).to receive(:refresh)
      review.send(:refresh)
    end
  end

end