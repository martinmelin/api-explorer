request = require "request"

exports.index = (req, res) ->
  request("http://api.tictailhq.com/#{req.param(0)}").pipe res
