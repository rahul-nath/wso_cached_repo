class EphcatchController < ApplicationController

	before_action :ensure_senior_week
	before_action :ensure_user
	before_action :ensure_senior

	SENIOR_WEEK_BEGIN = Time.new(Time.now.year, 5, 15, "+0:00")

	def index
		@seniors = Student.seniors.sort_by(&:name) - [current_user]
	end

	def matches
		@matches = current_user.ephcatch_matches
	end

	def create
		current_user.ephcatches.create(other_id: params[:id])
	end

	def destroy
		current_user.ephcatches.destroy(params[:id])
	end

	private

	def ensure_senior_week
		unless Time.now >= SENIOR_WEEK_BEGIN
			redirect_to root_path
			flash[:notice] = "It's not time for ephcatch yet"
		end
	end

	def ensure_senior
		unless current_user.student? && current_user.senior?
			redirect_to root_path
			flash[:notice] = "Seniors only!"
		end
	end

end
