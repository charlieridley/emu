Emu.PushDataAdapter = Ember.Object.extend
  init: ->
    @_serializer = @get("serializer")?.create() or Emu.Serializer.create()    
  
  listenForUpdates: (store, type) ->
    @registerForUpdates(store, type)

  didUpdate: (type, store, json) ->
    primaryKey = Emu.Model.primaryKey(type)
    model = store.findUpdatable(type, json[primaryKey])
    @_serializer.deserializeModel(model, json) if model