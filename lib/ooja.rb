require 'nokogiri'
require 'open-uri'
require 'json'
require 'oauth'
require 'yaml'

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
    # use the access token as an agent to get the user timeline
  #response = access_token.request(:get, "https://userstream.twitter.com/2/user.json")
  #response = access_token.request(:get, "http://api.twitter.com/1/statuses/home_timeline.json")

response=access_token.request(:get, "http://api.twitter.com/1/statuses/home_timeline.json")
  if response.code == "200"
    JSON::parse(response.read_body).first["text"]
  end
rescue
  puts "couldn't get tweet"
end

def run
# Exchange your oauth_token and oauth_token_secret for an AccessToken instance.
  def get_access_token()
      credentials_file="app-credentials.yaml"
      begin
        credentials = YAML.load(File.read(credentials_file))
        puts "found your app (consumer) credentials"
      rescue
        puts "get your oauth app (consumer) credentials from twitter"
        Kernel.sleep 2
        `open http://twitter.com/oauth_clients`
        credentials={}
        print "consumer id: "
        credentials["consumer_id"]=gets.chomp
        print "consumer secret: "
        credentials["consumer_secret"]=gets.chomp
        File.open credentials_file,'w' do |file|
          file.write YAML.dump(credentials)
        end
      end

      #setup consumer
      consumer = OAuth::Consumer.new(credentials["consumer_id"],
                                     credentials["consumer_secret"],
         { :site => "http://api.twitter.com",
           :scheme => :header
         })

      if credentials.has_key? :screen_name
        puts "cached oauth token for #{credentials[:screen_name]}"
        access=OAuth::AccessToken.from_hash(consumer, credentials )
      else
        #get request token from twitter
        request=consumer.get_request_token

        #send user to get pin saying it's cool
        `open #{request.authorize_url}`
        print "what's your pin? "
        pin=gets.chomp

        #use pin to authenticate and get access to act as user
        access=request.get_access_token :oauth_verifier=> pin

        puts "signed in as #{access.params[:screen_name]}"

        #save to file for next time
        File.open credentials_file,'w' do |file|
          file.write YAML.dump(credentials.merge(access.params))
        end

        access
      end
  end

  access_token = get_access_token

  last_tweet=""
  loop do
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
