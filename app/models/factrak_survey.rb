class FactrakSurvey < ActiveRecord::Base
  include StudentOwned

  # This allows to try to initialize the factrak survey
  # using these two things to find the course. They aren't
  # persisted to the database
  attr_accessor :aos_abbrev, :course_num

  default_scope { order('created_at DESC') }

  scope :commented, -> { where("comment <> ''") }
  scope :flagged, -> { where(flagged: true) }

  belongs_to :professor
  belongs_to :course

  has_many :agreements, class_name: "FactrakAgreement", foreign_key: "factrak_survey_id", dependent: :destroy

  before_validation :assign_course
  validates :professor, presence: true
  validates :comment, presence: true, allow_blank: false, length: { minimum: 100 }
  validate :not_same_prof_and_course

  def not_same_prof_and_course
    return unless course && user
    if user.factrak_surveys.any? { |other| other.id != self.id && other.equal?(self) }
      errors[:base] << "You've already reviewed this professor for this course."
    end
  end

  def equal?(s2)
    false if self.nil? || s2.nil?
    s2.professor == professor &&
    s2.course == course &&
    s2.user == user
  end

  ## Compute the score of this comment/survey, which is based on how many
  ## people agree with it, and how old it is
  def score_top
    agrees-disagrees - (1 + Date.today.year - created_at.year)**2
  end

  def score_helpful
    agrees - disagrees
  end

  def score_controversial
    (agrees - agrees).abs**2
  end

  def agrees
    agreements.where(agrees: true).count
  end

  def disagrees
    agreements.where(agrees: false).count
  end

  def assign_course
    return unless aos_abbrev || course_num    
    self.course = Course.first_or_create(aos_abbrev, course_num)
    errors.add(:course, "must have valid area of study and number") unless course
  end
end
