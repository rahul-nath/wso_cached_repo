Fabricator(:dormtrak_review) do
  user                { Fabricate(:student) }
  dorm_room
  comment             { Faker::Lorem.paragraph }
  lived_here          { [true, false].sample }
  closet              { Faker::Lorem.sentence }
  flooring            { Faker::Lorem.sentence }
  common_room_access  { [true, false].sample }
  common_room_desc    { Faker::Lorem.paragraph }
  thermostat_access   { [true, false].sample }
  thermostat_desc     { Faker::Lorem.paragraph }
  outlets_desc        { Faker::Lorem.paragraph }
  noise               { Faker::Lorem.paragraph }
  bed_adjustable      { [true, false].sample }
  anonymous           { [true, false].sample }
  faces               { %w(N E W S).sample }
  private_bathroom    { [true, false].sample }
  bathroom_desc       { Faker::Lorem.paragraph }
  picture             { Faker::Lorem.sentence }  
end
