Emu.ModelCollection = Ember.ArrayProxy.extend
  init: ->
    @set("content", Ember.A([])) unless @get("content")
    
    @createRecord = (hash) ->      
      primaryKey = Emu.Model.primaryKey(@get("type"))
      paramHash = 
        store: @get("store")
      paramHash[primaryKey] = hash?.id
      model = @get("type").create(paramHash)     
      model.setProperties(hash)    
      model.subscribeToUpdates() if @_subscribeToUpdates
      @pushObject(model)
    
    @addObserver "content.@each", =>
      @set("hasValue", true)
      @set("isDirty", true)
    
    @find = (predicate) -> 
      @get("content").find(predicate)

  subscribeToUpdates: ->
    @_subscribeToUpdates = true

  deleteRecord: (model) ->
    @removeObject(model)

  length: (->
    @get("content.length")
  ).property("content.length").volatile()