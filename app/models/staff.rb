class Staff < User
  belongs_to :office

  def room_string
  	"#{office.number}" if office
  end
end