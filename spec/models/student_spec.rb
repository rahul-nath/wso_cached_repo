require 'rails_helper'

describe Student do

  let(:student) { Fabricate.build(:student, name: "Stephanie Liu", class_year: 2018, major: "CSCI") }
  let(:dinosaur) { Fabricate.build(:student, class_year: 20) }

  it "validates class_year isn't ridiculous" do
    expect(dinosaur).not_to be_valid
  end

  context ".graduate!" do
    context "when grad date passed" do
      let!(:grad) { Fabricate(:student, class_year: Student.senior_year - 1) }

      it "sets the user to be an alum" do
        grad.graduate!
        expect(grad.type).to eq("Alum")
      end

      it "preserves factrak surveys" do
        survey = Fabricate(:factrak_survey, user: grad)
        grad.graduate!
        expect(grad.factrak_surveys(true).first).to eql(survey)
        expect(survey.user).to be(grad)
      end
    end

    context "when grad date not passed" do
      let!(:junior) { Fabricate(:student, class_year: Student.senior_year + 1) }

      it "raises exception" do
        expect { junior.graduate! }.to raise_error("Too soon to graduate")
      end
    end
  end

  context "#senior_year" do
    it "returns the current senior year" do
      correct_year = Time.zone.now.month > 7 ? Time.zone.now.year + 1 : Time.zone.now.year
      expect(Student.senior_year).to eq(correct_year)
    end
  end

  context ".name_string" do
    it "should append 'class_year" do
      expect(student.name_string).to eq("Stephanie Liu '18")
    end
  end

  context ".major" do
    it "returns the student's major" do
      expect(student.major).to eq("CSCI")
    end    
  end

  context ".major_list" do
    context "when single major" do
      let(:student) { Fabricate.build(:student, major: "CSCI") }

      it "returns the student's major" do
        expect(student.major_list).to eq("CSCI")
      end
    end

    context "when double major" do
      let(:student) { Fabricate.build(:student, major: "CSCI CHIN") }

      it "returns the student's major" do
        expect(student.major_list).to eq("CSCI and CHIN")
      end      
    end
  end

  context ".dorm" do
    context "when dorm room nil" do
      let!(:student) { Fabricate.build(:student, dorm_room: nil) }

      it "returns nil" do
        expect(student.dorm).to be_nil
      end
    end

    context "when dorm room not nil" do
      let!(:student) { Fabricate.build(:student) }

      it "returns dorm to which dorm_room belongs" do
        expect(student.dorm).to eq(student.dorm_room.dorm)
      end
    end
  end

  context ".room_string" do
    let!(:student) { Fabricate(:student) }

    context "when user has a dorm" do
      it "returns something like <dorm name> ..." do
        expect(student.room_string).to include(student.dorm.name)
      end
    end

    context "when dorm_room is nil" do
      before do
        student.update(dorm_room: nil)
      end

      it "does not raise an error" do
        expect(student.room_string).to be_nil
        expect{ student.room_string }.not_to raise_error
      end
    end
  end

  context ".graduated?" do
    context "when student has graduated" do
      let(:student) { Fabricate(:student, class_year: Time.zone.now.year) }
      let(:cutoff) { Time.zone.local(Time.zone.now.year, 7, 31) }

      context "and past cutoff month" do
        it "should return true" do
          Timecop.freeze(cutoff + 1.day) do
            expect(student.graduated?).to be_truthy
          end
        end
      end

      context "and before/at cutoff month" do
        it "should return false" do
          Timecop.freeze(cutoff) do
            expect(student.graduated?).to be_falsy
          end
        end
      end
    end

    context "student has not graduated" do
      let(:student) { Fabricate(:student, class_year: Time.zone.now.year + 1) }

      it "should return false" do
        expect(student.graduated?).to be_falsy
      end
    end
  end

  context ".can_edit_review" do
    let (:student) { Fabricate(:student, admin: false) }
    let (:admin) { Fabricate(:student, admin: true) }

    [:dormtrak_review, :factrak_survey].each do |review_type|
      context "on #{review_type}" do
        let (:some_review) { Fabricate(review_type) }
        let (:own_review) { Fabricate(review_type, user: student)}
        
        it "returns false if the user is not the writer and the user is not an admin" do
          expect(student.can_edit_review(some_review)).to be_falsy
        end
        
        it "returns true if the user is an admin" do
          expect(admin.can_edit_review(some_review)).to be_truthy
        end

        it "returns true if user owns review" do
          expect(student.can_edit_review(own_review)).to be_truthy
        end
      end
    end
  end

  context ".has_reviewed_room?" do
    let!(:review) { Fabricate(:dormtrak_review) }
    let!(:student) { review.user }

    context "with arg" do
      context "and user has reviewed room" do
        it "returns true" do
          expect(student.has_reviewed_room?(review.dorm_room)).to be_truthy
        end
      end

      context "and user has not reviewed room" do
        it "returns false" do
          expect(student.has_reviewed_room?(Fabricate(:dorm_room))).to be_falsy
        end
      end
    end

    context "with default arg (current room)" do
      context "and user has not reviewed current room" do
        it "returns false" do
          expect(review.dorm_room).not_to eq(student.dorm_room)
          expect(student.has_reviewed_room?).to be_falsy
        end
      end

      context "and user has reviewed current room" do
        let!(:r2) { Fabricate(:dormtrak_review, dorm_room: student.dorm_room, user: student) }

        it "returns true" do
          expect(student.has_reviewed_room?).to be_truthy
        end
      end
    end
  end

  context ".has_reviewed_room_in_dorm?" do
    context "when user has reviewed room in dorm" do
      let!(:student) { Fabricate(:student) }
      let!(:review) { Fabricate(:dormtrak_review, user: student, dorm_room: student.dorm_room) }
      let!(:dorm) { review.dorm }

      context "with arg" do
        let!(:review2) { Fabricate(:dormtrak_review, user: student) }

        it "returns true" do
          expect(review2.dorm).not_to eq(review.dorm)
          expect(student.has_reviewed_room_in_dorm?(review2.dorm)).to be_truthy
        end
      end

      context "without arg" do
        it "returns true" do
          expect(student.has_reviewed_room_in_dorm?).to be_truthy
        end
      end
    end

    context "when user has not reviewed room in dorm" do
      let!(:review) { Fabricate(:dormtrak_review) }
      let!(:student) { review.user }
      let!(:dorm) { student.dorm }

      context "with arg" do
        it "returns false" do
          expect(student.has_reviewed_room_in_dorm?(Fabricate(:dorm))).to be_falsy
        end
      end

      context "without arg" do
        it "returns false" do
          expect(student.has_reviewed_room_in_dorm?).to be_falsy
        end
      end
    end

    context "when user does not have a dorm" do
      let!(:student) { Fabricate(:student, dorm_room: nil) }

      context "with arg" do
        it "returns false" do
          expect(student.has_reviewed_room_in_dorm?(Fabricate(:dorm))).to be_falsy
        end
      end

      context "without arg" do
        it "returns false" do
          expect(student.has_reviewed_room_in_dorm?).to be_falsy
        end
      end      
    end
  end
end
