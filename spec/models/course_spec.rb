require 'rails_helper'

describe Course do
  describe "#first_or_create" do
    let!(:csci) { Fabricate(:area_of_study, abbrev: "CSCI") }
    let!(:econ) { Fabricate(:area_of_study, abbrev: "ECON") }
    let!(:psci) { Fabricate(:area_of_study, abbrev: "PSCI") }

    context "area_of_study abbrev not found" do
      it "returns nil" do
        expect(Course.first_or_create("ABCD", 123)).to be_nil
      end
    end

    context "area_of_study abbrev found" do
      context "course number already exists" do
        let!(:course) { Fabricate(:course, area_of_study: csci, number: 101) }

        it "returns the course" do
          expect(Course.first_or_create("CSCI", 101)).to eq(course)
        end
      end

      context "course number does not exist" do
        it "returns a new course" do
          expect(csci.courses.where(number: 101).first).to be_nil
          course = Course.first_or_create("CSCI", 101)
          expect(course.area_of_study).to eq(csci)
          expect(course.number).to eq("101")
        end
      end

      context "course number is blank" do
        it "returns nil" do
          expect(Course.first_or_create("CSCI", nil)).to be_nil
        end
      end

      context "course number is empty string" do
        it "returns nil" do
          expect(Course.first_or_create("CSCI", "")).to be_nil
        end        
      end
    end
  end
end
