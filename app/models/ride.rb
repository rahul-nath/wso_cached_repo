class Ride < Bulletin

  # The ordering of the .order is important because 
  # this is breaking ties in start_date by which is more recent
  scope :alive,     -> { where('start_date >= ?', Date.today)
                        .order("start_date ASC") }
  scope :has_ended, -> { where('start_date < ?', Date.today) }

  scope :offers,    -> { where(offer: true) }
  scope :requests,  -> { where(offer: false) }

  belongs_to :user

  validates :offer, inclusion: { in: [true, false] }
  validates :start_date, :source, :destination, presence: true

  before_validation :set_title

  def alive?
    !has_ended?
  end
  
  def has_ended?
    Date.today > start_date
  end

  private

  def set_title
    kind = self.offer ? "Offer" : "Request"
    self.title = "#{source} to #{destination} (#{kind})"
    true
  end

end
