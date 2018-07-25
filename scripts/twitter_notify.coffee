# Description
#   A Hubot script that notify reply and dm
#
# Dependencies:
#   twitter
#
# Commands:
#   none
#
# Author:
#   yuzumone
#

twitter = require 'twitter'
client = new twitter {
  consumer_key: process.env.TWITTER_CONSUMER_KEY,
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET,
  access_token_key: process.env.TWITTER_ACCESS_TOKEN,
  access_token_secret: process.env.TWITTER_ACCESS_SECRET
}

module.exports = (robot) ->

  send = (msg) ->
    robot.send {room: '#notify_twitter'}, msg

  new cron('0 0,15,30,45 * * * *', () ->
    now = new Date
    diff = new Date now.getFullYear(), now.getMonth(), now.getDate(),
          now.getHours(), now.getMinutes() - 15
    client.get 'statuses/mentions_timeline', (error, tweets, response) ->
      s = tweets.filter (status) ->
        createAt = new Date Date.parse(status.created_at)
        if createAt > diff then true else false
      if s.length > 0
        send 'Reply'
  ).start()

  new cron('0 0,15,30,45 * * * *', () ->
    now = new Date
    diff = new Date now.getFullYear(), now.getMonth(), now.getDate(),
          now.getHours(), now.getMinutes() - 15
    client.get 'direct_messages/events/list', (error, messages, response) ->
      m = messages.events.filter (message) ->
        createAt = new Date parseInt message.created_timestamp
        if createAt > diff.getTime() then true else false
      if m.length > 0
        send 'DM'
  ).start()
