class TT
  PARENT_ORIGIN: "http://tictailhq.com"
  API_URL: "http://api.tictailhq.com"

  store: null
  accessToken: null
  _events: $ {}

  # Initalize TT.js and call the callback with the current store when finished.
  # This should ideally be done before the rest of the application is loaded, e.g
  # TT.init(MyApp.init).
  init: (callback) ->
    @_setupMessagingEvents()

    @_trigger "requestAccess"
    @_events.one "access", (e, {accessToken, store}) =>
      @accessToken = accessToken
      @store = store

      @loaded()
      callback? store

    @_events.on "requestSize", @reportSize.bind(this)

  loading: => @_trigger "loading"
  loaded: => @_trigger "loaded"

  # Report the size to the parent frame so that the iframe containing this
  # app is resized. The options parameter can either contain a width and
  # height property, or an element property containing a jQuery compatible
  # selector string. If called without arguments, the outer size of the <html>
  # element is reported.
  reportSize: (options) ->
    width = height = 0
    if options?.width and options?.height
      {width, height} = options
    else
      $el = $(options?.element or "html")
      width = $el.outerWidth()
      height = $el.outerHeight()

    @_trigger "reportSize", {width: width, height: height}

  # Show the Tictail dashboard share dialog with the given
  # heading and message. The given onComplete function is called
  # with a Boolean indicating whether the user clicked share (true)
  # or cancelled (false).
  showShareDialog: (options) ->
    @_trigger "showShareDialog", {
      heading: options.heading
      message: options.message
    }

    @_events.one "shareDialogShown", (e, data) ->
      options.onComplete data

  # A jQuery.ajax wrapper that automatically sets the API root url,
  # authorization and content-type headers.
  request: (endpoint, settings) ->
    defaults =
      url: "#{@API_URL}/#{endpoint}"
      headers: {
        Authorization: "Bearer #{@accessToken}"
      }

    if settings.type is "POST"
      defaults.contentType = "application/json"

    $.ajax $.extend(true, defaults, settings)

  # Trigger an event on the parent frame
  _trigger: (eventName, eventData) ->
    message = JSON.stringify eventName: eventName, eventData: eventData
    window.parent.postMessage message, @PARENT_ORIGIN

  # Convert incoming messages to their own events on the @_events object,
  # assuming every message is an object containing the keys eventName
  # and eventData.
  _setupMessagingEvents: ->
    $(window).on "message", (e) =>
      return unless e.originalEvent.origin is @PARENT_ORIGIN

      try
        data = JSON.parse e.originalEvent.data
      catch e
        return

      @_events.trigger data.eventName, data.eventData

window.TT = new TT
