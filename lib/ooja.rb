require 'nokogiri'
require 'open-uri'
require 'json'

def play_song(song)
puts "looking for #{song}"
xml=Nokogiri::XML(open("https://gdata.youtube.com/feeds/api/videos?q=#{URI.escape(song)}&max-results=1"))
url = xml.search('feed entry link[rel=alternate]').attr('href').value
`open #{url}`
rescue
  puts "sorry dude, couldn't find #{song}"
end

#Clients may not make more than 150 requests per hour
def get_last_tweet(user="fakefritz")
  tweet=JSON::parse(open("https://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{user}&count=1").read).first["text"]
rescue
  puts "couldn't get tweet"
end

def run
  last_tweet=""
  while true do
    sleep 1
    tweet = get_last_tweet
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
