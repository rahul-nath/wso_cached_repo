# Utility to fill in rooms for each building with data from csv files
# Hopefully this will just be executed once...
# LOAD DODD AFTERWARDS !!!!!!!!!!!!!!!!!!!!!!!!!

require 'csv'

Building.all.each do |b|
  if b.rooms.any?
    next
  end
  if b.neighborhood_name != "First-year" && b.neighborhood_name != "Co-op"
    # Currently no data for first-year or co-op housing
    # Path to csv
    path = 'roominfo/' + b.name + '.csv'
    # Open the CSV
    csv = CSV.read(path, :headers => true)
    # Process each room (a row) in the CSV
    csv.each do |r|
      # start making an empty room...
      room = b.rooms.build()
      room.number = r["number"]
      room.floor_number  = r["floor"].to_i
      if r["single_or_double"].downcase == "s"
        room.single_or_double = "Single"
      else
        room.single_or_double = "Double"
      end
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
