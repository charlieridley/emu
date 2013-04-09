Emu.PushDataAdapter = Ember.Object.extend
  init: ->
    @_serializer = @get("serializer")?.create() or Emu.Serializer.create()    

  start: (store) ->
    @updatableTypes?.forEach (type) =>
      @listenForUpdates(store, Ember.get(type))
  
  listenForUpdates: (store, type) ->
    @registerForUpdates?(store, type)

  didUpdate: (type, store, json) ->
    primaryKey = Emu.Model.primaryKey(type)
    model = store.findUpdatable(type, json[primaryKey])
    @_serializer.deserializeModel(model, json) if model