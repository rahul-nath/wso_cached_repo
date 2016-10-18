class ParseHelper


  def self.push_to_android(message, channel)
    self.push(message, channel, "android")
  end

  def self.push_to_ios(message, channel)
    self.push(message, channel, "ios")
  end


  private

  def self.push(message, channel, device)
    data = { alert: message }
    push = Parse::Push.new(data, channel)
    push.type = device
    push.save
  end

end
