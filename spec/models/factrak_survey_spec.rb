require 'rails_helper'

RSpec.describe FactrakSurvey do

  # Presence validations
  [:user, :professor].each do |owner|
    it "validates presence of #{owner}" do
      expect(Fabricate.build(:factrak_survey, owner => nil)).not_to be_valid
    end
  end

  describe "comment length validation" do
    context "when greater than 100 chars" do
      it "is valid" do
        expect(Fabricate.build(:factrak_survey, comment: "a"*100)).to be_valid
      end
    end

    context "when less than 100 chars" do
      it "is valid" do
        expect(Fabricate.build(:factrak_survey, comment: "a"*99)).not_to be_valid
      end
    end
  end

  describe "comment blank validation" do
    context "when blank" do
      it "is invalid" do
        expect(Fabricate.build(:factrak_survey, comment: "\n"*100 + " "*100)).not_to be_valid
      end
    end

    context "when not blank" do
      it "is valid" do
        expect(Fabricate.build(:factrak_survey, comment: "a" * 100)).to be_valid
      end
    end
  end

  describe "#validates not same prof and course" do
    let!(:student) { Fabricate(:student) }

    context "when same prof and course" do
      it "is invalid" do
        student.factrak_surveys << Fabricate(:factrak_survey)
        survey1 = student.factrak_surveys.first
        survey2 = Fabricate.build(:factrak_survey,
                                  user: student,
                                  professor: survey1.professor,
                                  course: survey1.course)
        expect(survey2).not_to be_valid
      end
    end

    context "when different prof, same course" do
      it "is valid" do
        student.factrak_surveys << Fabricate(:factrak_survey)
        survey1 = student.factrak_surveys.first
        survey2 = Fabricate.build(:factrak_survey,
                                  user: student,
                                  course: survey1.course)
        expect(survey2).to be_valid
      end
    end

    context "when same prof, different course" do
      it "is valid" do
        student.factrak_surveys << Fabricate(:factrak_survey)
        survey1 = student.factrak_surveys.first
        survey2 = Fabricate.build(:factrak_survey,
                                  user: student,
                                  professor: survey1.professor)
        expect(survey2).to be_valid
      end
    end

    context "when different prof, different course" do
      it "is valid" do
        student.factrak_surveys << Fabricate(:factrak_survey)
        survey1 = student.factrak_surveys.first
        survey2 = Fabricate.build(:factrak_survey,
                                  user: student)
        expect(survey2).to be_valid
      end
    end
  end

  describe ".==" do
    context "when prof and course are the same" do
      let(:survey1) { Fabricate(:factrak_survey) }
      let(:survey2) { Fabricate(:factrak_survey,
                                professor: survey1.professor,
                                user: survey1.user,
                                course: survey1.course) }
      it "returns true" do
        expect(survey1).to equal(survey2)
      end
    end

    context "when prof and course are different" do
      let(:survey1) { Fabricate(:factrak_survey) }
      let(:survey2) { Fabricate(:factrak_survey, user: survey1.user) }

      it "returns false" do
        expect(survey1).not_to equal(survey2)
      end
    end

    context "when students are different" do
      let(:survey1) { Fabricate(:factrak_survey) }
      let(:survey2) { Fabricate(:factrak_survey,
                                professor: survey1.professor,
                                course: survey1.course) }

      it "returns false" do
        expect(survey1).not_to equal(survey2)
      end
    end
  end

end
