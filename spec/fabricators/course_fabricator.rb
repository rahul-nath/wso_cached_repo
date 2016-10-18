Fabricator(:course) do
  number { sprintf '%03d', (101..555).to_a.sample }
  area_of_study(fabricator: :area_of_study)
end
