class ApiKey < ActiveRecord::Base
  belongs_to :user
  
  validates :user, presence: true
  validates :access_token, uniqueness: true

  before_save :generate_access_token
  before_save :generate_expires_at

  def as_json(options={})
    super(only: [:access_token, :expires_at])
  end
  

  def expired?
    Time.now.to_i > self.expires_at
  end

  private

  # By default, tokens expire in 60 days
  def generate_expires_at
    self.expires_at = (Time.now + 60.days).to_i
  end

  def generate_access_token
    # Generates a string of length 244.
    # Probability of token collision is (26+10)^244.
    # The number of atoms in the observable universe is 4e81.
    self.access_token = SecureRandom.hex(122)
  end

end
