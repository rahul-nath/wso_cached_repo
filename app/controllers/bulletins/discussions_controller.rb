class Bulletins::DiscussionsController < ApplicationController
  before_action :ensure_user

  require 'will_paginate/array'

  layout 'discussions'

  def index
    @threads = Discussion.alive.paginate(page: params[:page], per_page: 20)

    respond_to do |format|
      format.json { render json: Discussion.alive }
      format.html { render :index }
    end
  end

  def show
    @thread = Discussion.find(params[:id])
    @posts = @thread.children
    @reply = Post.new

    respond_to do |format|
      format.json { render json: @thread.to_json(include: [:posts])}
      format.html { render :show }
    end

  end

  # Users don't create threads. They create Posts, and depending on the
  # context in which the Post was created, we might auto-create a Thread
  def new
    @thread = Discussion.new
    @post = Post.new
  end

  def destroy
    d = Discussion.find(params[:id])
    d.update_attributes(deleted: true) if current_user.admin?
    redirect_to "/discussions"
  end

end
