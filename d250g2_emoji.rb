# -*- coding: utf-8 -*-
require 'twitter'

Plugin.create(:d250g2) do
  @clients = {}

  unless UserConfig[:twitter_secret] # mikutter >= 3.0.0
    @clients[Service.primary.idname] = Twitter::REST::Client.new do |c|
      c.consumer_key = Service.primary.twitter.consumer_key
      c.consumer_secret = Service.primary.twitter.consumer_secret
      c.oauth_token = Service.primary.twitter.a_token
      c.oauth_token_secret = Service.primary.twitter.a_secret
    end
  else # mikutter < 3.0.0
    if defined? Twitter::REST
      @clients[Service.primary.idname] = Twitter::REST::Client.new do |c|
        c.consumer_key = CHIConfig::TWITTER_CONSUMER_KEY
        c.consumer_secret = CHIConfig::TWITTER_CONSUMER_SECRET
        c.oauth_token = UserConfig[:twitter_token]
        c.oauth_token_secret = UserConfig[:twitter_secret]
      end
    else
      Twitter.configure do |c|
        c.consumer_key = CHIConfig::TWITTER_CONSUMER_KEY
        c.consumer_secret = CHIConfig::TWITTER_CONSUMER_SECRET
        c.oauth_token = UserConfig[:twitter_token]
        c.oauth_token_secret = UserConfig[:twitter_secret]
      end
      @clients[Service.primary.idname] = Twitter.client
    end
  end

  begin
    @reply_array = YAML.load_file(File.join(__dir__, "config.yml"))
  rescue LoadError
    notice "\"config.yml\" not found."
  end

  command(:d250g2,
          name: "d250g2-emoji",
          condition: Plugin::Command[:CanReplyAll],
          visible: true,
          role: :timeline) do |m|
    m.messages.map do |msg|
      emoji(msg.message)
    end
  end

  def emoji(message)
    id = message.idname
    message = "@#{id}"
    filename = @reply_array.sample
    Thread.new {
      @clients[Service.primary.idname].update_with_media(message, File.new(File.join(__dir__, 'emoji', filename)))
    }
  end

end
