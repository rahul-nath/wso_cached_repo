require 'rails_helper'

describe Bulletin do

  it "has a valid factory" do
    expect(Fabricate.build(:bulletin)).to be_valid
  end

  it "validates presence of user" do
    expect(Fabricate.build(:bulletin, user: nil)).not_to be_valid
  end

  it "validates non-blank title" do
    expect(Fabricate.build(:bulletin, title: nil)).not_to be_valid
  end

  describe ".normalize_start_date" do
    context "when start date specified is in the past" do
      let(:past_date) { (Date.today - 1.day).strftime("%b %d") }

      it "sets the start_date to 1 year past the specified date" do
        bulletin = Fabricate(:bulletin, start_date: past_date)
        expect(bulletin.start_date.year).to eq(Time.now.year + 1)
      end
    end

    context "when start date not specified" do
      let(:bulletin) { Fabricate(:bulletin, start_date: nil) }
      
      it "sets start_date to be today" do
        expect(bulletin.start_date.to_date).to eq(Date.today)
      end
    end
  end
end
