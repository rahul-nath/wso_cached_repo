require 'rails_helper'

describe Neighborhood do
  let!(:neighborhood) { Fabricate(:neighborhood) }
  let!(:other_dorms) { Fabricate(:dorm) }
  let!(:dorm1) { Fabricate(:dorm, neighborhood: neighborhood) }
  let!(:dorm2) { Fabricate(:dorm, neighborhood: neighborhood) }
  let!(:dorm3) { Fabricate(:dorm, neighborhood: neighborhood) }
  let!(:student1) { Fabricate(:student, dorm_room: Fabricate(:dorm_room, dorm: dorm1)) }
  let!(:student2) { Fabricate(:student, dorm_room: Fabricate(:dorm_room, dorm: dorm2)) }
  let!(:student3) { Fabricate(:student, dorm_room: Fabricate(:dorm_room, dorm: dorm3)) }
  let!(:student4) { Fabricate(:student) }

  describe ".students" do
    it "returns all users living in dorms in this neighborhood" do
      correct = Student.joins(:dorm_room).merge(DormRoom.where(dorm_id: [dorm1.id, dorm2.id, dorm3.id]))
      expect(neighborhood.students).to eq(correct)
    end
  end

  describe ".first-year?" do
    context "when first year" do
      let!(:fyn) { Fabricate(:neighborhood, name: "First-year") }

      it "returns true" do
        expect(fyn.first_year?).to be_truthy
      end
    end

    context "when not first year" do
      let!(:non) { Fabricate(:neighborhood, name: "Dodd") }

      it "returns false" do
        expect(non.first_year?).to be_falsy
      end      
    end
  end

  describe ".coop?" do
    context "when coop" do
      let!(:coop) { Fabricate(:neighborhood, name: "Co-op") }

      it "returns true" do
        expect(coop.coop?).to be_truthy
      end
    end

    context "when not coop" do
      let!(:non) { Fabricate(:neighborhood, name: "Dodd") }

      it "returns false" do
        expect(non.coop?).to be_falsy
      end      
    end    
  end
end
