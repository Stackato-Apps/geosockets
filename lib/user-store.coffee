Url = require 'url'
http = require 'http'
redis = require 'redis'

module.exports = class UserStore

  constructor: (cb) ->
    @ttl = 60*15
    @url = Url.parse('redis://localhost:6379')
    if process.env.REDIS_URL
      @url = Url.parse(process.env.REDIS_URL)
    else if process.env.STACKATO_SERVICES
      service = JSON.parse(process.env.STACKATO_SERVICES)['user-store'].credentials
      @url = {}
      @url.port = service.port
      @url.hostname = service.hostname
      @url.auth = "#{service.name}:#{service.password}"

    @redis = redis.createClient(@url.port, @url.hostname)
    @redis.auth(@url.auth.split(":")[1]) if @url.auth

    cb() if cb

  getByUrl: (url, cb) =>
    @redis.keys url+"*", (err, keys) =>
      return cb(err) if err
      return cb(null, []) if keys.length is 0
      @redis.mget keys, (err, users) ->
        cb null, users

  add: (user, cb) =>
    @redis.setex "#{user.url}---#{user.uuid}", @ttl, JSON.stringify(user)
    cb()
