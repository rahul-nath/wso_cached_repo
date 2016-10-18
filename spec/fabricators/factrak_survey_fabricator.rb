Fabricator(:factrak_survey) do
  user                    { Fabricate(:student) }
  professor
  course

  comment                 { Faker::Lorem.paragraphs(3).join(" ") }
  flagged                 { [true,false,false,false,false].sample }
  grade_received          { %w(A B C D F).sample }
  would_recommend_course  { [true, false].sample }
  would_take_another      { [true, false].sample }
  course_workload         { (1..7).to_a.sample }
  course_stimulating      { (1..7).to_a.sample }
  approachability         { (1..7).to_a.sample }
  lead_lecture            { (1..7).to_a.sample }
  promote_discussion      { (1..7).to_a.sample }
  outside_helpfulness     { (1..7).to_a.sample }
end
