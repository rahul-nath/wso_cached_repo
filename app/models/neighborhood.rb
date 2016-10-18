class Neighborhood < ActiveRecord::Base
  scope :trakked, -> { where.not(name: ["Co-op", "First-year"]) }

  has_many :dorms
  has_many :students, through: :dorms
  has_many :dorm_rooms, through: :dorms

  def as_json(options={})
    if options
      super(options)
    else
      super(except: [:created_at, :updated_at, :dorms])
    end
  end
  
  def to_param
    name.downcase
  end

  def first_year?
    name == "First-year"
  end
  
  def coop?
    name == "Co-op"
  end
end
