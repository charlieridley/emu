Emu.SignalrPushDataAdapter = Emu.PushDataAdapter.extend
  registerForUpdates: (store, type) ->
    modelKey = @_serializer.serializeTypeName(type)
    if hub = $.connection?[modelKey + "Hub"]
      hub.updated = (json) => @didUpdate(type, store, json)

  start: ->
    $.connection.start()