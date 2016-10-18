require "rails_helper"

RSpec.describe UsersController do
  let(:user1) { Fabricate(:user) }

  shared_examples "on campus or logged in" do
    context "when other user invisible" do
      let(:other) { Fabricate(:user, visible: false) }
      it "redirects to facebook root" do
        get :show, id: other.id
        expect(response).to redirect_to facebook_path
      end
    end

    context "when other user visible" do
      let(:other) { Fabricate(:user, visible: true) }
    end
  end

  context "#show" do
    context "when logged in" do
      include_context "user"
      it_behaves_like "on campus or logged in"
    end

    context "when on campus" do
      include_context "on campus"
      it_behaves_like "on campus or logged in"
    end
  end

  context "#update" do
    context "when on campus but not logged in" do
      include_context "on campus"
      it "redirects to login" do
        get :update, id: 1
        expect(response.redirect_url).to match account_login_path
      end
    end

    context "when logged in" do
      include_context "user"

      context "as different user from update request" do
        let(:other) { Fabricate(:user) }

        it "renders forbidden" do
          put :update, id: other.id
          expect(response.status).to eq(403)
        end
      end

      context "as same user in update request" do
        subject { put :update, id: user.id }

        it "redirects to edit" do
          expect(subject).to redirect_to facebook_edit_path
        end

        [:home_visible, :dorm_visible, :visible].each do |attr|
          [true, false].each do |bool|
            context "when changing #{attr} from #{bool} to #{!bool}" do
              it "saves correct value" do
                user.update_attributes(attr => bool)
                put :update, id: user.id, user: { attr => !bool }
                expect(user[attr]).to eq(!bool)
              end
            end
          end
        end
      end
    end
  end

  self.controller_class.instance_methods(false).each do |action|
    context "##{action}" do
      context "when off campus" do
        include_context "off campus"
        subject { get action, id: user1.id } # id for routing purposes

        it "should redirect to login" do
          expect(subject.redirect_url).to match account_login_path
        end
      end
    end
  end
end
