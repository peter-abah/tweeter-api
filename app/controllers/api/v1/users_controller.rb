module Api
  module V1
    class UsersController < ApplicationController
      include Paginate
      include Filterable

      before_action :authenticate_request!, only: %i[update destroy]

      def index
        users = filter(User.all.includes(
          profile_image_attachment: :blob,
          cover_image_attachment: :blob
        ))
        users = paginate(users)
        render json: Representer.new(users).as_json, status: :ok
      end

      def followers
        users = filter(user.followers)
        users = paginate(users)
        render json: Representer.new(users).as_json, status: :ok
      end

      def followed_users
        users = filter(user.followed_users)
        users = paginate(users)
        render json: Representer.new(users).as_json, status: :ok
      end

      def create
        user = User.create(user_params)

        if user.save
          render json: user_json(user), status: :created
        else
          render json: { error: user.errors.full_messages.first }, status: :unprocessable_entity
        end
      end

      def show
        render json: Representer.new(user).as_json, status: :ok
      end

      def update
        if user != @current_user
          render json: { error: 'forbidden' }, status: :forbidden
          return
        end

        if @current_user.update(user_params)
          render json: user_json(@current_user), status: :ok
        else
          render json: { error: @current_user.errors.full_messages.first }, status: :unprocessable_entity
        end
      end

      def destroy
        if user != @current_user
          render json: { error: 'forbidden' }, status: :forbidden
          return
        end

        @current_user.destroy
        render status: :no_content
      end

      private

      def user
        User.includes(%i[profile_image_attachment cover_image_attachment]).find(params[:id])
      end

      def user_json(user, options = {methods: [:authentication_token]})
        Representer.new(user, options).as_json
      end

      def user_params
        params.require(:user).
          permit(:username, :password, :password_confirmation, :first_name, 
                 :last_name, :email, :profile_image, :cover_image)
      end
    end
  end
end
