class LostFound < Bulletin

  default_scope { order("start_date DESC") }

  # Used for things like the home page box title
  def self.title
    "Lost + Found"
  end

  def lost_or_found
    lost? ? "Lost" : "Found"
  end

  def lost?
    !offer?
  end

  def found?
    offer?
  end

end
