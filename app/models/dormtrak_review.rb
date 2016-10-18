class DormtrakReview < ActiveRecord::Base
  include StudentOwned

  default_scope { order('created_at DESC') }
  scope :commented, -> { where("comment <> ''") }

  belongs_to :dorm_room
  delegate :dorm, to: :dorm_room, allow_nil: true

  before_validation :strip_whitespace

  validates :dorm_room, presence: true
  validate :same_dorm_as_room

  after_save :refresh
  after_destroy :refresh

  def anonymous_tag_expired?
    Time.now.month >= 9 && Time.now.year >= self.created_at.year
  end

  def public?
    update(:anonymous, true) if anonymous_tag_expired?
    anonymous?
  end

  def same_dorm_as_room
    if dorm.present? && dorm_room.present? && user.present?
      if self.dorm != self.dorm_room.dorm
        errors.add(:dorm, "must be the one the room is in")
      end
    end
  end

  def unique_room(user)
    if user.dormtrak_reviews.any?
      user.dormtrak_reviews.each do |review|
        if dorm_room && review.dorm_room && dorm_room == review.dorm_room
          errors.add(:dorm_room, "You can only post one review per room.")
          return
        end
      end
    end
  end

  private
  
  def refresh
    dorm.refresh
    dorm_room.refresh
  end

  def strip_whitespace
    self.comment = self.comment.strip unless self.comment.nil?    
  end
end
