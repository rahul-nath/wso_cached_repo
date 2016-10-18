Fabricator(:dorm) do
  neighborhood
  name              { Fabricate.sequence(:name) { |i| "Dorm #{i}"} }
  number_singles { rand(1..10) }
  number_doubles { rand(1..10) }  
end
