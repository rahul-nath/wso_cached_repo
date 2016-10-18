module FacebookHelper
  require 'open-uri'

  def facebook_pic(unix, width=150, height=200)
    path = "/images/default.jpg" 
    if File.exist?("app/assets/images/user-pics/uploads/#{unix}.png")
      path = "user-pics/uploads/#{unix}.png"
    elsif File.exist?("app/assets/images/user-pics/#{unix}.jpg")
      path = "user-pics/#{unix}.jpg"
    end
    image_tag path, title: unix, size: "#{width}x#{height}"
  end

  def get_search_results

    if json_request?
      @results = facebook_search(params[:search].strip)
    else

      @searched = false # for making display options disappear and appear
      @tagline = "search"
      
      # set the view mode
      session[:facebook_results_mode] = params[:mode]
      session[:facebook_results_mode] ||= "auto"
      
      # If we got a nonempty, non whitespace search query, search.
      if params[:search] and !params[:search].strip.empty?
        @searched = true
        # If we're searching within a previous query and we have a previous query, do so.
        if params[:subsearch] and session[:facebook_query]
          if session[:facebook_query] != params[:search].strip
            session[:facebook_query] = "( #{session[:facebook_query]} ) & ( #{params[:search].strip} )"
          end
        else
          session[:facebook_query] = params[:search].strip
        end
        @search = true
        @results = facebook_search(params[:search].strip)
      else
        session[:facebook_query] = nil
      end
    end

    puts "RESULTS: #{@results}"
    
    
  end

end
