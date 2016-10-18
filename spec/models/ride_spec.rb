require "rails_helper"

describe Ride do

  it "has a valid factory" do
    expect(Fabricate(:ride)).to be_valid
  end

  it "validates source presence" do
    expect(Fabricate.build(:ride, source: "")).not_to be_valid
    expect(Fabricate.build(:ride, source: nil)).not_to be_valid
  end

  it "validates dest presence" do
    expect(Fabricate.build(:ride, destination: "")).not_to be_valid
    expect(Fabricate.build(:ride, destination: nil)).not_to be_valid
  end

  it "validates start_date presence" do
    expect(Fabricate.build(:ride, start_date: nil)).not_to be_valid
  end

  it "validates offer presence" do
    expect(Fabricate.build(:ride, offer: nil)).not_to be_valid
  end

  describe ".set_title" do
    it "sets title to Source to Dest (Kind)" do
      ride = Fabricate.build(:ride, title: nil)
      ride.save
      kind = ride.offer? ? "Offer" : "Request"
      expect(ride.title).to eq("#{ride.source} to #{ride.destination} (#{kind})")
    end
  end

  # Rides that have ended
  (1..3).each do |i|
    Timecop.freeze(Date.today - i.days) do
      past_date = Date.today
      Fabricate(:ride, start_date: past_date)
    end
  end

  # Rides that have present/future start dates
  [1, 0, 2, 0].each do |i|
    Fabricate(:ride, start_date: Date.today + i.days)
  end

  describe "#alive scope" do
    let!(:alive) { Ride.alive }

    it "includes all and only rides with start date >= today" do
      Ride.where("start_date >= ?", Date.today).each do |ride|
        expect(alive).to include(ride)
      end
    end

    it "orders st imminent rides are first" do
      (0..alive.size - 2).each do |i|
        expect(alive[i].start_date).to be <= alive[i+1].start_date
      end
    end
  end

end