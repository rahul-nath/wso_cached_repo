class Professor < User

  belongs_to :office

  has_many :courses, -> { where uniq: true }, through: :surveys
  has_many :surveys, class_name: "FactrakSurvey", foreign_key: "professor_id", dependent: :destroy

  def room_string
    "#{office.number}" if office
  end

  ## Get this professor's average score on surveys for attribute attr. However,
  ## we only return the value if there are enough surveys that scored it
  def average(attr)
    total = 0
    count = 0
    surveys.each do |s|
      if s[attr]
        total += s[attr]
        count += 1
      end
    end
    if count >= 1
      return (total / count).to_i
    else
      return nil
    end
  end	
end
