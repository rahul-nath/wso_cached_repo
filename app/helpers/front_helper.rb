module FrontHelper

  require 'yaml'

  def random_wso
    words_file = Rails.application.config.words_file
    words = nil
    if File.exists?(words_file)
      words = YAML.load_file(words_file)
      "#{words[:w][rand(words[:w].size)]} #{words[:s][rand(words[:s].size)]} #{words[:o][rand(words[:o].size)]}"
    else
      "Williams Students Online"
    end
  end

  def link_to_all_from_one(resource)
    model_name = resource.class.name.underscore.pluralize
    title = resource.class.title
    eval("link_to '#{title}', #{model_name}_path")
  end

  def time_if_today_else_date(datetime)
    # If old, return date. If today, show time.
    if datetime.to_date == Date.today
      "Today"
    else
      datetime.strftime("%a, %b %e")
    end
  end

end
