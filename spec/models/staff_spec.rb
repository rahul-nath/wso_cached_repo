require 'rails_helper'

RSpec.describe Staff do

  context ".room_string" do
    let!(:office) { Fabricate(:office, number: "Platform 934") }
    let!(:staff) { Fabricate(:staff, office: office) }

    it "returns office info" do
      expect(staff.room_string).to eq("Platform 934")
    end
  end
end
