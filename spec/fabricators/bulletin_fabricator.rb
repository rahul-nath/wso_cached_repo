Fabricator(:bulletin) do
  user                { Fabricate([:student, :professor, :staff].sample) }
  title               { Faker::Lorem.sentence }
  body                { Faker::Lorem.paragraph }
end

Fabricator(:ride, from: :bulletin) do
  type                "Ride"
  start_date          { Date.today }	
  offer               { [true, false].sample }
  source              { "#{Faker::Address.city}" }
  destination         { "#{Faker::Address.city}" }
end

Fabricator(:announcement, from: :bulletin) do
  type                "Announcement"
  title               { Faker::Company.bs }
  start_date          { [Date.today, nil].sample }
end

Fabricator(:exchange, from: :bulletin) do
  type                "Exchange"
  title               { Faker::Commerce.product_name }
end

Fabricator(:lost_found, from: :bulletin) do
  type                "LostFound"
  title               { ["Lost ", "Found "].sample + Faker::Commerce.product_name.partition(" ").last }
end

Fabricator(:job, from: :bulletin) do
  type                "Job"
  title               { Faker::Name.title }
end
