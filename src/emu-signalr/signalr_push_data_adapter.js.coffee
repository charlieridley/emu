Emu.SignalrPushDataAdapter = Emu.PushDataAdapter.extend
  registerForUpdates: (store, type) ->
    modelKey = @_serializer.serializeTypeName(type)
    if hub = $.connection?[modelKey + "Hub"]
      hub.updated ?= (json) => @didUpdate(type, store, json)

  start: (store) ->
    @_super(store)
    $.connection.hub.logging = true;
    $.connection.hub.start()
            .done(-> console.debug("Connected to SignalR hub"))
            .fail(-> console.debug("Failed to connect to SignalR hub"))