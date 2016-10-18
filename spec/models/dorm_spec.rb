require 'rails_helper'

describe Dorm do
  
  it "validates presence of neighborhood" do
    expect(Fabricate.build(:dorm, neighborhood: nil)).not_to be_valid
  end

  let!(:dorm) { Fabricate(:dorm) }
  let!(:doubles) { Fabricate.times(5, :dorm_room, dorm: dorm, capacity: 2) }
  let!(:ds_2) { Fabricate.times(5, :dorm_room, dorm: Fabricate(:dorm), capacity: 2) }
  let!(:singles) { Fabricate.times(5, :dorm_room, dorm: dorm, capacity: 1) }
  let!(:ss_2) { Fabricate.times(5, :dorm_room, dorm: Fabricate(:dorm), capacity: 1) }

  context ".doubles" do
    it "returns all and only its doubles" do
      expect(dorm.doubles).to eq(doubles)
    end
  end

  context ".singles" do
    it "returns all and only its singles" do
      expect(dorm.singles).to eq(singles)
    end
  end

  context ".capacity" do
    let!(:dood) { Fabricate(:dorm, number_singles: 1, number_doubles: 1) }

    it "is set automatically" do
      expect(dood.capacity).to eq(3)
      dood.update(number_doubles: 2)
      expect(dood.capacity).to eq(5)
    end
  end

  context ".recent_reviews" do
    let!(:r1) { Fabricate(:dormtrak_review) }
    let!(:a_room) { r1.dorm_room }
    let!(:d) { a_room.dorm }
    let!(:r2) { Fabricate(:dormtrak_review, comment: nil, dorm_room: a_room) }
    let!(:r3) { Fabricate(:dormtrak_review, comment: "  ", dorm_room: a_room)}

    it "excludes blank reviews" do
      expect(d.recent_reviews).not_to include(r2)
      expect(d.recent_reviews).not_to include(r3)
    end
  end

  context ".refresh" do
    let!(:room) { Fabricate(:dorm_room, dorm: dorm) }
    let!(:r1) { Fabricate(:dormtrak_review, dorm_room: room, wifi: 5.0) }
    let!(:r2) { Fabricate(:dormtrak_review, dorm_room: room, wifi: 2.0) }
    let!(:r3) { Fabricate(:dormtrak_review, dorm_room: room, wifi: 1.0) }
    let!(:r4) { Fabricate(:dormtrak_review, dorm_room: room, wifi: nil) }

    it "should have correct rating" do
      expect(dorm.wifi).to eq(2.67)
    end

    context "after review created" do
      it "is called" do
        expect(dorm).to receive(:refresh)
        Fabricate(:dormtrak_review, dorm_room: room)
      end

      context "with non-nil key_or_card" do
        it "sets dorm's key_or_card to the most recent review's value" do
          dorm.update_attributes(key_or_card: "haha")
          Fabricate(:dormtrak_review, dorm_room: room, key_or_card: "woop")
          # just to make sure it isn't just because it's the only review
          expect(dorm.dormtrak_reviews.size).to be > 1 
          expect(dorm.key_or_card).to eq("woop")
        end
      end
    end

    context "after review destroyed" do
      it "is called" do
        expect(dorm).to receive(:refresh)
        Fabricate(:dormtrak_review, dorm_room: room)
      end      
    end
  end
end
