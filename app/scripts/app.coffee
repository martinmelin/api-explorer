class App
  $form: $ "form"
  $endpointSelect: $ "#endpoint"
  $parameters: $ "#parameters"
  $requestBody: $ "#request-body"
  $response: $ ".response code"

  constructor: (@store) ->
    @parameterInputTemplate = _.template $("#parameter-input-template").html()

    @$endpointSelect.on "change", @showEndpointParameters.bind(this)
    @$form.on "ifChecked", "input[name=method]", @loadEndpoints.bind(this)
    @$form.validate submitHandler: @submitHandler.bind(this)

    @display()
    @loadEndpoints()

  display: ->
    $(".loader").hide()
    $(".app").show()

  # Load the list of endpoints for the currently selected HTTP method
  # into the endpoint select box.
  loadEndpoints: ->
    method = @$form.find("input[name=method]:checked").val()
    endpoints = _.map _.clone(API_ENDPOINTS[method]), (endpoint) ->
      { text: endpoint, id: endpoint }

    @$endpointSelect.select data: endpoints
    @$endpointSelect.val(endpoints[0].id).trigger "change"

    if method is "POST"
      @$requestBody.show()
    else
      @$requestBody.hide()

    TT.reportSize()

  # Render input boxes setting url parameters of the currently selected
  # endpoint.
  showEndpointParameters: ->
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

    TT.reportSize()

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
  submitHandler: (form) ->
    urlParameters = {}
    for input in @$parameters.find("input")
      urlParameters[input.name] = input.value

    endpoint = @insertUrlParameters form.endpoint.value, urlParameters
    method = @$form.find("input[name=method]:checked").val()

    params =
      type: method

    if method is "POST"
      params.data = @$form[0].body.value

    TT.request(endpoint, params)
      .success((response, status, jqXHR) =>
        @$response.text jqXHR.responseText or "Success!"
        Prism.highlightAll()
      ).error((error) =>
        @$response.text "#{error.status}: #{error.statusText}"
      )

$("body").addClass location.hash.slice(1)
TT.init (store) -> new App(store)
