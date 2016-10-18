# Ripper for getting information for Dormtrak, including class breakdowns

require 'Date'
require 'csv'

# WARNING: this creates all new buildings using data
# provided in the csv

Dorm.destroy_all

CSV.foreach('building-info.csv', headers: true) do |row|
  hash = row.to_hash
  n = row[1]
  hood = Neighborhood.find_by(name: n)
  hood.buildings.create!(hash)
end


mission = ['Dennett', 'Mills', 'Armstrong', 'Pratt']
frosh   = ['Sage', 'Williams']

SENIOR = Date.today.year
if Date.today.month > 7
  # ie you're a senior if its fall of your senior year
  SENIOR += 1
end
JUNIOR =    SENIOR + 1
SOPHOMORE = SENIOR + 2
FRESHMEN  = SENIOR + 3

Dorm.all.each do |b|
  # Reset all counts
  b.seniors    = 0
  b.juniors    = 0
  b.sophomores = 0
  b.freshmen   = 0
  b.save
end

User.all.each do |u|
  yr = 2000 + (u.class_year.to_i % 2000) # maybe year appears as 2016 sometimes
  b = nil # look for building
  # Freshman buildings have things like Sage F. Just want Sage
  froshyname = u.building.to_s.split(' ')[0] # get first word of two word name
  if (mission+frosh).include?(froshyname)    # check for name in fquad/mission
    if mission.include?(froshyname)
      b = Building.find_by(name: "Mission Park") # all mission entries as same
    elsif frosh.include?(froshyname)
      b = Building.find_by(name: "Frosh Quad") # all quad entries as same
    end
  else
    # Not a freshmen building. do a normal search for it
    b = Building.find_by(name: u.building)
  end
  if b # Found a house (note: other buildings are buildings. only want houses)
    if yr == SENIOR
      b.seniors += 1
    elsif yr == JUNIOR
      b.juniors += 1
    elsif yr == SOPHOMORE
      b.sophomores += 1
    elsif yr == FRESHMEN
      b.freshmen += 1
    end
    b.save # or just get all buildings after and save them 1 by 1.
  end
end

Building.all.each do |b|
  b.capacity = b.number_singles + b.number_doubles*2
  b.bathroom_ratio = (b.capacity.to_f / b.number_bathrooms.to_f).round(2)
  b.save
end

