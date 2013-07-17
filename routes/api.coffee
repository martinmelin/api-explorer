request = require "request"

exports.index = (req, res) ->
  request(
    url: "http://api.tictailhq.com/#{req.param(0)}"
    method: req.method
    body: JSON.stringify req.body
    headers: {
      "Content-Type": "application/json"
    }
  ).pipe res
