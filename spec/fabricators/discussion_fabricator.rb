Fabricator(:discussion) do
  user
  last_active     { DateTime.now - ((1..999).to_a.sample).day }
  title           { Faker::Lorem.sentence }
  lum_id          5
  ex_user_name    { Faker::Name.name }
  deleted         false
end
