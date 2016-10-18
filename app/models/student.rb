class Student < User
  include Graduatable

  CUTOFF_MONTH = 7 # The month after which rising X are now X

  scope :seniors,    -> { where(class_year: senior_year) }
  scope :juniors,    -> { where(class_year: junior_year) }
  scope :sophomores, -> { where(class_year: sophomore_year) }
  scope :freshmen,   -> { where(class_year: freshman_year) }

  belongs_to :dorm_room
  delegate :dorm, to: :dorm_room, allow_nil: true
  
  has_many :ephcatches, class_name: "Ephcatch", foreign_key: "user_id"

  validates :has_accepted_dormtrak_policy, inclusion: { in: [true,false] }

  # If 2015, there might be class of 2020's decided (via early decision)
  # but we shouldn't care about them until 2016, so current year + 5 is fine
  validates :class_year, presence: true, numericality: { greater_than: 1793, less_than: Date.today.year + 5 }

  def graduate!
    raise "Too soon to graduate" unless graduated?

    update_attributes(type: "Alum")
  end

  def self.senior_year
    Time.zone.now.year + (Time.zone.now.month >= CUTOFF_MONTH ? 1 : 0)
  end

  def self.junior_year
    senior_year + 1
  end

  def self.sophomore_year
    senior_year + 2
  end

  def self.freshman_year
    senior_year + 3
  end

  def senior?
    class_year == self.class.senior_year
  end

  def name_string
    "#{name} '#{(class_year % 100)}" if class_year && !graduated?
  end

  def room_string
    "#{dorm.name} #{dorm_room.number}" if dorm_room && dorm
  end

  def ephcatch_matches
    ephcatches.filter { |catch| catch.match? }.map { |catch| catch.other }
  end

  def major_list
    major.split(" ").to_sentence
  end

  def graduated?
    # Class year greater than current year, or same year and past CUTOFF_MONTH
    (class_year < Time.now.year) || (class_year == Time.zone.now.year && Time.zone.now.month > CUTOFF_MONTH)
  end

  def can_edit_review(review)
    review && (review.user == self || self.admin?)
  end

  def has_reviewed_room?(room=dorm_room)
    dormtrak_reviews.find { |review| review.dorm_room == room }
  end

  def has_reviewed_room_in_dorm?(dorm=dorm)
    dormtrak_reviews.any? { |review| review.dorm == dorm }
  end
end
