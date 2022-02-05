require 'rails_helper'

RSpec.describe "Retweets", type: :request do
  let!(:user) { FactoryBot.create!(:user) }
  let!(:tweets) { FactoryBot.create_list!(:tweet, 5, user: user) }
  let(:tweet) { tweets.first }
  let!(:retweets) do
    tweets.each { |tweet| Retweet.create!(user_id: user.id, tweet_id: tweet.id) }
  end
  let(:retweet) { retweets.first }

  describe 'GET /retweets' do
    context 'when user_id is provided' do
      it 'returns retweets for user' do
        get '/api/v1/retweets', params: { user_id: user.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(5)
      end
    end

    context 'when tweet_id is provided' do
      it 'returns retweets for tweet' do
        get '/api/v1/retweets', params: { tweet_id: tweet.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(1)
      end
    end
  end

  describe 'GET /retweets/:retweet_id' do
    it 'returns the specific retweet' do
      get "/api/v1/retweets/#{retweet.id}"

      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json['id']).to eq(retweet.id)
    end
  end

  describe 'POST /retweets' do
    it 'creates a new retweet' do
      post '/api/v1/retweets', params: { user_id: user.id, tweet_id: tweet.id },
                               headers: { 'Authentication': AuthenticationTokenService.call(user.id) }

      updated_tweet = Tweet.find(tweet.id)
      updated_user = User.find(user.id)

      expect(response).to have_http_status(:ok)
      expect(updated_tweet.retweets.size).to eq(2)
      expect(updated_user.retweets.size).to eq(6)
    end

    it 'returns unauthorized if authorization missing' do
      post '/api/v1/retweets', params: { user_id: user.id, tweet_id: tweet.id }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized if authorization is invalid' do
      post '/api/v1/retweets', params: { user_id: user.id, tweet_id: tweet.id },
                               headers: { 'Authentication': 'awrongtoken123456' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /retweets/:retweet_id' do
    it 'deletes a particular tweet' do
      delete "/api/v1/retweets/#{retweet.id}", headers: { 'Authentication': AuthenticationTokenService.call(user.id) }

      updated_user = User.find(user.id)

      expect(response).to have_http_status(:no_content)
      expect(updated_user.retweets.size).to eq(4)
    end

    it 'returns unauthorized if authorization missing' do
      delete "/api/v1/retweets/#{retweet.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized if authorization is invalid' do
      delete "/api/v1/retweets/#{retweet.id}", headers: { 'Authentication': 'awrongtoken123456' }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
