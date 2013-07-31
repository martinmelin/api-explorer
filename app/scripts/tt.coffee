PARENT_ORIGIN = "http://tictailhq.com"
API_URL = "http://api.tictailhq.com"

window.TT = {
  store: null
  accessToken: null

  _events: $ {}

  init: (callback) ->
    @_setupMessagingEvents()

    @_emit "requestAccess"
    @_events.one "access", (e, {accessToken, store}) =>
      @accessToken = accessToken
      @store = store

      @_emit "loaded"
      callback? store

  request: (endpoint, settings) ->
    defaults =
      url: "#{API_URL}/#{endpoint}"
      headers: {
        Authorization: "Bearer #{@accessToken}"
      }

    if settings.type is "POST"
      defaults.contentType = "application/json"

    $.ajax $.extend(true, defaults, settings)

  _setupMessagingEvents: ->
    $(window).on "message", (e) =>
      return unless e.originalEvent.origin is PARENT_ORIGIN
      @_events.trigger e.originalEvent.data.eventName, \
                       e.originalEvent.data.eventData

  _emit: (eventName, eventData) ->
    window.parent.postMessage(
      eventName: eventName
      eventData: eventData
    , PARENT_ORIGIN)
}
