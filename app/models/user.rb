require "directory_tools"
require "search"

class User < ActiveRecord::Base
  include Search

  has_one :api_key, dependent: :destroy
  has_many :rides, dependent: :destroy

  # Bulletins
  has_many :bulletins,     dependent: :destroy
  has_many :announcements, dependent: :destroy
  has_many :exchanges,     dependent: :destroy
  has_many :jobs,          dependent: :destroy
  has_many :lost_founds,   dependent: :destroy
  has_many :rides,         dependent: :destroy

  has_many :discussions
  has_many :posts

  belongs_to :department

  # unix id must start with letter
  validates :unix_id, presence: true, uniqueness: true
  validates :williams_email, presence: true
  validates :name, presence: true

  before_save :index
  # after_save :create_api_key

  def self.with_access_token(token)
    ApiKey.where(access_token: token).first.try(:user)
  end

  def self.search(q)
    query = FacebookQuery.new(q.downcase)
    if q.length > 0
      begin
        results = query.results
      rescue QuerySyntaxError => e
        @syntax_error = "<p>#{e.message}</p>"
        @syntax_error += e.show_error do |source, pos_1, length_1, pos_2, length_2|
          err_begin = "<span class=\"highlight_error\">"
          err_end = "</span>"
          source.insert(pos_1, err_begin)
          source.insert(pos_1 + length_1 + err_begin.length, err_end)
          if pos_2
            source.insert(pos_2 + err_begin.length + err_end.length, err_begin)
            source.insert(pos_2 + length_2 + err_begin.length * 2 + err_end.length, err_end)
          end
          "<p><span class=\"box\">#{source}</span></p>"
        end
        return Array.new
      end
      results.find_all { |u| u.visible? }
    else
      Array.new
    end
  end

  def index
    if !visible?
      search_fields = nil
    elsif !at_williams?
      search_field = nil
    else
      fields = Hash.new
      [:name, :unix_id, :title, :class_year, :major, :su_box, :entry].each do |attr|
        fields[attr] = self[attr]
      end
      fields[:room] = room_string if dorm_visible? && room_string
      fields[:home] = home_address if home_visible?
      self.search_fields = fields.values.join("#")
    end
  end

  def student?
    type == "Student" && !graduated?
  end

  def alum?
    type == "Alum"
  end


  ## Is this a user who is currently at williams?
  ## We decide this by asking if they have an OIT login and they, if students, haven't graduated
  ## We check whether a person has graduated by checking if his class year has passed,
  ## which it to say a person's record won't be seen half year after his graduation in June
  ## "Current" users are in and can see the facebook.
  def at_williams?
    unix_id? && !alum? ## this may be incorrect. we should do an ldap poll, assuming ldap shows abroad users
  end

  def name_string
    name.blank? ? email : name
  end

  def email
    if williams_email && !williams_email.empty?
      williams_email
    elsif unix_id && !unix_id.empty?
      if alum?
        "#{unix_id}@alumni.williams.edu"
      else
        "#{unix_id}@williams.edu"
      end
    end
  end

  def room_string
  end

  def home_address
    if home_visible?
      [home_town, home_state, home_country == "United States" ? nil : home_country].compact.join(", ")
    end
  end

  def refresh!
    attrs = User.ldap_lookup(unix_id).first
    if attrs
      return update_attributes(attrs)
    else
      return false
    end
  end


  # Uses LDAP and Ph (major) to find user attributes, given a user's unix.
  # Call with unix_id as * to look up everyone
  # Returns list of attr hashes that LDAP returned
  def self.ldap_lookup(unix_id, ldap=DirectoryTools::Ldap.new(ENV["WSO_LDAP_DN"], ENV["WSO_LDAP_PW"]))
    results = []
    ldap.each_user("uid", unix_id) do |u|
      attrs = {
        :unix_id => u["uid"],
        :name => u["cn"],
        :williams_email => ( u["mail"] ? u["mail"].sub(/@williams\.edu/, "") : nil ),
        #:department => u["ou"],
        :visible => u[:visible] != false
      }
      if u["wmsClass"]
        attrs[:class_year] = u["wmsClass"].to_i + 2000
      end
      return attrs unless attrs[:visible]
      attrs[:home_country] = u["wmsHomeCountry"]
      attrs[:home_state] = u["wmsHomeState"]
      attrs[:home_town] = u["wmsHomeCity"]
      attrs[:home_zip] = u["wmsHomePostal"]
      attrs[:cell_phone] = u["wmsCellPhone"]
      attrs[:title] = u["title"]
      attrs[:campus_phone_ext] = u["telephoneNumber"][-4..-1] if u["telephoneNumber"] and !u["telephoneNumber"].empty?
      # Student things
      if (attrs[:class_year]) && (attrs[:class_year].to_i >= Date.today.year % 2000)
        if u["wmsDormAddr1"].present?
          dorm = Dorm.where(name: u["wmsDormAddr1"]).first
          if dorm.nil?
            logger.warn "Encountered unknown dorm: #{u['wmsDormAddr1']}"
          else
            attrs[:dorm_room] = DormRoom.where(dorm: dorm, number: u["wmsDormAddr2"]).first_or_create
          end
        end
        attrs[:su_box] = u["wmsCampusAddr1"]
        if false
          begin
            # Not dealing with this slowness right now. It is a bit ridiculous
            ph = DirectoryTools::Ph.new.query("unix=#{unix_id}").first
            if ph
              attrs[:major] = ph["curriculum"] if ph["curriculum"]
            end
            ph.disconnect
          rescue Timeout::Error
          end
        end
      # Facstaff things
      else
        number = "#{u['wmsCampusAddr1']} #{u['wmsCampusAddr2']}"
        attrs[:office] = Office.where(number: number).first_or_create
        attrs[:department] = Department.where(name: u["ou"][0..u["ou"].index(" Department") || -1]).first_or_create if u["ou"]
      end
      #return attrs
      results.push(attrs)
    end
    return results
    #return nil
  end


  def self.find_or_create_from_unix_id(unix_id)
    return nil unless self.valid_unix_id(unix_id)

    # return User with given unix
    user = User.find_by(unix_id: unix_id)
    return user if user

    # create
    attrs = User.ldap_lookup(unix_id).first
    if attrs
      if attrs[:title].to_s.downcase.include?("professor")
        return Professor.create!(attrs)
      elsif attrs[:class_year]
        if attrs[:class_year].to_i < Date.today.year
          raise "Class year too low for students on: " + attrs.to_s 
        else
          return Student.create!(attrs)
        end        
      else
        return Staff.create!(attrs)
      end
    else
      return nil
    end
  end

  def self.update_all_from_ldap
    Student.all.each do |student|
      if student.graduated?
        # Not sure what else we should remove
        student.type = "Alum"
        student.dorm_room = nil
        student.save
      end
    end

    attrs_list = User.ldap_lookup("*")
    attrs_list.each do |attrs|
      u = User.find_by(unix_id: attrs[:unix_id]) || User.new
      u.update!(attrs) rescue logger.warn "Could not save user with: #{attrs}"
    end
  end


  def has_temp_pic?
    File.exists?("#{Rails.application.config.user_pic_upload_dir}/#{unix_id}.jpg")
  end

  def owns?(model)
    model.user == self || admin?
  end  

  private

  def create_api_key
    ApiKey.create!(user: self)
    #ApiKey.create(user: self, expires_at: (Time.now + 60.days).to_i, access_token: SecureRandom.hex)
  end

  def self.valid_unix_id(unix_id)
    unix_id && unix_id.match(/^\w+$/)
  end

  def remove_directory_info!
    cell_phone = nil
    campus_phone_ext = nil
    room = nil
    su_box = nil
    home_town = nil
    home_zip = nil
    home_phone = nil
    major = nil
    entry = nil
    title = nil
    class_year = nil
    home_state = nil
    home_country = nil
    save!
  end

end
