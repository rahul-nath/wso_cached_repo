module ApplicationHelper

  YES = %w(yes 1 true t)

  def to_boolean(param)
    YES.include? param.downcase
  end

  def string_to_datetime(string)
    DateTime.strptime(string, "yyyy-MM-d'T'HH:m:s.SZ")
  end

  def json_request?
    request.format.json?
  end

  def logged_in?
    !current_user.nil?
  end

  def on_campus?
    WsoTools::Net.on_campus?(request.remote_ip)
  end

  def at_williams?
    current_user.try(:at_williams?)
  end

  def student?
    current_user.try(:student?)
  end

  def admin?
    current_user.try(:admin?)
  end

  def set_current_user_from_unix_id(unix_id)
    @current_user = User.find_or_create_from_unix_id(unix_id)
    session[:current_user_id] = @current_user.try(:id)
    @current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:current_user_id])
  end

  def current_user=(user)
    @current_user = user
  end

  # given kmc3@williams.edu, returns kmc3
  # given kmc3, returns kmc3
  def unix_from_email(email)
    end_unix = email.index("@")
    end_unix = end_unix ? end_unix - 1 : -1
    email[0..end_unix]
  end

end
