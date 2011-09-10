require 'nokogiri'
require 'open-uri'
require 'json'
require 'oauth'

def play_song(song)
puts "looking for #{song}"
xml=Nokogiri::XML(open("https://gdata.youtube.com/feeds/api/videos?q=#{URI.escape(song)}&max-results=1"))
url = xml.search('feed entry link[rel=alternate]').attr('href').value
`open #{url}`
rescue
  puts "sorry dude, couldn't find #{song}"
end

#Clients may not make more than 150 requests per hour
def get_last_tweet(access_token)
  response=access_token.request(:get, "http://api.twitter.com/1/statuses/home_timeline.json")
  if response.code == "200"
    JSON::parse(response.read_body).first["text"]
  end
rescue
  puts "couldn't get tweet"
end

def run
# Exchange your oauth_token and oauth_token_secret for an AccessToken instance.
  def prepare_access_token(oauth_token, oauth_token_secret)
      consumer = OAuth::Consumer.new("VG4ZMn117FlHZX4MR4Q", "h9Z9zIEDMEhKD609W4PQCrZG4KSbWYLvkMluSREuMY",
         { :site => "http://api.twitter.com",
           :scheme => :header
         })
      # now create the access token object from passed values
      token_hash = { :oauth_token => oauth_token,
                     :oauth_token_secret => oauth_token_secret
                   }
      access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
      return access_token
  end

  # TODO: should make people sign in via twitter
  # Exchange our oauth_token and oauth_token secret for the AccessToken instance.
  access_token = prepare_access_token("371208952-EeSa2o01Xg6ZV6Bm3r3GI3rNlpzErZ6ccEzX6xyS", "dDXIIw3V16Pl0GKwba8jdyq3IlqeKA9YSLzI5WpI0g")
  # use the access token as an agent to get the user timeline
  #response = access_token.request(:get, "https://userstream.twitter.com/2/user.json")
  #response = access_token.request(:get, "http://api.twitter.com/1/statuses/home_timeline.json")

  last_tweet=""
  while true do
    sleep 3
    tweet = get_last_tweet access_token
    print "."
    next if tweet == last_tweet

    hashtag=/#play/
    if hashtag =~ tweet
      search_for=tweet.gsub(hashtag, '')
      play_song search_for
    else
      puts "new tweet, but no hashtag: #{tweet}"
    end

    last_tweet=tweet
  end
end
