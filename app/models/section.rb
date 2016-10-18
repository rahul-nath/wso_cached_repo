class Section < ActiveRecord::Base
  #attr_accessible :name, :number_items
  validates :name, presence: true
  has_many :announcements
  

  #set_primary_key "name"

  def to_param
    name
  end
  
  def self.find_by_name_or_id(section_id)
    Section.where("name = ? OR id = ?", section_id, section_id).first
  end
end
