class DormRoom < ActiveRecord::Base
  scope :trakked,  -> { where(dorm: Dorm.trakked) }
  scope :singles,  -> { where(capacity: 1) }
  scope :doubles,  -> { where(capacity: 2) }
  scope :biggest,  -> { trakked.reorder(area: :desc) }
  scope :smallest, -> { trakked.reorder(area: :asc) }

  belongs_to :dorm
  has_many   :students
  has_many   :dormtrak_reviews

  validates :dorm, :number, presence: true
  validates :capacity, inclusion: { in: [1,2] }
  validate :unique_in_building
  validate :area_if_upperclass

  after_save :update_dorm

  def self.open
    DormRoom.select { |room| room.students.count < room.capacity}
  end

  def name
    "#{dorm.name} #{number}"
  end

  def single?
    capacity == 1
  end

  def double?
    capacity == 2
  end

  def avg(attr)
    unless %w(comfort loudness convenience wifi location satisfaction).include?(attr.to_s)
      raise "Invalid attribute #{attr} for avg"
    end

    count = 0.0
    sum = 0.0
    dormtrak_reviews.each do |review|
      unless review[attr].nil?
        sum += review[attr]
        count += 1.0
      end
    end

    (sum / count).round(2)
  end

  def refresh
    latest = dormtrak_reviews(true).order("id").first
    return unless latest

    attrs = [:closet, :capacity, :faces, :flooring]
    attrs.each { |attr| self[attr] = latest[attr] || self[attr] }

    # Stuff that can be made anonymous
    anons = [:noise, :common_room_desc]
    anons.each { |attr| self[attr] = latest[attr] || self[attr] } unless latest.anonymous?

    # Always take the latest for these, because we might've been wrong before
    bools = [:common_room_access, :thermostat_access, :private_bathroom, :bed_adjustable]
    bools.each { |attr| self[attr] = latest[attr] unless latest[attr].nil? }

    if private_bathroom && latest.bathroom_desc
      bathroom_desc = latest.bathroom_desc || bathroom_desc
    end

    save!
  end

  private

  def unique_in_building
    return unless dorm
    errors.add(:number, "already taken") if dorm.dorm_rooms.any? { |r| r.number == self.number && r.id != self.id }
  end

  def area_if_upperclass
    return unless dorm
    return if dorm.coop? || dorm.first_year?
    if area.nil?
      errors.add(:area, "cannot be nil") 
    elsif area <= 0
      errors.add(:area, "must be greater than 0")
    end
  end

  def update_dorm
    dorm.update_average_areas!
    dorm.update_single_double_counts!
    dorm.update_mode_areas!
  end
end
