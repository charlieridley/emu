Emu.ModelCollection = Ember.ArrayProxy.extend Emu.ModelEvented, Ember.Evented,
  init: ->
    @set("content", Ember.A([])) unless @get("content")
    
    @createRecord = (hash) ->      
      primaryKey = Emu.Model.primaryKey(@get("type"))
      paramHash = 
        store: @get("store")
      paramHash[primaryKey] = hash?.id
      model = @get("type").create(paramHash)   
      model.set("parent", this)  
      model.setProperties(hash)    
      model.subscribeToUpdates() if @_subscribeToUpdates
      @pushObject(model)    
    
    @pushObject = (model) =>
      model.on "didStateChange", => @didStateChange()
      @get("content").pushObject(model)

    @addObserver "content.@each.isDirty", =>
      @didStateChange()
      @set("hasValue", true)
      @set("isDirty", true)
    
    @find = (predicate) -> 
      @get("content").find(predicate)

    Emu.StateTracker.create().track(this)

  subscribeToUpdates: ->
    @_subscribeToUpdates = true

  deleteRecord: (model) ->
    @removeObject(model)

  length: (->
    @get("content.length")
  ).property("content.length").volatile()

  clear: ->
    @_super()
    @set("hasValue", false)