def next_unix
  while true
    unix = "#{(0...3).map { (65 + rand(26)).chr }.join.downcase}#{(1..9).to_a.sample}"
    return unix unless User.find_by(unix_id: unix)
  end
end

Fabricator(:user) do
  su_box                      { Faker::PhoneNumber.extension }
  unix_id                     { next_unix } 
  williams_email              { |attrs| "#{attrs[:unix_id]}@williams.edu" }
  department                  { Department.all.sample } # This will need to be made specific to each type
  title                       { Faker::Name.title }
  campus_phone_ext            { Faker::PhoneNumber.extension }
  cell_phone                  { Faker::PhoneNumber.cell_phone }
  home_phone                  { Faker::PhoneNumber.phone_number }
  home_town                   { Faker::Address.city }
  home_zip                    { Faker::Address.zip }
  home_state                  { Faker::Address.state }
  home_country                { Faker::Address.country }
  visible                     { [true, true, false].sample }
  home_visible                { [true, true, false].sample }
  name                        { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
end

Fabricator(:student, from: :user) do
  dorm_room                     { Rails.env.test? ? Fabricate(:dorm_room) : DormRoom.open.sample }
  type                          "Student"
  class_year                    { Student.senior_year + rand(4) }
  major                         { %w(CSCI ECON PSCI).sample }
  entry                         { ["Sage","Willy"].sample }
  has_accepted_factrak_policy   { [true, false].sample }
  has_accepted_dormtrak_policy  { [true, false].sample }
  admin                         { [true, false].sample }
  factrak_admin                 { false }
end

Fabricator(:alum, from: :user) do
  type                        "Alum"
  class_year                  { Student.senior_year - 4 + rand(4) }
  major                         { %w(CSCI ECON PSCI).sample }
  entry                         { ["Sage","Willy"].sample }
  has_accepted_factrak_policy   { [true, false].sample }
  has_accepted_dormtrak_policy  { [true, false].sample }
  admin                         { [true, false].sample }
  factrak_admin                 { false }  
end

Fabricator(:professor, from: :user) do
  office
  type                        "Professor"
end

Fabricator(:staff, from: :user) do
  office
  type                        "Staff"
end
