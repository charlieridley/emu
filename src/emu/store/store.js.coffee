Emu.Store = Ember.Object.extend
  init: ->    
    unless Ember.get(Emu, "defaultStore")
      Ember.set(Emu, "defaultStore", this)
    @set("modelCollections", {}) unless @get("modelCollections") 
    @set("queryCollections", {}) unless @get("queryCollections")
    @set("deferredQueries", {})  unless @get("deferredQueries")
    @set("updatableModels", {})  unless @get("updatableModels")
    @_adapter = @get("adapter")?.create() || Emu.RestAdapter.create()
    @_pushAdapter = @get("pushAdapter")?.create()
    @_pushAdapter?.start(this)

  createRecord: (type, hash) ->
    collection = @_getCollectionForType(type)
    collection.createRecord(hash)
  
  find: (type, param) -> 
    return @findAll(type) unless param 
    switch Em.typeOf(param)
      when 'string', 'number' then @findById(type, param)
      when 'object'           then @findQuery(type, param)
      when 'function'         then @findPredicate(type, param)
  
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
        deferredQuery.results.pushObjects(queryResult)
        deferredQuery.results.didFinishLoading()
  
  findById: (type, id) ->
    collection = @_getCollectionForType(type)
    model = collection.find (item) -> item.primaryKeyValue() == id
    unless model
      model = collection.createRecord(id: id)    
      model.primaryKeyValue(id) 
    @loadModel(model)

  didFindById: (model) ->
    model.didFinishLoading()  

  didError: (model) ->
    model.didError()

  findQuery: (type, queryHash) -> 
    collection = @_getCollectionForQuery(type, queryHash)
    unless collection.get("isLoading")
      collection.didStartLoading()
      @_adapter.findQuery(type, this, collection, queryHash)
    collection

  didFindQuery: (collection) ->
    @_didCollectionLoad(collection)    

  findPredicate: (type, predicate) ->
    allModels = @findAll(type)    
    results = Emu.ModelCollection.create(type: type, store: this)    
    if allModels.get("isLoaded")
      filtered = allModels.filter (m) -> predicate(m)
      results.pushObjects filtered
      results.didFinishLoading()    
    else
      results.didStartLoading()    
      queries = @get("deferredQueries")[type] or @get("deferredQueries")[type] = []
      queries.pushObject(predicate: predicate, results: results)
    results

  save: (model) ->
    model.didStartSaving()
    if model.primaryKeyValue()
      @_adapter.update(this, model) 
    else 
      @_adapter.insert(this, model)

  didSave: (model) ->
    model.didFinishSaving()

  loadAll: (collection) ->
    if collection.get("isLoading") or collection.get("isLoaded")
      return collection
    collection.didStartLoading()
    @_adapter.findAll(collection.get("type"), this, collection)
    collection  
  
  loadModel: (model) ->
    if not model.get("isLoading") and not model.get("isLoaded")
      model.didStartLoading()
      @_adapter.findById(model.constructor, this, model, model.primaryKeyValue())
    model

  subscribeToUpdates: (model) ->
    unless @_pushAdapter
      throw new Error("You need to register a Emu.PushDataAdapter on your store: Emu.Store.create({pushAdapter: App.MyPushAdapter.create()});")
    unless @findUpdatable(model.constructor, model.primaryKeyValue())
      @get("updatableModels")[model.constructor] ?= []
      @get("updatableModels")[model.constructor].pushObject(model)

  findUpdatable: (type, id) ->
    @get("updatableModels")[type]?.find (model) -> 
      model.primaryKeyValue() == id

  deleteRecord: (model) ->
    if model.primaryKeyValue()
      @_adapter.delete(this, model)
    else
      @didDeleteRecord(model)

  didDeleteRecord: (model) ->
    @_getCollectionForType(model.constructor).deleteRecord(model)
    
  _didCollectionLoad: (collection) ->
    collection.didFinishLoading()
  
  _getCollectionForType: (type) ->
    @get("modelCollections")[type] || @get("modelCollections")[type] = Emu.ModelCollection.create(type: type, store: this)
  
  _getCollectionForQuery: (type, queryHash) ->
    key = JSON.stringify(queryHash)
    queries = @get("queryCollections")[type] || @get("queryCollections")[type] = {}
    @get("queryCollections")[type][key] || @get("queryCollections")[type][key] = Emu.ModelCollection.create(type: type, store: this)
