require 'rails_helper'

describe Discussion do

  it "has a valid factory" do
    expect(Fabricate.build(:discussion)).to be_valid
  end

  [:title, :user, :last_active].each do |thing|
    it "validates presence of #{thing}" do
      expect(Fabricate.build(:discussion, thing => nil)).not_to be_valid
    end
  end

  context ".alive" do
    let!(:op) { Fabricate(:post) }
    let!(:discussion) { op.discussion }

    let!(:op2) { Fabricate(:post) }
    let!(:discussion2) { op2.discussion }

    let!(:deleted) { Fabricate(:discussion, deleted: true) }
    let!(:del_post) { Fabricate(:post, discussion: deleted) }

    it "is ordered by last_active" do
      expect(Discussion.alive).to eq([discussion2, discussion])
    end

    it "excludes deleted discussions" do
      expect(Discussion.alive).not_to include(deleted)
    end
  end

  context "after a post is created" do
    let!(:discussion) { Fabricate(:discussion) }
    let!(:posts) { Fabricate.times(5, :post, discussion: discussion) }
    let!(:future) { Fabricate(:post, discussion: discussion, created_at: Date.today + 2.days) }

    it "has last_active equal to latest post's created_at" do
      expect(discussion.last_active).to be_within(1.second).of discussion.children.last.created_at
    end
  end

  context ".children" do
    let!(:discussion) { Fabricate(:discussion) }
    let!(:posts) { Fabricate.times(3, :post, discussion: discussion) }
    let!(:deleted) { Fabricate(:post, discussion: discussion, deleted: true) }
    let!(:otherpost) { Fabricate(:post) }    

    it "excludes deleted" do
      expect(discussion.children).not_to include(deleted)
    end

    it "includes only and all of this discussion's children" do
      expect(discussion.children).to eq(posts)
    end
  end
end
