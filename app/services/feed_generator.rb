class FeedGenerator
  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  def feed
    tweets = users.reduce([]) do |acc, user|
      acc.concat(user.tweets, user.retweets, user.likes)
    end

    tweets.count < 25 ? pad_tweets(tweets) : tweets
  end

  def random_tweets(n = 25)
    Tweet.order('RANDOM()').take(n)
  end

  private

  # returns users that current_user follows and users that current_user
  # followed users follow
  def users
    current_user.followed_users
  end

  def pad_tweets(tweets)
    diff = 25 - tweets.count
    tweets + random_tweets(diff)
  end
end
