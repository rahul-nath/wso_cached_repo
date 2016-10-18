
# step one: create a new database with the proper schema
# rake db:drop db:create db:schema:load

# then, run this script to populate the new one given the old

# PROLOGUE
# This should point to a mysql connection of the old data.
conn = Mysql2::Client.new(
  username:'old_wso',
  password:'phoneg00blin',
  database:'old_data',
  socket:'/var/run/mysqld/mysqld.sock')



# NEIGHBORHOODS
puts "Neighborhoods:"
Neighborhood.create!(name: "Currier")
Neighborhood.create!(name: "Dodd")
Neighborhood.create!(name: "Spencer")
Neighborhood.create!(name: "Wood")
Neighborhood.create!(name: "Co-op")
Neighborhood.create!(name: "First-year")

old_neighborhoods = conn.query("SELECT id,name FROM neighborhoods")

# BUILDINGS
puts "Buildings:"
old_buildings = conn.query("SELECT * FROM buildings")

old_buildings.each do |b|

  # get the neighborhood name by old id, find it in the new db.
  n_id = Neighborhood.find_by(
    name: 
      old_neighborhoods.find { |n|
      n["id"] == b["neighborhood_id"] }["name"]
  ).id

  attr = Hash[b.map {|k,v| [k.to_sym, v]}]

  puts attr
  
  attr.merge!(neighborhood_id: n_id)
  attr.except!(:id, :neighborhood_name, :seniors, :juniors, :sophomores, :freshmen)

  Dorm.create!(attr)
end; nil


# ADD THE ENTRIES and coops


for name in ["Sage", "Williams", "Pratt", "Armstrong", "Dennett", "Mills"]
  Dorm.create!(
    neighborhood_id: Neighborhood.find_by(name: "First-Year").id,
    name: name
  )
end

for name in ["Chadbourne", "Doughty", "Lambert", "Milham", "Poker Flats", "Susie Hopkins", "Woodbridge"]
  Dorm.create!(
    neighborhood_id: Neighborhood.find_by(name: "Co-op").id,
    name: name
  )
end


# ROOMS
puts "rooms:"
old_rooms = conn.query("SELECT * FROM rooms")
room_map = {}

old_rooms.each do |r|

  # get the dorm (building) name by old id, find in new db
  d_id = Dorm.find_by(
    name:
      old_buildings.find { |b|
      b["id"] == r["building_id"] }["name"]
  ).id

  # determine capacity
  if r["single_or_double"] == "Single"
    capacity = 1
  else
    capacity = 2
  end
  
  # rename walkthrough
  is_walkthrough = r["is_walkthrough"]

  attr = Hash[r.map {|k,v| [k.to_sym, v]}]

  attr.merge!(
    dorm_id: d_id,
    capacity: capacity,
    walkthrough: is_walkthrough
  )
  attr.except!(
    :id,
    :building_id,
    :is_walkthrough,
    :single_or_double,
    :number_windows
  )

  # make 206a just the same as 206. they are the same room
  # this might not work correctly...
  if d_id == Dorm.find_by(name: "Dodd").id && attr[:number] == "206A"
    room_map[r["id"]] = DormRoom.find_by(dorm: "Dodd", number: "206")
    next
  end

  # Sewall changed room numbers, conveniently
  if d_id == Dorm.find_by(name: "Sewall").id
    sewall_map = {"91"=>"101",
                  "92"=>"104",
                  "96"=>"102",
                  "95"=>"103",
                  "101"=>"201",
                  "102"=>"203",
                  "103"=>"205",
                  "105"=>"202",
                  "104"=>"204"
                 }
    attr[:number] = sewall_map[attr[:number]]
  end

  if d_id == Dorm.find_by(name: "Gladden").id && attr[:number] == "C45"
    attr[:area] = 100
    attr[:faces] = "s"
  end

  if d_id == Dorm.find_by(name: "Wood").id && attr[:number] == "210B"
    attr[:area] = 100
    attr[:faces] = "n"
  end

  if d_id == Dorm.find_by(name: "Prospect").id && ["208", "308", "408"].include?(attr[:number])
    attr[:area] = 105
    attr[:faces] = "s"
  end
  
  begin
    ndr = DormRoom.create!(attr)
    room_map[r["id"]] = ndr.id
  rescue => error
    attr[:number].next!   # Gladden C45 is listed twice, but it should be C46.
    attr[:area] = 100
    ndr = DormRoom.create!(attr)
    room_map[r["id"]] = ndr.id
  end
