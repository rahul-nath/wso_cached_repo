# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

require "timecop"
require "csv"


Fabrication.configure do |config|
  config.fabricator_path = 'spec/fabricators'
  config.path_prefix = Rails.root
  config.sequence_start = 10000
end


################
## DORM SETUP ##
################

Dorm.destroy_all
Neighborhood.destroy_all

neighborhoods = %w(Currier Wood Spencer Dodd First-year Co-op)
neighborhoods.each { |n| Neighborhood.create(name: n) }

mission = ['Dennett', 'Mills', 'Armstrong', 'Pratt']
frosh   = ['Sage', 'Williams']

stime = Time.now
# Create the dorm with basic info like number doubles
CSV.foreach('building-info.csv', headers: true) do |row|
  hash = row.to_hash
  hood_name = hash.delete("neighborhood_name")
  hood = Neighborhood.find_by(name: hood_name)
  hood.dorms.create!(hash)
end
puts "Dorms: #{Time.now - stime}"

stime = Time.now
# Create the rooms
Dorm.all.each do |dorm|
  # next if dorm.rooms.any? # what is this for?
if dorm.neighborhood.name != "First-year" && dorm.neighborhood.name != "Co-op"
    # Currently no data for first-year or co-op housing
    # Path to csv
    path = 'roominfo/' + dorm.name + '.csv'
    # Open the CSV
    csv = CSV.read(path, :headers => true)
    # Process each room (a row) in the CSV
    r_index = 0
    csv.each do |r|
      r_index += 1
      break if r_index > 20
      # start making an empty room...
      room = dorm.dorm_rooms.build()
      room.number = r["number"]
      room.floor_number  = r["floor"].to_i
      room.capacity = r["single_or_double"].downcase == "s" ? 1 : 2
      dirs = r["faces"].split(',')      
      dirstr = ""
      dirs.each do |d|
        if d.downcase == "n"
          dirstr += "North, "
        elsif d.downcase == "e"
          dirstr += "East, "
        elsif d.downcase == "s"
          dirstr += "South, "
        else
          dirstr += "West, "
        end        
      end
      # Remove final comma and space
      dirstr = dirstr[0..-3]
      room.faces = dirstr
      room.area = r["area"].to_i
      if r["common_room_access"].to_i == 0
        room.common_room_access = false
      else
        room.common_room_access = true
      end
      # Finalize the room
      room.save
    end
  end  
end
puts "Rooms: #{Time.now - stime}"

areas = JSON.parse(File.read("#{Rails.root}/data/areas_of_study.json"))
areas.each do |area_hash|
  dept_hash = area_hash.delete("department")
  Department.where(dept_hash).first_or_create.areas_of_study.create(area_hash)
end

# A few important default users
Fabricate(:student, unix_id: "student", dorm_room: DormRoom.all.sample, admin: false) unless User.find_by(unix_id: "student")
Fabricate(:student, unix_id: "admin", admin: true, dorm_room: DormRoom.all.sample) unless User.find_by(unix_id: "admin")
Fabricate(:professor, unix_id: "prof") unless User.find_by(unix_id: "prof")
Fabricate(:staff, unix_id: "staff") unless User.find_by(unix_id: "staff")

# for android testing
Fabricate(:student, unix_id: 'kmc3') unless User.find_by(unix_id: "kmc3")

a = ApiKey.new(user: User.find_by(unix_id: "admin"), expires_at: (Time.now+60.days).to_i, access_token: SecureRandom.hex)
a.save

stime = Time.now
# Create Students for some rooms
DormRoom.open.sample(100).each do |room|
  Fabricate.times(room.capacity, :student, dorm_room: room)
end
puts "Fill rooms: #{Time.now - stime}"

stime = Time.now
# Let's assume just students for now
Student.all.each do |stud|

  # Make discussions
  1.times do
    discussion = Fabricate.build(:discussion, user: stud)
    discussion.posts << Fabricate(:post, user: stud, discussion: discussion)
    discussion.save
  end

  # Make dorm reviews
  Fabricate(:dormtrak_review, user: stud, dorm_room: stud.dorm_room)

  # Make factrak surveys
  2.times do
    dept = Department.all.sample    

    until (p = Fabricate.build(:professor, department: dept, visible: true)).valid?
      next
    end
    p.save

    aos = dept.areas_of_study.sample
    c = Fabricate(:course, area_of_study: aos)
    Fabricate(:factrak_survey, user: stud, professor: p, course: c)
  end
end
puts "Student things: #{Time.now - stime}"

stime = Time.now
[-1, 0].each do |i|
  Timecop.freeze(Time.zone.now + i.days) do
    # Make each bulletin subtype
    [:exchange, :job, :lost_found].each do |bulletin|
      Fabricate.times(10, bulletin, created_at: Time.zone.now, updated_at: Time.zone.now)
    end
  end
end

2.times do
  (-2..2).each do |i|
    Timecop.freeze(Date.today + i.days) do
      past_date = Date.today
      Fabricate(:announcement, start_date: past_date)
      Fabricate(:ride, start_date: past_date)
    end
  end
end
puts "Bulletins: #{Time.now - stime}"
