Fabricator(:factrak_agreement) do
  user        { Fabricate(:student) }
  survey      { Fabricate(:factrak_survey) }
  agrees      { [true,false].sample }
end
