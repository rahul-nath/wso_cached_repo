class Job < Bulletin
  default_scope { order("start_date DESC") }
end
