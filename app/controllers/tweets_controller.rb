class TweetsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def index
    @tweets = Tweet.all.order(created_at: :desc)
    render 'tweets/index' # can be omitted
  end

  def index_by_user
      @user = User.find_by(username: params[:username])

      if @user
        @tweets = @user.tweets.order(created_at: :desc)
        render 'tweets/index' # can be omitted
      else
        render json: { tweets: [] }
      end
  end

  def create
    token = cookies.signed[:twitter_session_token]
    session = Session.find_by(token: token)

    if session
      @user = session.user
      @tweet = @user.tweets.new(tweet_params)

      if @tweet.save
        render 'tweets/create'
      else
        render json: { success: false }
      end
    else
      render json: { success: false }
    end
  end

  def destroy
    token = cookies.signed[:twitter_session_token]
    session = Session.find_by(token: token)

    if session
      @tweet = Tweet.find_by(id: params[:id], user_id: session.user.id)
      if @tweet&.destroy
        render json: { success: true }
      else
        render json: { success: false }
      end
    else
      render json: { success: false }
    end
  end

  def mark_complete
    @tweet = Tweet.find_by(id: params[:id])

    render 'tweets/update' if @tweet&.update(completed: true)
  end

  def mark_active
    @tweet = Tweet.find_by(id: params[:id])

    render 'tweets/update' if @tweet&.update(completed: false)
  end

  private

  def tweet_params
    params.require(:tweet).permit(:message)
  end

end