end; nil




# DEPARTMENTS
puts "departments:"
depts = conn.query("SELECT DISTINCT department FROM users")
depts.each do |d|
  if d["department"] and d["department"] != "Student"
    Department.create!(name: d["department"])
  end
end; nil


# AREAS OF STUDY
puts "areas of study:"

load 'depts.rb'

old_depts = conn.query("SELECT * FROM factrak_departments")


@areas_of_study.each do |k, v|
  aos = old_depts.find { |d| d["name"] == k }
  if aos
    abbrv = aos["abbrev"]
    AreaOfStudy.create!(
      name: k,
      abbrev: abbrv,
      department_id: Department.where(name: v).first_or_create.id
    )
  end
end; nil


# USERS

puts "users:"

old_users = conn.query("SELECT * FROM users order by updated_at") #unix_id is null")
user_map = {}

old_users.each do |u|
  if u["unix_id"] == "mr2"
    u["title"] = "Visiting Assistant Professor of Sociology"
  end

  # figure out type
  if u["class_year"].to_i != 0
    if u["class_year"].to_i >=16
      type = "Student"
    else
      type = "Alum"
    end
  elsif u["alumni_id"] != nil
    type = "Alum"
  elsif (not u["department"].to_s.downcase.include?("office") and not u["department"].to_s.downcase.include?("athletic") and (u["title"].to_s.downcase.include?("professor") or u["title"].to_s.downcase.include?("lecturer")))
    type = "Professor"
  else
    type = "Staff"
  end

  # add 2000 to class year
  year = u["class_year"].to_i
  if year > 0
    year += 2000
  else
    year = nil
  end

  # TODO: figure out room id... u["room"], u["building"]
  # alumni should not have rooms
  if type == "Alum"
    dorm_room_id = nil
  else
    building = u["building"]
    if building
      if building.split(" ").first == "Sage"
        building = "Sage"
      elsif building.split(" ").first == "Williams"
        building = "Williams"
      end
    end
    
    d = Dorm.find_by(name: building)
    if d
      dorm_room_id = d.dorm_rooms.where(number: u["room"]).first_or_create.id
      office_id = nil
    else
      office = building.to_s + " " +  u["room"].to_s
      office.strip!
      if office
        office_id = Office.where(number: office).first_or_create.id
      else
        office_id = nil
      end
      dorm_room_id = nil
    end
  end

  # TODO: figure out department id. u["department"]
  dept = Department.find_by(name: u["department"])
  dept = dept ? dept.id : nil

  # TODO: turn dormtrak_policy from nil to false? maybe?
  dormtrak = !u["has_accepted_dormtrak_policy"].nil?

  if u["unix_id"].nil?
    id = u["alumni_id"]
  else
    id = u["unix_id"]
  end
  
  attr = Hash[u.map {|k, v| [k.to_sym, v]}]

  attr.each do |k,v|
    if v.nil?
      attr.except!(k)
    end
  end
  
  attr.except!(
    :id,
    :unix_id,
    :room,
    :wso_id,
    :home_street,
    :department,
    :building,
    :is_admin,
    :is_alumni,
    :home_phone,
    :neighborhood,
    :has_new_picture,
    :ephcatches,
    :class_year,
    :alumni_id
  )

  attr.merge!(
    unix_id: id,
    type: type,
    department_id: dept,
    entry: u["entry"], # AOERICAOHNITHA<>NITDANTIHA
    admin: u[:is_admin], # check this?
    office_id: office_id,
    dorm_room_id: dorm_room_id,
    class_year: year
  )
  

  if !u["williams_email"].to_s.empty? && !u["name"].to_s.empty?
    a = User.find_by(unix_id: id)
    if a
      aid = a.id
      a.destroy!
      nu = User.create!(attr)
      oldkey = user_map.find { |k,v| v == aid }.first
      user_map[oldkey] = nu.id

    else
      nu = User.create!(attr)
    end
    user_map[u["id"]] = nu.id
  end
