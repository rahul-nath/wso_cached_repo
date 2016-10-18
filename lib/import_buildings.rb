require 'csv'

Neighborhood.create!(name: "Currier")
Neighborhood.create!(name: "Dodd")
Neighborhood.create!(name: "Spencer")
Neighborhood.create!(name: "Wood")
Neighborhood.create!(name: "Co-op")
Neighborhood.create!(name: "First-year")


CSV.foreach('building-info-wo-inf.csv', headers: true) do |row|
  hash = row.to_hash
  n = row[1]
  hood = Neighborhood.find_by(name: n)
  hood.buildings.create!(hash)
end
