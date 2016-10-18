class AreaOfStudy < ActiveRecord::Base
  validates :name, :abbrev, presence: true, uniqueness: true

  belongs_to :department
  has_many :courses

  def to_s
    abbrev
  end
end
