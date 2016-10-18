class Department < ActiveRecord::Base

  validates :name, presence: true, allow_blank: false

  has_many :professors
  has_many :staff
  has_many :areas_of_study

  def self.facstaff
    professors + staff
  end

  def to_s
    name
  end
end
