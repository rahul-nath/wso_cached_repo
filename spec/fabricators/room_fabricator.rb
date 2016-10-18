def get_number
  sprintf '%03d', (1..455).to_a.sample
end

Fabricator(:dorm_room) do
  number              { get_number }
  dorm                { Rails.env.test? ? Fabricate(:dorm) : Dorm.all.sample }
  closet              "a closet"
  flooring            "wood"
  common_room_access  { [true,false].sample }
  common_room_desc    "spacious"
  thermostat_access   { [true,false].sample }
  thermostat_desc     "warmth"
  outlets_desc        "hard to reach"
  key_or_card         "card"
  faces               %w(N E S W).sample
  noise               "lots"
  bed_adjustable      { [true,false].sample }
  capacity            { (1..2).to_a.sample }
  hc                  { [true,false].sample }
  private_bathroom    { [true,false].sample }
  floor_number        1
  area                1
  walkthrough         { [true,false].sample }
  bathroom_desc       "toilets"
  num_flag            true
end

Fabricator(:office) do
  number              { Faker::Address.street_address }
end
