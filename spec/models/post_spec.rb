require 'rails_helper'

describe Post do

  it "has a valid factory" do
    expect(Fabricate.build(:post)).to be_valid
  end

  [:content].each do |thing|
    it "validates presence of #{thing}" do
      expect(Fabricate.build(:post, thing => nil)).not_to be_valid
    end
  end

  it "validates :deleted is a boolean" do
    expect(Fabricate.build(:post, deleted: "")).not_to be_valid
  end

end