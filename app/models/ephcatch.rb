class Ephcatch < ActiveRecord::Base
	belongs_to :user, class_name: "User"
	belongs_to :other, class_name: "User"

	validates :other_id, uniqueness: true

	def match?
		other.ephcatches.any? { |catch| catch.other == self.user }
	end

end
