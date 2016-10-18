require 'mysql2'

van = Mysql2::Client.new(:host => "localhost", :username => "wso_on_rails",
                         :database => "vanilla",
                         :password => "i0Ta7R0n$Tud135")

Discussion.all.each do |disc|
  id = disc.id
  q = van.query("select authuserid from lum_discussion where discussionid = " +
                id.to_s)
  authid = q.first["authuserid"]
  q = van.query("select name, firstname, lastname from lum_user " + 
                "where userid = " + authid.to_s)
  if q.any?
    per = q.first
    unix = per["name"]
    name = per["firstname"] + " " + per["lastname"]
    if !unix || !name
      puts per
      puts name
      puts unix
      break
    end
    u = User.find_by(unix_id: unix)
    if u
      disc.user_id = u.id
    else
      disc.user_id = nile
      disc.ex_user_name = name
    end
    disc.save
  end
end

exit
x = <<EOF

results = van.query("SELECT DiscussionID, AuthUserID, DateLastActive, Name, " +
                    "DateCreated, CountComments FROM LUM_Discussion")
results.each do |row|
  begin
    disc = Discussion.new(:id          => row["DiscussionID"],
                          :lum_id      => row["DiscussionID"],
                          :last_active => row["DateLastActive"],
                          :created_at  => row["DateCreated"],
                          :title       => row["Name"],
                          :number_replies => row["CountComments"])
    ppl = van.query("SELECT Name, FirstName, LastName FROM LUM_User WHERE " +
                    "UserID = " + row["AuthUserID"].to_s)
    if !ppl.any?
      next
    end
    person = ppl.first
    u = User.find_by(unix_id: person["Name"]) 
    if u
      disc.user_id = u.id
    else
      disc.ex_user_name = person["FirstName"] + " " + person["LastName"]
    end
    disc.save
  rescue
    puts row
    break
  end
end

results = van.query("SELECT AuthUserId, DateCreated, DateEdited, Body, " + 
                    "Deleted, CommentID, DiscussionID FROM LUM_Comment")
presults.each do |row|
  begin
    post = Post.new(:id         => row["CommentID"],
                    :created_at => row["DateCreated"],
                    :updated_at => row["DateEdited"],
                    :content    => row["Body"],
                    :deleted    => row["Deleted"],
                    :discussion_id => row["DiscussionID"])
    ppl = van.query("SELECT Name, FirstName, LastName FROM LUM_User WHERE " +
                    "UserID = " + row["AuthUserId"].to_s)
    if !ppl.any?
      next
    end
    person = ppl.first
    u = User.find_by(unix_id: person["Name"]) 
    if u
      post.user_id = u.id
    else
      post.ex_user_name = person["FirstName"] + " " + person["LastName"]
    end
    post.save
  rescue => error
    puts error.backtrace
    puts error.message
    puts row
    puts person
    break
  end
end

EOF
