require "rails_helper"

describe Announcement do

  it "has a valid factory" do
    expect(Fabricate.build(:announcement)).to be_valid
  end

  describe "#alive scope" do
    # Ones whose start date is in the past/present
    3.times do |i|
      Timecop.freeze(Date.today - i.days) do
        Fabricate(:announcement, start_date: nil)
      end
    end

    # Start date in the future
    let!(:future) { Fabricate(:announcement, start_date: Date.tomorrow) }

    it "does not include announcements whose start_date is in the future" do
      expect(Announcement.alive).not_to include(future)
    end

    it "will include it at that time" do
      travel_to future.start_date do
        expect(Announcement.alive).to include(future)
      end
    end

    let!(:alive) { Announcement.alive }


    it "orders such that newer start_dates are earlier" do
      (0..alive.size - 2).each do |i|        
        expect(alive[i].start_date).to be >= alive[i+1].start_date
      end
    end
  end

end
