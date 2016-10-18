require 'rails_helper'

RSpec.describe EphcatchController do

  shared_examples "filters during senior week" do
    self.controller_class.instance_methods(false).each do |action|
      it "redirects to root" do
        Timecop.freeze(Date.new(Time.now.year, 5, 20)) do
          get action, id: 1 # for routing purposes only
          expect(response).to redirect_to root_path
        end
      end
    end
  end

  shared_examples "filters when outside of senior week" do
    self.controller_class.instance_methods(false).each do |action|
      it "redirects to root" do
        Timecop.freeze(Date.new(Time.now.year, 3, 1)) do
          get action, id: 1 # for routing purposes only
          expect(response).to redirect_to root_path
        end
      end
    end
  end

  context "when not logged in" do
    it_behaves_like "filters when outside of senior week"

    self.controller_class.instance_methods(false).each do |action|
      it "redirects to root" do
        Timecop.freeze(Date.new(Time.now.year, 5, 20)) do
          get action, id: 1 # for routing purposes only
          expect(response.redirect_url).to match account_login_path
        end
      end
    end
  end

  context "when logged in" do
    context "as a senior" do
      include_context "senior"

      it_behaves_like "filters when outside of senior week"

      context "during senior week" do
        # I don't care what it does right now in particular
        self.controller_class.instance_methods(false).each do |action|
          context "##{action}" do
            it "returns 200" do
              expect(response.status).to eq(200)
            end
          end
        end
      end
    end

    context "as not a senior" do
      include_context "underclassman"

      it_behaves_like "filters when outside of senior week"
      it_behaves_like "filters during senior week"
    end
  end
end
