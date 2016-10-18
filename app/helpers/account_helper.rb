module AccountHelper

  def upload_picture
    # grab the uploaded picture for approval
    if params[:pic_file] && params[:pic_file].size > 0 && params[:pic_file].size <= MAX_PIC_FILE_SIZE
      # TODO: make sure to check the content-type or catch RMagick errors...
      pic = Magick::Image.from_blob(params[:pic_file].read)[0].crop_resized(150, 200)
      if current_user.admin?
        pic.write("#{Rails.application.config.user_pic_dir}/#{current_user.unix_id}.jpg")
        flash[:saved_items].push "picture"
      else
        pic.write("#{Rails.application.config.user_pic_upload_dir}/#{current_user.unix_id}.jpg")
        flash[:messages].push "Uploaded picture for approval."
      end
    else
      flash[:messages].push "Uploaded picture was larger than the 1MB limit."
    end
  end

  def update_cell_phone
    # save new cell phone
    if current_user.cell_phone != params[:cell_phone]
      flash[:saved_items].push :cell_phone
      current_user.cell_phone = params[:cell_phone]
    end
  end

  def update_visible
    # does the user want to be shown in facebook?
    current_user.visible = params[:visible]
  end
  
  def update_home_visible
    # does the user want their home phone/address to be shown in facebook?
    current_user.home_visible = params[:home_visible]
  end

  def update_name
    user.name = params[:name] if params[:name]
  end

  def valid_wso_id?
    params[:wso_id] && params[:wso_id].length > 1
  end
  

end
