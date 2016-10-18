module ImageProcess

  class ProfilePictureMaker
  
    def initialize(user)
      @user = user
    end

    def create_from_blob(pic_blob)
      # Overview: Some large bug that isn't our problem causes it to have
      # to be done this way. Save the file they give us in a temp, 
      # then open it with MiniMagick, do stuff, save that, and rm tmp
      path = Rails.root.join "#{Rails.application.config.user_pic_upload_dir}/#{@user.unix_id}tmp"
      File.open(path, "wb") do |f|
        f.write(pic_blob.read)
        f.close
      end
      pic = MiniMagick::Image.open(path)
      # png is numba 1
      pic.format "png"
      # smartphones store rotation info in EXIF data. Most fancy programs
      # know how to handle that exif data automatically, so Preview, for
      # example, will display it right. However, we need to do this
      # manually, otherwise photos will potentially get sent to us
      # rotated. 
      pic.auto_orient
      # Fix sizing
      crop_and_resize(pic, PIC_WIDTH, PIC_HEIGHT)
      # Write to the uploads subdirectory in user-pics. The facebook
      # helper will test to try to find this image before using one
      # of the default images.
      File.delete(path)  # Remove the tmp image
      pic.write("app/assets/images/user-pics/uploads/" + @user.unix_id + ".png")
      # Could cause write errors or pic errors
    end
  end
  
  class Cropper
        
    def crop_and_resize(pic, width, height)
      # It's late, I'm tired. This isn't ideal.
      curr_ratio = (pic[:width].to_f / pic[:height].to_f).round(2)
      need_ratio = (width.to_f / height.to_f).round(2)
      if curr_ratio == need_ratio
        # It means our thingy is a good ratio already, so just
        # scale it
      elsif curr_ratio < need_ratio
        # Height is too big. Find how much we need to shave off
        # to fix the ratio (not that shave takes off a little
        # from both sides, so we'll divide the cut amount by 2).
        # Just set up the equation and do some algebra.
        amt = (pic[:height].to_f-(pic[:width].to_f/need_ratio))
        amt /= 2 # (it shaves from both sides)
        pic.shave("0x#{amt}")
      elsif
        curr_ratio > need_ratio
        # Width is too big. Same deal as above.
        amt = (pic[:width].to_f-pic[:height]*need_ratio)
        amt /= 2
        pic.shave("#{amt}x0")
      end
      # We have the right ratio now, so just rescale
      #pic.resize("150x200")
    end
  end
  
end