end; nil



# COURSES
# TODO: rename arabic to arabic studies after migration
puts "courses (remember to rename arabic)"
courses = conn.query("SELECT * FROM factrak_courses")


courses.each do |c|
  old_d = old_depts.find { |d| d["id"] == c["factrak_department_id"] }["name"]
  aos = AreaOfStudy.find_by(name: old_d)
  if aos
    Course.create!(
      number: c["number"],
      area_of_study_id: aos.id,
    )
  end
end; nil


# FACTRAK SURVEYS
puts "factrak surveys"

surveys = conn.query("SELECT * FROM factrak_surveys")
survey_map = {}

surveys.each do |s|
  prof = conn.query("SELECT unix_id FROM factrak_professors WHERE id = '" + s["factrak_professor_id"].to_s + "'")
  prof = User.find_by(unix_id: prof.first["unix_id"])

  next if prof.nil? or ["asolomon", "dstevens", "jkurkowi", "ead2", "sbodner", "eaw2", "elawrenc", "kkibler", "sbolton", "bb9"].include? prof.unix_id

  if prof.unix_id == "pmurphy" or prof.unix_id == "gcaprio"
    prof.update_attributes!(type: "Professor")
    prof = Professor.find_by(unix_id: prof.unix_id)
  end

  stuid = user_map[s["user_id"]]
  if stuid.nil?
    next
  end
  
  # TODO: find course_id
  course=courses.find { |c| c["id"] == s["factrak_course_id"]}
  if course.nil?
    course_no = nil
  else
    old_d = old_depts.find { |d| d["id"] == course["factrak_department_id"] }["name"]
    dept = AreaOfStudy.find_by(name: old_d)
    course_no = dept.courses.find { |c| c.number == course["number"] }.id
  end
  
  attr = Hash[s.map {|k, v| [k.to_sym, v]}]
  
  attr.each do |k,v|
    if v.nil?
      attr.except!(k)
    end
  end
  
  attr.except!(
    :factrak_professor_id,
    :factrak_course_id,
    :user_id,
    :id
  )
  
  attr.merge!(
    professor: prof,
    course_id: course_no,
    user_id: stuid
  )

  begin
    news = FactrakSurvey.create!(attr)
  rescue
    stu = User.find_by(id: stuid)
    if stu.nil?
      next
    end
    type = stu.type
    stu.update_attributes!(type: "Student")
    news = FactrakSurvey.create(attr)
    stu.update_attributes!(type: type)
  end

  survey_map[s["id"]] = news.id

end; nil



# FACTRAK AGREEMENTS
puts "factrak_agreements"

agrees = conn.query("SELECT * FROM factrak_agreements WHERE factrak_survey_id is not null")
agrees.each do |a|

  uid = user_map[a["user_id"]]

  survey = survey_map[a["factrak_survey_id"]]
  if survey.nil?
    next
  end

  if a["agrees"] == 7 #because lets use ternary logic why not?
    next
  end
  
  attr = {
    agrees: a["agrees"],
    factrak_survey_id: survey,
    user_id: uid
  }

  begin
    FactrakAgreement.create!(attr)    
  rescue
    u = User.find_by(id: uid)
    type = u.type
    u.update_attributes!(type: "Student")
    FactrakAgreement.create!(attr)    
    u.update_attributes!(type: type)
  end
end; nil

# BULLETINS
puts "ride bulletins"
old_rides = conn.query("SELECT * FROM rides where end_date >= Now();")
old_rides.each do |r|
# don't migrate all rides, just the most recent dozen

  attr = {
    type: "Ride",
    user_id: user_map[r["user_id"]],
    body: r["notes"],
    start_date: r["end_date"],
    offer: r["is_offer"].nil? ? false : r["is_offer"],
    source: r["source"],
    destination: r["destination"],
  }

  puts attr
  
  Ride.create!(attr)
end; nil


