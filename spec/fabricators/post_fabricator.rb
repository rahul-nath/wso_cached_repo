Fabricator(:post) do
  user
  discussion
  content       { Faker::Lorem.paragraph }
  deleted       false
  ex_user_name  "name"
  lum_id        5
end
