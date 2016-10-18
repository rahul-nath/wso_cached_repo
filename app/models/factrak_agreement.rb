class FactrakAgreement < ActiveRecord::Base
  include StudentOwned

  belongs_to :survey, class_name: "FactrakSurvey", foreign_key:  "factrak_survey_id"
  belongs_to :user

  validates :user, :survey, presence: true
  validates :agrees, inclusion: { in: [true,false] }

  validate :user_not_survey_owner

  def user_not_survey_owner
    return unless errors.blank?
    errors.add(:base, "cannot agree with own survey") if survey.user == user
  end
end
