class Announcement < Bulletin

  scope :alive, -> { where("start_date <= ?", Time.now)
  					.order(start_date: :desc) }
  					

  def show_date
    start_date || created_at
  end

end
