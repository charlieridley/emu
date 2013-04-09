describe "Emu.SignalrPushDataAdapter", ->
  serializer = Ember.Object.create
    serializeTypeName: ->
  Serializer = 
    create: -> serializer
  $.connection = 
    personHub: {}
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
        expect($.connection.personHub.updated).not.toBeUndefined()

    describe "twice", ->
      beforeEach ->      
        @store = {}
        spyOn(serializer, "serializeTypeName").andReturn("person")
        @adapter = Emu.SignalrPushDataAdapter.create(serializer: Serializer)
        @adapter.registerForUpdates(@store, App.Person)
        @updatedFunc = $.connection.personHub.updated
        @adapter.registerForUpdates(@store, App.Person)
      it "should not re-register the updated function", ->
        expect(@updatedFunc).toBe($.connection.personHub.updated)

  describe "updated", ->
    beforeEach ->
      $.connection =
        personHub: {}
      @json = {name: "bob"}
      @store = {}
      spyOn(serializer, "serializeTypeName").andReturn("person")
      @adapter = Emu.SignalrPushDataAdapter.create(serializer: Serializer)
      spyOn(@adapter,"didUpdate")
      @adapter.registerForUpdates(@store, App.Person)
      $.connection.personHub.updated(@json)
    it "should call didUpdate on the adapter", ->
      expect(@adapter.didUpdate).toHaveBeenCalledWith(App.Person, @store, @json)

  describe "start", ->
    beforeEach ->
      $.connection =
        start: jasmine.createSpy()
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
      expect($.connection.start).toHaveBeenCalled()