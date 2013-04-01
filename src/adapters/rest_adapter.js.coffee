Emu.RestAdapter = Ember.Object.extend
  init: ->
    @_serializer = @get("serializer")?.create() or Emu.Serializer.create()
  findAll: (type, store, collection) -> 
    url = if collection.get("parent") then @_getEndpointNestedSubCollection(collection) else @_getEndpointForModel(type)
    $.ajax
      url: url
      type: "GET"
      success: (jsonData) =>
        @_didFindAll(store, collection, jsonData)
  findById: (type, store, model, id) ->
    $.ajax
      url: @_getEndpointForModel(type) + "/" + id
      type: "GET"
      success: (jsonData) =>
        @_didFindById(store, model, jsonData)
  findQuery: (type, store, collection, queryHash) ->
    $.ajax
      url: @_getEndpointForModel(type) + @_serializer.serializeQueryHash(queryHash)
      type: "GET"
      success: (jsonData) =>
        @_serializer.deserializeCollection(collection, jsonData)
        store.didFindQuery(collection)
  insert: (store, model) ->
    jsonData = @_serializer.serializeModel(model)
    $.ajax
      url: @_getEndpointForModel(model.constructor)
      data: jsonData
      type: "POST"
      success: (jsonData) =>
        @_didSave(store, model, jsonData)
  _didFindAll: (store, collection, jsonData) ->
    @_serializer.deserializeCollection(collection, jsonData)
    store.didFindAll(collection)
  _didFindById: (store, model, jsonData) ->
    @_serializer.deserializeModel(model, jsonData)
    store.didFindById(model)
  _didSave: (store, model, jsonData) ->
    @_serializer.deserializeModel(model, jsonData)
    store.didSave(model)
  _getEndpointNestedSubCollection: (collection) ->
    @_getBaseUrl() + @_serializer.serializeTypeName(collection.get("parent").constructor) + "/" + collection.get("parent.id") + "/" + @_serializer.serializeTypeName(collection.get("type"))
  _getEndpointForModel: (type) ->
    @_getBaseUrl() + @_serializer.serializeTypeName(type)
  _getBaseUrl: ->
    if @get("namespace") then @get("namespace") + "/" else ""