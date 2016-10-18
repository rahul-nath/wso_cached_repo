class Bulletin < ActiveRecord::Base

  belongs_to :user

  validates :user, presence: true
  validates :title, presence: true, allow_blank: false

  # Everything other than ride will NOT have these
  # Note the special handling of boolean presence
  validates :offer, exclusion: { in: [true, false] }, unless: :ride?
  validates :offer, :source, :destination, absence: true, unless: :ride?

  before_save :normalize_start_date

  def self.latest(n)
    Bulletin.where("start_date <= ?", Date.today).last(n)
  end

  def ride?
    self.type == "Ride"
  end

  def self.title
    self.name.pluralize
  end

  def show_date
    start_date
  end

  private

  # User might assign something like Feb 1 when it is currently Oct,
  # and so we want it to use next year's feb 1, not this year's
  # It ||'s with Time.zone.now to allow for fine-grained tiebreaking
  def normalize_start_date
    self.start_date ||= Time.zone.now
    if self.start_date.to_date == Date.today
      self.start_date = Time.zone.now
    end
    self.start_date += 1.year if self.start_date < Date.today
    true
  end
end
