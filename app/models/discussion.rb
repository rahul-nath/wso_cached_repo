class Discussion < ActiveRecord::Base
  include ActiveModel::Validations

  default_scope { order(last_active: :DESC) }
  scope :alive, -> { where deleted: false }

  belongs_to :user
  has_many   :posts

  validates :title, :user, :last_active, presence: true
  validates :deleted, inclusion: { in: [true, false] }

  before_create :update_last_active

  def self.title
    "Discussions"
  end

  def show_date
    last_active
  end

  def children
    Post.where(discussion_id: id, deleted: false)
  end

  private

  def update_last_active
    last_active = DateTime.now
  end 
end
