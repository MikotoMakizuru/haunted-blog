# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]
  before_action :browsable_user!, only: %i[show]

  def index
    @blogs = if params[:term].present?
               sanitized_term = ActiveRecord::Base.sanitize_sql_like(params[:term])
               Blog.where('title LIKE ?', "%#{sanitized_term}%").published.default_order
             else
               Blog.published.default_order
             end
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def authorize_user!
    raise ActiveRecord::RecordNotFound unless @blog.user == current_user
  end

  def browsable_user!
    raise ActiveRecord::RecordNotFound if @blog.secret? && @blog.user != current_user
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch).tap do |permitted_params|
      permitted_params[:random_eyecatch] = false if permitted_params[:random_eyecatch] && !current_user.premium
    end
  end
end
