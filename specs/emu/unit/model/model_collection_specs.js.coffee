describe "Emu.ModelCollection", ->
  Person = Emu.Model.extend()
  describe "create", ->

    describe "not setting content", ->
      beforeEach ->
        @stateTracker = Emu.StateTracker.create()
        spyOn(@stateTracker, "track")
        spyOn(Emu.StateTracker, "create").andReturn(@stateTracker)
        @modelCollection = Emu.ModelCollection.create
          type: Person

      it "should have hasValue false", ->
        expect(@modelCollection.get("hasValue")).toBeFalsy()

      it "should have isDirty false", ->
        expect(@modelCollection.get("isDirty")).toBeFalsy()

      it "should set an empty array as content", ->
        expect(@modelCollection.get("content.length")).toEqual(0)

      it "should be tracked with a StateTracker", ->
        expect(@stateTracker.track).toHaveBeenCalledWith(@modelCollection)

    describe "setting content", ->
      beforeEach ->
        @content = [Ember.Object.create()]
        @modelCollection = Emu.ModelCollection.create
          content: @content

      it "should have the given collection as content", ->
        expect(@modelCollection.get("content")).toBe(@content)

  describe "pushObject", ->
    beforeEach ->
      beforeEach ->
      @modelCollection = Emu.ModelCollection.create
        type: Person
        store: @store
      @modelCollection.on "didStateChange", => @didStateChange = true
      @modelCollection.pushObject(Person.create())

    it "should have fired a state change event", ->
      expect(@didStateChange).toBeTruthy()

    it "should have isDirty true", ->
      expect(@modelCollection.get("isDirty")).toBeTruthy()

    it "should have hasValue true", ->
      expect(@modelCollection.get("hasValue")).toBeTruthy()

  describe "createRecord", ->

    describe "without subscribeToUpdates", ->
      beforeEach ->
        @store = Ember.Object.create()
        @modelCollection = Emu.ModelCollection.create
          type: App.Person
          store: @store
        @modelCollection.on "didStateChange", => @didStateChange = true
        @result = @modelCollection.createRecord(id: 1, name: "larry")

      it "should have fired a state change event", ->
        expect(@didStateChange).toBeTruthy()

      it "should return a model of type Person", ->
        expect(@result.constructor.toString()).toBe("App.Person")

      it "should add the item to the collection", ->
        expect(@modelCollection.get("length")).toEqual(1)
        expect(@modelCollection.get("firstObject")).toBe(@result)

      it "should set the properties on the new object", ->
        expect(@result.get("id")).toEqual(1)
        expect(@result.get("name")).toEqual("larry")

      it "should pass the store to the child model", ->
        expect(@result.get("store")).toBe(@store)

      it "should have hasValue true", ->
        expect(@modelCollection.get("hasValue")).toBeTruthy()

      it "should have the collection as the parent for the model", ->
        expect(@result.get("parent")).toBe(@modelCollection)

    describe "with subscribeToUpdates", ->
      beforeEach ->
        @store = Ember.Object.create()
        @model = App.Person.create()
        spyOn(App.Person, "create").andReturn(@model)
        spyOn(@model, "subscribeToUpdates")
        @modelCollection = Emu.ModelCollection.create
          type: App.Person
          store: @store
        @modelCollection.subscribeToUpdates()
        @result = @modelCollection.createRecord(id: 1, name: "larry")

      it "should call subscribeToUpdates on the new model", ->
        expect(@model.subscribeToUpdates).toHaveBeenCalled()

  describe "deleteRecord", ->
    beforeEach ->
      @store = Ember.Object.create()
      @modelCollection = Emu.ModelCollection.create
        type: App.Person
        store: @store
      @model = @modelCollection.createRecord(id: 1, name: "larry")
      @modelCollection.on "didStateChange", => @didStateChange = true
      @modelCollection.deleteRecord(@model)

    it "should have fired a state change event", ->
      expect(@didStateChange).toBeTruthy()

    it "should have no items left in the collection", ->
      expect(@modelCollection.get("length")).toEqual(0)

describe "clear", ->
  beforeEach ->
    @store = Ember.Object.create()
    @modelCollection = Emu.ModelCollection.create
      type: App.Person
      store: @store
    @modelCollection.pushObject(App.Person.create())
    @modelCollection.on "didStateChange", => @didStateChange = true
    @modelCollection.clear()

  it "should have fired a state change event", ->
    expect(@didStateChange).toBeTruthy()

  it "should have no items", ->
    expect(@modelCollection.get("length")).toEqual(0)

  it "should have hasValue false", ->
    expect(@modelCollection.get("hasValue")).toBeFalsy()

  describe "modify child in collection non dirty collection", ->
    beforeEach ->
      @store = Ember.Object.create()
      @modelCollection = Emu.ModelCollection.create
        type: App.Person
        store: @store
      @modelCollection.pushObject(App.Person.create())
      @modelCollection.on "didStateChange", => @didStateChange = true
      @modelCollection.set("firstObject.name", "Paddington Bear")

    it "should have fired a state change event", ->
      expect(@didStateChange).toBeTruthy()