describe "Emu.SignalrPushDataAdapter", ->
  serializer = Ember.Object.create
    serializeTypeName: ->
  Serializer = 
    create: -> serializer
  $.connection =     
      personHub: 
        client: {}
  describe "registerForUpdates", ->
    describe "once", ->
      beforeEach ->      
        @store = {}
        spyOn(serializer, "serializeTypeName").andReturn("person")
        Adapter = Emu.SignalrPushDataAdapter.extend()
        @adapter = Emu.SignalrPushDataAdapter.create(serializer: Serializer)
        @adapter.registerForUpdates(@store, App.Person)
      it "should serialize the type name", ->
        expect(serializer.serializeTypeName).toHaveBeenCalledWith(App.Person)
      it "should register for 'updated' updates", ->
        expect($.connection.personHub.client.updated).not.toBeUndefined()

    describe "twice", ->
      beforeEach ->      
        @store = {}
        spyOn(serializer, "serializeTypeName").andReturn("person")
        @adapter = Emu.SignalrPushDataAdapter.create(serializer: Serializer)
        @adapter.registerForUpdates(@store, App.Person)
        @updatedFunc = $.connection.personHub.client.updated
        @adapter.registerForUpdates(@store, App.Person)
      it "should not re-register the updated function", ->
        expect(@updatedFunc).toBe($.connection.personHub.client.updated)

  describe "updated", ->
    beforeEach ->
      $.connection =
        personHub: 
          client: {}
      @json = {name: "bob"}
      @store = {}
      spyOn(serializer, "serializeTypeName").andReturn("person")
      @adapter = Emu.SignalrPushDataAdapter.create(serializer: Serializer)
      spyOn(@adapter,"didUpdate")
      @adapter.registerForUpdates(@store, App.Person)
      $.connection.personHub.client.updated(@json)
    it "should call didUpdate on the adapter", ->
      expect(@adapter.didUpdate).toHaveBeenCalledWith(App.Person, @store, @json)

  describe "start", ->
    beforeEach ->
      $.connection =
        hub:
          start: jasmine.createSpy().andReturn
            done: -> this
            fail: -> this
      MyPushAdapter = Emu.SignalrPushDataAdapter.extend(updatableTypes: ["App.Person", "App.Customer"])
      @adapter = MyPushAdapter.create()
      @store = jasmine.createSpy()
      spyOn(@adapter, "listenForUpdates")
      @adapter.start(@store)
    it "should listen for updates for App.Person", ->
      expect(@adapter.listenForUpdates).toHaveBeenCalledWith(@store, App.Person)
    it "should listen for updates for App.Customer", ->
      expect(@adapter.listenForUpdates).toHaveBeenCalledWith(@store, App.Customer)
    it "should start the signalr connection", ->
      expect($.connection.hub.start).toHaveBeenCalled()