require 'rails_helper'

describe Professor do

  it "has a valid factory" do
    expect(Fabricate.build(:professor)).to be_valid
  end

  context ".room_string" do
    let!(:office) { Fabricate(:office, number: "Platform 934") }
    let!(:prof) { Fabricate(:professor, office: office) }

    it "returns office info" do
      expect(prof.room_string).to eq("Platform 934")
    end
  end
end
