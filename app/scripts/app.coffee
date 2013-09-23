class App
  $form: $ "form"
  $endpointSelect: $ "#endpoint"
  $parameters: $ "#parameters"
  $requestBodyContainer: $ ".request-body-container"

  parameterInputTemplate: _.template $("#parameter-input-template").html()

  constructor: ->
    @setupListeners()
    @setupEditors()

    @getStore().done @display, @loadEndpoints

  setupListeners: ->
    @$endpointSelect.on "change", @showEndpointParameters
    @$form.on "ifChecked", "input[name=method]", @loadEndpoints
    @$form.validate submitHandler: @submitHandler

  # Initialize and setup the ACE editors (request body and read-only response)
  setupEditors: ->
    @editor = ace.edit "request-body"
    @response = ace.edit "response"

    for editor in [@editor, @response]
      editor.setTheme "ace/theme/monokai"
      editor.renderer.setShowGutter false
      editor.setHighlightActiveLine false

      session = editor.getSession()
      session.setMode "ace/mode/json"
      session.setTabSize 2
      session.setUseWrapMode true
      session.setWrapLimitRange null, null

    @response.setReadOnly true

  # Get the user's store from the /me API endpoint
  getStore: ->
    TT.api.get("v1/me").then((store) => @store = store)

  display: =>
    $(".app").show()

    $("#accessToken").text TT.api.accessToken
    $("#storeId").text @store.id

  # Load the list of endpoints for the currently selected HTTP method
  # into the endpoint select box.
  loadEndpoints: =>
    method = @$form.find("input[name=method]:checked").val()

    clone = _.clone(API_ENDPOINTS[method])
    endpoints = _.map clone, (endpoint) -> text: endpoint, id: endpoint

    @$endpointSelect.select data: endpoints
    @$endpointSelect.val(endpoints[0].id).trigger "change"

    if method is "POST"
      @$requestBodyContainer.show()
    else
      @$requestBodyContainer.hide()

    TT.native.reportSize()

  # Render input boxes setting url parameters of the currently selected
  # endpoint.
  showEndpointParameters: =>
    endpoint = @$endpointSelect.val()
    parameters = @parseUrlParameters endpoint
    @$parameters.empty()

    if parameters
      @$parameters.show()

      for parameter in parameters
        $input = $ @parameterInputTemplate(name: parameter[1..])
        if parameter is ":store_id"
          $input.find("input").val(@store.id).prop "disabled", true

        @$parameters.append $input
    else
      @$parameters.hide()

    TT.native.reportSize()

  # Return a list of parameters for the given url
  parseUrlParameters: (url) ->
    url.match /:[A-Z_]*/gi

  # Insert values from the parameters hash into the given url.
  # Example:
  #   insertUrlParameters("http://example.com/:foo/:bar", {foo: 1, bar: 5})
  #     => "http://example.com/1/5"
  insertUrlParameters: (url, parameters) ->
    url = url.replace(":#{parameter}", value) for parameter, value of parameters
    url

  # Handle form submits. Sends an API request according to the form and
  # prints the success data or error message in the response box.
  submitHandler: (form) =>
    urlParameters = {}
    @$parameters.find("input").each -> urlParameters[@name] = @value

    endpoint = @insertUrlParameters form.endpoint.value, urlParameters
    method = @$form.find("input[name=method]:checked").val()
    params =
      endpoint: endpoint
      type: method

    if method is "POST"
      params.data = @editor.getValue()

    TT.native.loading()
    TT.api.ajax(params)
      .done(@printSuccessResponse)
      .fail(@printErrorResponse)
      .always =>
        TT.native.loaded()
        @response.clearSelection()
        @response.gotoLine 0

  printSuccessResponse: (response, status, jqXHR) =>
    @response.setValue \
      jqXHR.responseText or "#{jqXHR.status} #{jqXHR.statusText}"

  printErrorResponse: (error) =>
    @response.setValue \
      "#{error.status} #{error.statusText}\n\n#{error.responseText}"

TT.native.init().then -> new App
