# frozen_string_literal: true

class Api::LikingUsersController < ApplicationController
  def index
    blog = Blog.find(params[:blog_id])
    @users = blog.liking_users.order(:id)
    my_liking = blog.likings.find_by(user: current_user)
    @destroy_path = my_liking ? api_blog_liking_path(blog, my_liking, format: :json) : nil

    render json: { users: @users.as_json(only: %i[nickname]), destroy_path: @destroy_path }
  end
end
