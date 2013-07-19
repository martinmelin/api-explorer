#= require ../vendor/jquery/jquery-1.10.2.min
#= require ../vendor/underscore/underscore-min
#= require ../vendor/tictail-uikit/tictail-uikit.js
#= require endpoints

# Use Mustache-style templating to avoid conflicts with EJS templates
_.templateSettings = interpolate : /\{\{(.+?)\}\}/g

class App
  $form: $ "form"
  $endpointSelect: $ "#endpoint"
  $parameters: $ "#parameters"
  $parameterInputs: $ "#parameters .inputs"
  $requestBody: $ "#request-body"

  constructor: ->
    @parameterInputTemplate = _.template $("#parameter-input-template").html()

    @$endpointSelect.on "change", @showEndpointParameters.bind(this)
    @$form.on "ifChecked", "input[name=method]", @loadEndpoints.bind(this)
    @$form.validate submitHandler: @submitHandler.bind(this)

    @loadEndpoints()

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

  showEndpointParameters: ->
    endpoint = @$endpointSelect.val()
    parameters = @parseUrlParameters endpoint
    @$parameterInputs.empty()

    if parameters
      @$parameters.show()

      for parameter in parameters
        $input = $ @parameterInputTemplate(name: parameter[1..])
        if parameter is ":store_id"
          $input.find("input").val(STORE_ID).prop "disabled", true

        @$parameterInputs.append $input
    else
      @$parameters.hide()

  parseUrlParameters: (url) ->
    url.match /:[A-Z_]*/gi

  insertUrlParameters: (url, parameters) ->
    url = url.replace(":#{parameter}", value) for parameter, value of parameters
    url

  submitHandler: (form) ->
    urlParameters = {}
    for input in @$parameterInputs.find("input")
      urlParameters[input.name] = input.value

    endpoint = @insertUrlParameters form.endpoint.value, urlParameters
    method = @$form.find("input[name=method]:checked").val()

    params = url: "http://api.tictailhq.com/#{endpoint}", type: method
    if method is "POST"
      _.extend params, contentType: "application/json", data: @$form[0].body.value

    $.ajax(params)
      .success((response, status, jqXHR) ->
        $(".response").text jqXHR.responseText
      ).error((error) ->
        $(".response").text "#{error.status}: #{error.statusText}"
      )

new App