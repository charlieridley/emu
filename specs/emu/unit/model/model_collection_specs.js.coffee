describe "Emu.ModelCollection", ->
  Person = Emu.Model.extend() 
  describe "create", ->
    beforeEach ->
      @modelCollection = Emu.ModelCollection.create
        type: Person
        store: @store
    it "should have hasValue false", ->
      expect(@modelCollection.get("hasValue")).toBeFalsy()
    it "should have isDirty false", ->
      expect(@modelCollection.get("isDirty")).toBeFalsy()

  describe "isDirty", ->
    beforeEach ->
      beforeEach ->
      @modelCollection = Emu.ModelCollection.create
        type: Person
        store: @store
      @modelCollection.pushObject(Person.create())
    it "should have isDirty true", ->
      expect(@modelCollection.get("isDirty")).toBeTruthy()
  
  describe "createRecord", ->
    beforeEach ->   
      @store = Ember.Object.create()
      @modelCollection = Emu.ModelCollection.create
        type: App.Person
        store: @store
      @result = @modelCollection.createRecord(id: 1, name: "larry")
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
