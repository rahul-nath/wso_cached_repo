require 'image_process'

class UsersController < ApplicationController
  include ImageProcess

  MAX_PIC_FILE_SIZE = 1.megabyte
  PIC_WIDTH = 150
  PIC_HEIGHT = 200

  layout 'facebook'

  before_action :ensure_campus_or_at_williams, except: :update
  before_action :ensure_user, only: :update

  def show
    @view_person = User.find_by(id: params[:id])

    if @view_person.nil?
      flash[:notice] = "That person does not exist."
      redirect_to facebook_path

    elsif !@view_person.visible?
      flash[:notice] = "That #{@view_person.class} is not visible."
      redirect_to facebook_path

    elsif !@view_person.at_williams?
      flash[:notice] = "That #{@view_person.class} is no longer at Williams."
      redirect_to facebook_path
    end
  end

  def update
    return head :forbidden unless current_user.id == params[:id].to_i

    changes = params[:user] || params[:student] || params[:professor] || params[:staff] # Temp hack
    if changes
      [:home_visible, :dorm_visible, :visible].each do |attr|
        current_user[attr] = changes[attr] unless changes[attr].nil?
      end
      current_user.save

      # Update profile picture
      if changes[:pic_file] and changes[:pic_file].size > 0
        update_profile_pic
      end
    end
    redirect_to "/facebook/edit"
  end

  private

  def update_profile_pic
    pic_blob = params[:user][:pic_file]

    if pic_blob.size <= MAX_PIC_FILE_SIZE
      begin
        maker = ProfilePictureMaker.new(current_user)
        maker.create_from_blob(pic_blob)
      rescue
        flash[:notice] = "There was an error uploading your photo."
      else
        current_user.has_new_picture = true
        current_user.save
        flash[:notice] = "All account changes saved successfully"
      end
    else
      flash[:notice] = "Photo too large"
    end
  end

end
