class Exchange < Bulletin

  default_scope { order('created_at DESC') }

  def self.title
    return "Exchange"
  end
  
end
