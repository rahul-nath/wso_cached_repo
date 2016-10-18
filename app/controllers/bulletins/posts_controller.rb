class Bulletins::PostsController < ApplicationController

  def create
    # Thread creation
    unless params[:post][:discussion_id]
      @thread = current_user.discussions.build(title: params[:post][:title],
                                               last_active: Time.now)
      @post = current_user.posts.build(post_params)
      @post.discussion = @thread
      if @thread.valid? && @post.valid?
        @thread.save!
        @post.save!
        redirect_to @thread
      else
        @post.valid? # populate .errors without saving
        render "bulletins/discussions/new", :layout => 'discussions'
      end
    # Reply
    else
      @post = current_user.posts.create(post_params)
      respond_to do |format|
        format.js {}
      end
    end
  end

  def edit
    @post = Post.find_by(id: params[:id])
    if @post.user == current_user || current_user.admin?
      respond_to do |format|
        format.js {}
      end
    else
      redirect_to "/discussions"
    end
  end

  def update
    p = Post.find(params[:id])
    if p.user == current_user
      p.content = params[:post][:content]
      p.save
    end
    redirect_to p.discussion
  end

  def destroy
    @p = Post.find(params[:id])
    if current_user == @p.user || current_user.admin?
      # Note we're not actually deleting anything
      @p.deleted = true
      @p.save
      if !@p.discussion.children.any?
        @p.discussion.deleted = true
        @p.discussion.save
      end
      respond_to do |format|
        format.js {}
      end
    else
      redirect_to "/discussions"
    end
  end

  private

  def post_params
    params.require(:post).permit(:content, :title, :discussion_id)
  end

end
