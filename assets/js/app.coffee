#= require ../vendor/jquery/jquery-1.10.2.min
#= require ../vendor/underscore/underscore-min
#= require ../vendor/tictail-uikit/tictail-uikit.js
#= require endpoints

$endpointSelect = $ "#endpoint"
$parameters = $ ".parameters"
$parameterInputs = $parameters.find ".inputs"

# Use Mustache-style templating to avoid conflicts with EJS templates
_.templateSettings = interpolate : /\{\{(.+?)\}\}/g
parameterInputTemplate = _.template $("#parameter-input-template").html()

loadEndpoints = ->
  endpoints = _.map _.clone(API_ENDPOINTS.GET), (endpoint) ->
    { text: endpoint, id: endpoint }
  $endpointSelect.select data: endpoints
  $endpointSelect.val(endpoints[0].id).trigger "change"

showEndpointParameters = ->
  endpoint = $endpointSelect.val()
  parameters = parseUrlParameters endpoint
  $parameterInputs.empty()

  if parameters
    $parameters.show()

    for parameter in parameters
      $parameterInputs.append parameterInputTemplate(name: parameter[1..])
  else
    $parameters.hide()

parseUrlParameters = (url) ->
  url.match /:[A-Z_]*/gi

insertUrlParameters = (url, parameters) ->
  url = url.replace(":#{parameter}", value) for parameter, value of parameters
  url

loadEndpoints()
$endpointSelect.on("change", showEndpointParameters)

$("form").validate
  submitHandler: (form) ->
    urlParameters = {}
    for input in $parameterInputs.find("input")
      urlParameters[input.name] = input.value

    endpoint = insertUrlParameters form.endpoint.value, urlParameters

    $.get("/api/#{endpoint}")
      .success((response, status, jqXHR) ->
        $(".response").text jqXHR.responseText
      ).error((error) ->
        $(".response").text "#{error.status}: #{error.statusText}"
    )

