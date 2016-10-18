Fabricator(:department) do
  name { Fabricate.sequence(:name) { |i| "DEPT#{i}" } }#{ ["Humanities", "Center for Languages", "Asian Science"].sample }
end