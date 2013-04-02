Emu.Store = Ember.Object.extend
  init: ->    
    if not Ember.get(Emu, "defaultStore")
      Ember.set(Emu, "defaultStore", this)
    @set("modelCollections", {}) if @get("modelCollections") == undefined
    @set("queryCollections", {}) if @get("queryCollections") == undefined
    @set("deferredQueries", {}) if @get("deferredQueries") == undefined
    @_adapter = @get("adapter")?.create() || Emu.RestAdapter.create()
  
  createRecord: (type) ->
    collection = @_getCollectionForType(type)
    collection.createRecord(isDirty: true)
  
  find: (type, param) -> 
    if not param 
      return @findAll(type)
    else if Em.typeOf(param) == "string" 
      return @findById(type, param)
    else if Em.typeOf(param) == "number" 
      return @findById(type, param)
    else if Em.typeOf(param) == "object"
      @findQuery(type, param)
    else if Em.typeOf(param) == "function"
      @findPredicate(type, param)
  
  findAll: (type) ->
    collection = @_getCollectionForType(type)
    @loadAll(collection)
    collection  
  
  didFindAll: (collection) ->
    @_didCollectionLoad(collection)
    deferredQueries = @get("deferredQueries")[collection.type]
    if deferredQueries
      deferredQueries.forEach (deferredQuery) ->
        queryResult = collection.filter(deferredQuery.predicate)
        queryResult.forEach (item) ->
          deferredQuery.results.pushObject(item)
  
  findById: (type, id) ->
    collection = @_getCollectionForType(type)
    model = collection.find (item) -> item.get("id") == id
    if not model
      model = collection.createRecord(id: id)     
    @loadModel(model)

  didFindById: (model) ->
    model.set("isLoading", false)
    model.set("isLoaded", true)

  findQuery: (type, queryHash) ->
    collection = @_getCollectionForQuery(type, queryHash)
    if not collection.get("isLoading")
      collection.set("isLoading", true)
      @_adapter.findQuery(type, this, collection, queryHash)
    collection

  didFindQuery: (collection) ->
    @_didCollectionLoad(collection)    

  findPredicate: (type, predicate) ->
    allModels = @findAll(type)    
    results = Emu.ModelCollection.create(type: type, store: this)    
    if allModels.get("isLoaded")
      allModels.forEach (model) -> 
        if predicate(model)
          results.pushObject(model)
    else
      queries = @get("deferredQueries")[type] || @get("deferredQueries")[type] = []
      queries.pushObject(predicate: predicate, results: results)
    results

  save: (model) ->
    if model.get("id") then @_adapter.update(this, model) else @_adapter.insert(this, model)

  didSave: (model) ->
    model.set("isDirty", false)
    model.set("isLoaded", true)
    model.set("isLoading", false)

  loadAll: (collection) ->
    if collection.get("isLoading") or collection.get("isLoaded")
      return collection
    collection.set("isLoading", true)
    @_adapter.findAll(collection.get("type"), this, collection)
    collection  
  
  loadModel: (model) ->
    if not model.get("isLoading") and not model.get("isLoaded")
      model.set("isLoading", true)
      @_adapter.findById(model.constructor, this, model, model.get("id"))
    model
    
  _didCollectionLoad: (collection) ->
    collection.set("isLoaded", true)
    collection.set("isLoading", false)
  
  _getCollectionForType: (type) ->
    @get("modelCollections")[type] || @get("modelCollections")[type] = Emu.ModelCollection.create(type: type, store: this)
  
  _getCollectionForQuery: (type, queryHash) ->
    key = JSON.stringify(queryHash)
    queries = @get("queryCollections")[type] || @get("queryCollections")[type] = {}
    @get("queryCollections")[type][key] || @get("queryCollections")[type][key] = Emu.ModelCollection.create(type: type, store: this)
