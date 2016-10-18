require 'rails_helper'

describe Alum do


  it "has a valid factory" do
    expect(Fabricate.build(:alum)).to be_valid
  end

  context "empty fields" do
    let(:alum) { Fabricate.build(:alum, unix_id: 'jarjarbinks') }
    
    it "replaces the email with unix id if none exists" do
      alum.update(williams_email: '')
      expect(alum.email).to eq("jarjarbinks@alumni.williams.edu")
    end
  end
end
