class FactrakController < ApplicationController
  before_action :ensure_user
  before_action :ensure_student
  before_action :ensure_policy_acceptance, :except => [:accept_policy, :policy]
  before_action :ensure_factrak_admin, :only => [:moderate]

  ## Factrak home page. Display list of depts, 10 most recent comments.
  def index
    @comments = FactrakSurvey.commented.first(10)
    @areas = AreaOfStudy.order(:name)

    respond_to do |format|
      format.json { render json: @comments }
      format.html
    end
  end

  def moderate
    @flagged = FactrakSurvey.flagged
  end

  ## PUT flag_comment_url(:id)
  ## Flag a comment for moderator attention.
  def flag
    s = FactrakSurvey.find(params[:id])
    if !s.nil?
      s.flagged = true
      s.save
    end
    @id = params[:id]
    # Call /views/factrak/flag.js.erb to mark s as flagged
    respond_to do |format|
      format.js {}
    end
  end

  def unflag
    if current_user.factrak_admin?
      @s = FactrakSurvey.find(params[:id])
      if !@s.nil?
        @s.flagged = false
        @s.save
      end
      respond_to do |format|
        format.js {}
      end
    else
      forbidden "You don't have permission to do that"
    end
  end

  def autocomplete
    q = params[:q]
    profs = match_profs(q)[0..4]
    courses = match_courses(q)[0..4]
    course_names = []
    courses.each do |c|
      course_names.push(:title => c.to_s,
                        :id => c.id)
    end
    results = profs + course_names
    respond_to do |format|
      format.json { render :json => results.to_json }
    end
  end

  def find_depts_autocomplete
    q = params[:q]
    depts = match_depts(q)
    abbrevs = []
    depts.each do |d|
      abbrevs.push(d.abbrev)
    end
    respond_to do |format|
      format.json { render :json => abbrevs.to_json }
    end
  end

  def search
    @query = params[:search]
    # First see if they searched by a professor
    profs = match_profs(params[:search])
    if profs.length == 1
      # Single match
      redirect_to [:factrak, profs[0]]
      return
    end
    courses = match_courses(params[:search])
    if courses.length == 1
      # Single match
      redirect_to [:factrak, courses[0]]
      return
    end
    @profs = profs
    @courses = courses
    render :layout => 'factrak'
    # Nothing found.
  end

  def policy
    render :policy
  end

  def accept_policy
    if params[:accept] == "1"
      current_user.update_attributes(:has_accepted_factrak_policy => true)
      redirect_to "/factrak"
    else
      redirect_to root_path
    end
  end


  ## Admin functions to implement later

  ## Update from the ldap. Hide but don't delete no-longer-current profs. Present a list
  ## to the admin and require confirmation on all to actually delete. (This prevents us
  ## from totally hosing the database if LDAP goes haywire.

  private

  def match_courses(course)
    if course.nil? or course.empty?
      Array.new
    else
      # Yeah this is messy. Will be cleaned up later.
      parts = course.split(" ")
      depts = AreaOfStudy.where("abbrev LIKE ?", "#{parts[0]}%")
        .order("abbrev")

      if depts.empty?
        Array.new
      else
        number = parts[-1] || ""
        suggestions = []
        depts.each do |d|
          suggestions += d.courses.where("number LIKE ?", "#{number}%")
            .order("number")
            .find_all { |c| c.number != '000' }
        end
        if suggestions.empty?
          depts.each do |d|
            suggestions += d.courses
          end
        end
        return suggestions
      end
    end
  end

  def match_profs(name)
    if name.nil? or name.empty?
      Array.new
    else
      parts = name.split(" ")
      Professor.where("name LIKE ?", "%#{parts[-1]}%")
        .order("name")
        .find_all { |p| p.name.downcase.match(Regexp.new("(^|\s)#{parts[-1].downcase}"))}
        .select { |p| !Professor.find_by(unix_id: p.unix_id).nil? }
    end
  end

  def match_depts(name)
    if name.nil? or name.empty?
      Array.new
    else
      AreaOfStudy.where("name LIKE ? or name LIKE ? or abbrev LIKE ?", "#{name}%", "% #{name}%", "#{name}%")
        .order("name")
    end
  end

  def ensure_factrak_admin
    forbidden 'Only Factrak admins are allowed to use this function.' unless current_user.factrak_admin?
  end

  def ensure_policy_acceptance
    unless current_user.has_accepted_factrak_policy?
      redirect_to "/factrak/policy"
      return false
    end
  end

end
