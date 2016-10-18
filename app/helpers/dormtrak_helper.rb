module DormtrakHelper

  def photo_for(dorm)
    # Return main photo for that dorm
    path = "banners/#{dorm.name.titleize}.png"
    image_tag(path, title: "(photo by Doug Schiazza)", width: "100%")
  end

  def avatar_for(dorm)
    path = "avatars/#{dorm.name.titleize}.png"
    image_tag(path, title: dorm.name)
  end

  def small_avatar_for(dorm)
    # Each are 300 x 154. This is for recent comments
    path = "avatars/#{dorm.name.titleize}.png"
    image_tag(path, title: dorm.name, size: '150x77')
  end
end
