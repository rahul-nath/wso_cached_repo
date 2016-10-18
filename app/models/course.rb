class Course < ActiveRecord::Base
  validates :area_of_study, presence: true
  validates :number, presence: true, allow_blank: false

  belongs_to :area_of_study

  has_many :professors, -> { distinct }, through: :surveys
  has_many :surveys, class_name: "FactrakSurvey", foreign_key: "course_id"
  UNKNOWN = "_"

  def to_s
    "#{area_of_study.abbrev} #{number == UNKNOWN ? '[Unknown]' : number}"
  end

  def self.first_or_create(abbrev, number)
    return nil unless abbrev.present? && number.present?
    aos = AreaOfStudy.where("lower(abbrev) = ?", abbrev.downcase).first
    aos.nil? ? nil : aos.courses.find_or_create_by(number: number)
  end
end
