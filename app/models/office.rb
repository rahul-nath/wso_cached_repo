class Office < ActiveRecord::Base
  has_many :professors
  has_many :staffs

  validates :number, presence: true, uniqueness: true
end