puts "announcement bulletins:"
old_announce = conn.query("SELECT * FROM announcements")
old_announce.each do |a|

  next if a["created_at"].to_date < "jan 1 2015".to_date

  type_map = {
    2 => "Exchange",
    4 => "Job",
    3 => "LostFound",
    1 => "Announcement"
  }
  user = user_map[a["user_id"]]
  if user.nil? or User.find_by(id: user).nil? or a["body"].blank?
    next
  end

  attr = {
    type: type_map[a["section_id"]],
    user_id: user,
    title: a["summary"][0,127],
    body: a["body"],
    start_date: a["start"] || a["created_at"], 
    created_at: a["created_at"]
  }

  Bulletin.create!(attr)
  
end; nil

# DORMTRAK REVIEWS
puts "dormtrak reviews:"

old_dt_reviews = conn.query("SELECT * FROM dormtrak_reviews")
old_dt_reviews.each do |r|

  attr = Hash[r.map {|k, v| [k.to_sym, v]}]

  attr.except!(
    :id,
    :user_id,
    :single_or_double,
    :building_id,
    :building_name,
    :room_number,
    :room_id,
    :number_windows
  )

  user = user_map[r["user_id"]]
  if user.nil?
    next
  end

  attr.merge!(
    user_id: user,
    dorm_room_id: room_map[r["room_id"]]
  )

  begin
    DormtrakReview.create!(attr)
  rescue
    u = User.find_by(id: user)
    if u.nil?
      puts user, "not found"
      next
    end
    type = u.type
    u.update_attributes!(type: "Student")
    DormtrakReview.create!(attr)
    u.update_attributes!(type: type)
  end
    
    
end; nil


# DISCUSSIONS
puts "discussions:"

old_disc = conn.query("SELECT * FROM discussions")
disc_map = {}
old_disc.each do |d|

  attr = Hash[d.map {|k,v| [k.to_sym, v]}]

  if d["user_id"].nil?
    if d["ex_user_name"].nil?
      next
    else
      uid = User.where("name like ?", "#{d["ex_user_name"].split.join("%")}").first
      if uid.nil?
        next
      end
      user = uid.id
    end
  else
    user = user_map[d["user_id"]]    
  end

  if user.nil?
    next
  end
  
  attr.except!(:id, :number_replies, :user_id, :deleted)
  attr.merge!(
    user_id: user,
    deleted: d["deleted"].nil? ? 0 : d["deleted"]
  )

  begin
    nd = Discussion.create!(attr)
  rescue
    u = User.find_by(id: user)
    if u.nil?
      puts user, "not found"
      next
    end
    type = u.type
    u.update_attributes!(type: "Student")
    nd = Discussion.create!(attr)
    u.update_attributes!(type: type)
  end

  disc_map[d["id"]] = nd.id
end; nil

# POSTS
puts "posts"

old_posts = conn.query("SELECT * FROM posts")
old_posts.each do |po|

  attr = Hash[po.map {|k,v| [k.to_sym, v]}]

  if po["user_id"].nil?
    if po["ex_user_name"].nil?
      next
    else
      uid = User.where("name like ?", "#{po["ex_user_name"].split.join("%")}").first
      if uid.nil?
        next
      end
      user = uid.id
    end
  else
    user = user_map[po["user_id"]]
  end

  if user.nil?
    next
  end

  disc = disc_map[po["discussion_id"]]

  if user.nil? or disc.nil?
    next
  end
  
  attr.except!(:id, :user_id, :parent_id, :discussion_id, :deleted)

  attr.merge!(
    user_id: user,
    discussion_id: disc,
    deleted: po["deleted"].nil? ? 0 : po["deleted"]
  )

  begin
    Post.create!(attr)
  rescue
    u = User.find_by(id: user)
    if u.nil?
      puts user, "not found"
      next
    end
    type = u.type
    u.update_attributes!(type: "Student")
    Post.create!(attr)
    u.update_attributes!(type: type)
  end


end; nil
  
# +------------------------+
# | Tables_in_olddb        |
# +------------------------+
# | account_requests       |
# | games                  |
# | hoots                  |
# | keywords               |
# | keywords_organizations |
# | nicknames              |
# | nicknames_users        |
# | nightowls              |
# | organizations          |
# | people                 |
# | photos                 |
# | ride_places            |
# | schema_info            |
# | schema_migrations      |
# | scores                 |
# | sections               |
# | sessions               |
# | sheets                 |
# | signups                |
# +------------------------+
