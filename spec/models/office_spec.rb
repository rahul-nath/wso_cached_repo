require 'rails_helper'

describe Office do
  it "validates uniqueness" do
    Fabricate(:office, number: "Bob 123")
    expect(Fabricate.build(:office, number: "Bob 123")).not_to be_valid
  end
end
