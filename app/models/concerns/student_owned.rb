# The purpose of this file is to provide a validation upon
# the creation of some model which can only belong to a student
# when the record is created, and then afterwards can belong
# to either a student or an alum (which is usually the result of 
# graduating a student)
# This is needed because all user subtypes are stored in the same
# table and only differentiated by their type column,
# and so we want not just to prevent professors/staff from creating
# factrak reviews at the view level (they can't see the page), but also
# at the model level (this stuff)

module StudentOwned
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    validates :user, presence: true
    validate :user_is_student, on: :create
  end

  def user_is_student
    errors.add(:user, "must be a student") unless user.is_a? Student
  end  
end
