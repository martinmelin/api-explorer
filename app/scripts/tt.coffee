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

    @_events.on "requestSize", @reportSize.bind(this)

  reportSize: (options) ->
    width = height = 0
    if options?.width and options?.height
      {width, height} = options
    else
      $el = $(options?.element or "html")
      width = $el.outerWidth()
      height = $el.outerHeight()

    @_emit "reportSize", {width: width, height: height}

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
