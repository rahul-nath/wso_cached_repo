require 'rails_helper'

describe DormRoom do

  it "has a valid factory" do
    expect(Fabricate.build(:dorm_room)).to be_valid
  end

  it "validates presence of dorm" do
    expect(Fabricate.build(:dorm_room, dorm: nil)).not_to be_valid
  end

  it "validates capacity is 1 or 2" do
    expect(Fabricate.build(:dorm_room, capacity: 0)).not_to be_valid
    expect(Fabricate.build(:dorm_room, capacity: 3)).not_to be_valid
  end

  context "in upperclass dorm" do
    let!(:dorm) { Fabricate(:dorm, neighborhood: Fabricate(:neighborhood, name: "Dodd")) }

    it "validates area is not nil for upperclass dorm" do
      expect(Fabricate.build(:dorm_room, dorm: dorm, area: nil)).not_to be_valid
    end

    it "validates area > 0" do
      expect(Fabricate.build(:dorm_room, dorm: dorm, area: 0)).not_to be_valid
      expect(Fabricate.build(:dorm_room, dorm: dorm, area: -1)).not_to be_valid      
    end
  end

  context "in freshmen dorm" do
    let!(:dorm) { Fabricate(:dorm, neighborhood: Fabricate(:neighborhood, name: "First-year")) }

    it "allows nil area" do
      expect(Fabricate.build(:dorm_room, dorm: dorm, area: nil)).to be_valid
    end
  end

  context "in coop" do
    let!(:dorm) { Fabricate(:dorm, neighborhood: Fabricate(:neighborhood, name: "Co-op")) }

    it "allows nil area" do
      expect(Fabricate.build(:dorm_room, dorm: dorm, area: nil)).to be_valid
    end    
  end

  context "area change" do
    context "(for means)" do
      let!(:single) { Fabricate(:dorm_room, capacity: 1, area: 10) }
      let!(:double) { Fabricate(:dorm_room, capacity: 2, area: 30) }

      it "updates dorm average single area" do
        expect(single.dorm.average_single_area).to eq(10)
        single.update(area: 5)
        expect(single.dorm.average_single_area).to eq(5)
      end

      it "updates dorm average double area" do
        expect(double.dorm.average_double_area).to eq(30)
        double.update(area: 12)
        expect(double.dorm.average_double_area).to eq(12)
      end
    end

    context "(for modes)" do
      let!(:dorm) { Fabricate(:dorm) }
      let!(:singles) { Fabricate.times(2, :dorm_room, dorm: dorm, capacity: 1, area: 10) }
      let!(:doubles) { Fabricate.times(2, :dorm_room, dorm: dorm, capacity: 2, area: 20) }

      context "mode single size changes" do
        it "updates mode single area" do
          expect(dorm.mode_single_area).to eq(10)
          Fabricate.times(3, :dorm_room, dorm: dorm, capacity: 1, area: 5)
          expect(dorm.mode_single_area).to eq(5)          
        end
      end

      it "updates mode double area" do
        expect(dorm.mode_double_area).to eq(20)
        Fabricate.times(3, :dorm_room, dorm: dorm, capacity: 2, area: 3)
        expect(dorm.mode_double_area).to eq(3)             
      end
    end
  end

  context "capacity change" do
    let!(:room) { Fabricate(:dorm_room, capacity: 1) }

    it "updates dorm single count" do
      expect(room.dorm.number_singles).to eq(1)
      room.update(capacity: 2)
      expect(room.dorm.number_singles).to eq(0)
    end

    it "update double count" do
      expect(room.dorm.number_doubles).to eq(0)
      room.update(capacity: 2)
      expect(room.dorm.number_doubles).to eq(1)
    end
  end

  describe "unique in building validation" do
    context "when duplicate number" do
      it "is invalid" do
        room = Fabricate(:dorm_room, number: "101")
        room.dorm.reload
        expect(Fabricate.build(:dorm_room, dorm: room.dorm, number: "101")).not_to be_valid
      end
    end

    context "when not duplicate number" do
      it "is valid" do
        room = Fabricate(:dorm_room, number: "101")
        room.dorm.reload
        expect(Fabricate.build(:dorm_room, dorm: room.dorm, number: "102")).to be_valid        
      end
    end

    context "when duplicate number is in another building" do
      it "is valid" do
        room = Fabricate(:dorm_room, number: "101")
        room.dorm.reload
        expect(Fabricate.build(:dorm_room, number: "101")).to be_valid        
      end      
    end
  end

  context "when capacity is 1" do
    let(:single) { Fabricate.build(:dorm_room, capacity: 1) }

    it "is a single" do
      expect(single.single?).to be_truthy
    end

    it "not a double" do
      expect(single.double?).to be_falsy
    end
  end

  context "when capacity is 2" do
    let(:double) { Fabricate.build(:dorm_room, capacity: 2) }

    it "is not a single" do
      expect(double.single?).to be_falsy
    end

    it "is a double" do
      expect(double.double?).to be_truthy
    end
  end  


  let!(:room) { Fabricate(:dorm_room) }
  let!(:r1) { Fabricate(:dormtrak_review, dorm_room: room, wifi: 5.0) }
  let!(:r2) { Fabricate(:dormtrak_review, dorm_room: room, wifi: 2.0) }
  let!(:r3) { Fabricate(:dormtrak_review, dorm_room: room, wifi: 1.0) }
  let!(:r4) { Fabricate(:dormtrak_review, dorm_room: room, wifi: nil) }

  context ".avg" do
    it "ignores nils in calculating average" do
      expect(room.avg(:wifi)).to eq(2.67)
    end
  end

  context ".refresh" do
    context "after review deleted" do
      it "is called" do
        expect(room).to receive(:refresh)
        r1.destroy
      end      
    end

    context "after review saved" do
      it "is called" do
        review = Fabricate(:dormtrak_review, dorm_room: room)
        expect(room).to receive(:refresh)
        review.update_attributes(wifi: 2.0)
      end
    end

    context "after review created" do
      it "is called" do
        expect(room).to receive(:refresh)
        Fabricate(:dormtrak_review, dorm_room: room)
      end

      context "if review anonymous" do
        let!(:cr_desc_before) { room.common_room_desc }
        let!(:noise_before) { room.noise }
        let!(:anon) { Fabricate(:dormtrak_review, 
                                dorm_room: room, 
                                anonymous: true,
                                common_room_desc: "hhee",
                                noise: "naaaa") }

        it "doesnt take noise description" do
          expect(room.common_room_desc).to eq(cr_desc_before)
        end

        it "doesnt take common room description" do
          expect(room.noise).to eq(noise_before)
        end
      end

      [:closet, :faces, :flooring, :bed_adjustable, 
       :noise, :common_room_desc, :common_room_access, :thermostat_access, :private_bathroom].each do |attr|
        it "supersedes existing #{attr}" do
          review = Fabricate(:dormtrak_review, dorm_room: room, anonymous: false)
          expect(room[attr]).to eq(review[attr])
        end
      end

      # This is a possible implementation error. If it is previously true,
      # and the latest review says it is false, then there might be an implementation
      # error like this (assuming room[:cool] = true, latest_review[:cool] = false: 
      # room[:cool] ||= latest_review[:cool] # will assign room[:cool] = true
      [:private_bathroom, :common_room_access, :bed_adjustable].each do |attr|
        it "handles transition from true to false for boolean #{attr}" do
          room.update_attributes(attr => true)
          review = Fabricate(:dormtrak_review, dorm_room: room, attr => false)
          expect(room[attr]).to be_falsy
        end
      end

    end
  end

end
