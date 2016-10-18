Fabricator(:area_of_study) do
  department#
  abbrev { Fabricate.sequence(:abbrev) { |i| "ABBREV#{i}" } }#["CSCI", "PSCI", "ECON"].sample }
  name { Fabricate.sequence(:name) { |i| "NAME#{i}"} } #{ |attrs| { "CSCI"=>"Computer Science", "PSCI"=>"PoliSci", "ECON"=>"Economics" }[attrs[:abbrev]] }
end
