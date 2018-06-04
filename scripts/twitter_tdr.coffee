# Description
#   A Hubot script that search tweets of tdr information
#
# Dependencies:
#   twitter
#
# Commands:
#   tdr_now or tdr_md
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

  createAttachments = (statuses) ->
    attachments = []
    for status in statuses
      name = status.user.screen_name
      icon = status.user.profile_image_url_https
      text = status.full_text
      id = status.id_str
      media = status.entities.media
      createAt = new Date Date.parse(status.created_at)
      attachment = {
        "fallback": text
        "author_name": name,
        "author_link": 'https://twitter.com/' + name + '/status/' + id,
        "author_icon": icon,
        "text": text,
        "ts": createAt.getTime() / 1000
      }
      if media
        attachment["image_url"] = media[0].media_url_https
      attachments.push(attachment)
    return attachments

  robot.hear /tdr_now/, (res) ->
    room = res.message.room
    if room is process.env.TWITTER_ROOM
      now = new Date
      diff = new Date now.getFullYear(), now.getMonth(), now.getDate(),
          now.getHours() - 1, now.getMinutes()
      params =  {
        q: '#tdr_now -rt', lang: 'ja', result_type: 'recent', count: '10',
        include_entities: 1, tweet_mode: 'extended'
      }
      client.get 'search/tweets', params, (error, tweets, response) ->
        statuses = tweets.statuses.filter (status) ->
          createAt = new Date Date.parse(status.created_at)
          if createAt > diff then true else false
        attachments = createAttachments statuses
        res.send { attachments: attachments }

  robot.hear /tdr_md/, (res) ->
    room = res.message.room
    if room is process.env.TWITTER_ROOM
      now = new Date
      diff = new Date now.getFullYear(), now.getMonth(), now.getDate(),
          now.getHours() - 8, now.getMinutes()
      params =  {
        q: '#tdr_md -rt', lang: 'ja', result_type: 'recent', count: '10',
        include_entities: 1, tweet_mode: 'extended'
      }
      client.get 'search/tweets', params, (error, tweets, response) ->
        statuses = tweets.statuses.filter (status) ->
          createAt = new Date Date.parse(status.created_at)
          if createAt > diff then true else false
        attachments = createAttachments statuses
        res.send { attachments: attachments }
