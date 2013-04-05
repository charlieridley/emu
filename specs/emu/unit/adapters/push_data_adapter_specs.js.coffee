describe "Emu.PushDataAdapter", ->
  serializer = Ember.Object.create
    serializeTypeName: ->
    deserializeCollection: ->
    deserializeModel: ->
    serializeModel: ->
    serializeQueryHash: ->
  Serializer = 
    create: -> serializer

  describe "create", ->

    describe "no serializer specified", ->
      beforeEach ->
        spyOn(Emu.Serializer, "create")
        @adapter = Emu.PushDataAdapter.create()
      it "should create the default serializer", ->
        expect(Emu.Serializer.create).toHaveBeenCalled()

    describe "serializer specified", ->
      beforeEach ->        
        spyOn(Serializer, "create")
        @adapter = Emu.RestAdapter.create(serializer: Serializer)
      it "should create the default serializer", ->
        expect(Serializer.create).toHaveBeenCalled()

  describe "listenForUpdates", ->
    describe "once", ->
      beforeEach ->
        TestAdapter = Emu.PushDataAdapter.extend
          listen: ->
        @store = {}
        @model = App.Person.create(id: 6)
        @adapter = TestAdapter.create(registerForUpdates: ->)
        spyOn(@adapter, "registerForUpdates")
        @adapter.listenForUpdates(@store, App.Person)
      it "should register for updates", ->
        expect(@adapter.registerForUpdates).toHaveBeenCalledWith(@store, App.Person)  

  describe "didUpdate", ->
    beforeEach ->
      @json = {id: 6, address: {town: "Exeter"}}
      spyOn(Emu.Model, "primaryKey").andCallThrough()
      @adapter = Emu.PushDataAdapter.create(serializer: Serializer)
      @model = App.Person.create()
      @store = 
        findUpdatable: ->          
      spyOn(@store, "findUpdatable").andReturn(@model)
      spyOn(serializer, "deserializeModel")
      @adapter.didUpdate(App.Person, @store, @json)
    it "should find the primary key for the type", ->
      expect(Emu.Model.primaryKey).toHaveBeenCalledWith(App.Person)
    it "should find from the store", ->
      expect(@store.findUpdatable).toHaveBeenCalledWith(App.Person, 6)
    it "should deserialize the json payload to the model", ->
      expect(serializer.deserializeModel).toHaveBeenCalledWith(@model, @json)