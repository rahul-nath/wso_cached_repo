require 'rails_helper'

RSpec.describe Factrak::CoursesController do

  it_behaves_like "factrak restricted"

  1.times { |i| let!("course#{i}") { Fabricate(:course) } }

  context "as a student" do
    context "who has accepted factrak policy" do
      include_context "student who has accepted factrak policy"

      context "get show" do
        it "renders show page" do
          get :show, id: 1
          expect(response).to render_template(:show)
        end
      end
    end
  end

end
