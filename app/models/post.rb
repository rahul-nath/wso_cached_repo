class Post < ActiveRecord::Base
  default_scope { order("created_at ASC") }
  scope :alive, -> { where deleted: false }

  belongs_to :user
  belongs_to :discussion

  validates :content, presence: true
  validates :deleted, inclusion: { in: [true, false] }

  after_create :update_last_active

  private

  def update_last_active
    discussion.update_attributes(last_active: self.created_at)
  end
end
