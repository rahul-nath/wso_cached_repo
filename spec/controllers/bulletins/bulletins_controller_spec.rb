require "rails_helper"

describe BulletinsController do

  context "when logged in" do
    include_context "user"

    let(:bulletin) { Fabricate(:bulletin) }

    [:edit, :update, :destroy].each do |change_action|
      describe "get #{change_action} when not the user" do
        it "redirects" do
          get change_action, id: bulletin.id
          expect(response.status).to be(302)
          expect(response.redirect_url).to eq("http://test.host/")
        end
      end
    end
  end

  context "when guest" do
    # I think the only difference is they can't post, obviously

    context "and on campus" do
      include_context "on campus"

      [:new, :create, :edit, :update, :destroy].each do |user_action|
        describe "get #{user_action}" do
          it "redirects" do
            get user_action, id: 1 # id needed for routing a couple
            expect(response.status).to be(302)
            expect(response.redirect_url).to match("login")
          end
        end
      end
    end

    context "and off campus" do
      include_context "off campus"

      let!(:bulletin) { Fabricate(:bulletin) }

      describe "#show" do
        it "returns 200" do
          get :show, id: bulletin.id
          expect(response.status).to eq(200)
        end
      end
    end
  end

end