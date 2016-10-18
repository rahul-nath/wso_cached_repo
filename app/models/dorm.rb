class Dorm < ActiveRecord::Base
  scope :trakked,                -> { where(neighborhood: Neighborhood.trakked) }
  scope :most_singles,           -> { trakked.reorder(number_singles: :desc) }
  scope :most_doubles,           -> { trakked.reorder(number_doubles: :desc) }
  scope :loudest,                -> { trakked.reorder(loudness: :desc) }
  scope :quietest,               -> { trakked.reorder(loudness: :asc) }
  scope :biggest,                -> { trakked.reorder(capacity: :desc) }
  scope :smallest,               -> { trakked.reorder(capacity: :asc) }
  scope :most_bathrooms,         -> { trakked.reorder(bathroom_ratio: :asc) }
  scope :fewest_bathrooms,       -> { trakked.reorder(bathroom_ratio: :desc) }
  scope :best_wifi,              -> { trakked.reorder(wifi: :desc) }
  scope :best_location,          -> { trakked.reorder(location: :desc) }
  scope :order_biggest_doubles,  -> { trakked.where.not(average_double_area: nil).order("average_double_area DESC") }
  scope :order_smallest_doubles, -> { trakked.where.not(average_double_area: nil).order("average_double_area ASC") }
  scope :order_biggest_singles,  -> { trakked.where.not(average_single_area: nil).order("average_single_area DESC") }
  scope :order_smallest_singles, -> { trakked.where.not(average_single_area: nil).order("average_single_area ASC") }

  has_many :dorm_rooms
  has_many :dormtrak_reviews, through: :dorm_rooms
  has_many :students, through: :dorm_rooms

  belongs_to :neighborhood
  validates :neighborhood, presence: true

  delegate :first_year?, :coop?, to: :neighborhood
  delegate :doubles, to: :dorm_rooms
  delegate :singles, to: :dorm_rooms

  validates :number_bathrooms, numericality: { allow_nil: true, greater_than: 0 }

  before_save :set_capacity
  before_save :set_bathroom_ratio

  def to_param
    name.downcase
  end

  def biggest_single
    singles.biggest.first
  end

  def smallest_single
    singles.smallest.first
  end

  def biggest_double
    doubles.biggest.first
  end

  def smallest_double
    doubles.smallest.first
  end

  def common_room_access
    counts = dorm_rooms.group(:common_room_access).count
    ratio = counts[true].to_f / (counts[true] + counts[false]).to_f
    "None" if ratio == 0.0
    "All or nearly all rooms have direct access" if ratio > 0.95
    "Most rooms have direct access" if ratio > 0.75
    "Some rooms have direct access" if ratio > 0.45
    "Few rooms have direct access"
  end

  def recent_reviews
    dormtrak_reviews.commented.where(dorm_room: dorm_rooms)
  end

  def self.search(search)
    search ? where('name LIKE ?', "%#{search}%") : all
  end

  def refresh
    attrs = [:comfort, :loudness, :convenience, :wifi, :location, :satisfaction]
    attrs.each { |attr| self[attr] = 0 }

    # Since some ratings might not be there. Separate counts of
    # how many times each attr has been rated
    # Also don't want to research db each time. So loop once over reviews.
    attr_counts = Hash.new

    # There is something funky going on with the rails cache
    # where it isn't loading correct reviews 
    # It might be because it is executing in a callback and apparently
    # rails devs wrote bad code for after_save 
    dormtrak_reviews(true).each do |review|
      update_attribute(:key_or_card, review.key_or_card) if review.key_or_card
      attrs.each do |attr| 
        next if review[attr].nil?
        self[attr] += review[attr]
        attr_counts[attr] = (attr_counts[attr] || 0) + 1
      end
    end

    attr_counts.each do |attr, count|
      next if count < 1
      new_avg = (self[attr] / count).round(2)
      update_attributes(attr => new_avg)
    end
  end

  def update_average_areas!
    update(average_single_area: singles.any? ? singles.average(:area).to_i : nil)
    update(average_double_area: doubles.any? ? doubles.average(:area).to_i : nil)
  end

  def update_single_double_counts!
    update(number_singles: singles.count)
    update(number_doubles: doubles.count)
  end

  def update_mode_areas!
    update(mode_single_area: singles.group(:area).limit(1).pluck(:area).first)
    update(mode_double_area: doubles.group(:area).limit(1).pluck(:area).first)
  end

  def set_capacity
    return if number_singles.nil? || number_doubles.nil?
    self.capacity = number_singles + 2 * number_doubles
  end

  def set_bathroom_ratio
    return if capacity.nil? || number_bathrooms.nil?
    self.bathroom_ratio = capacity.to_f / number_bathrooms.to_f
  end
end
