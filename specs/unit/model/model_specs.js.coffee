describe "Emu.Model", ->  
  Person = Emu.Model.extend
    name: Emu.field("string")
    orders: Emu.field("App.Order", {collection:true})
  it "should have a flag to indicate the type is an Emu model", ->
    expect(Person.isEmuModel).toBeTruthy()
  describe "createRecord", ->
    beforeEach ->
      Ember.set(Emu, "defaultStore", undefined)
      @store = Emu.Store.create()
      spyOn(@store, "createRecord")
      @model = Person.createRecord()
    it "should proxy the call to the store", ->
      expect(@store.createRecord).toHaveBeenCalledWith(Person)
  describe "find", ->
    beforeEach ->
      Ember.set(Emu, "defaultStore", undefined)
      @store = Emu.Store.create()
      spyOn(@store, "find")
      @model = Person.find(5)
    it "should proxy the call to the store", ->
      expect(@store.find).toHaveBeenCalledWith(Person, 5)
  describe "save", ->
    beforeEach ->
      Ember.set(Emu, "defaultStore", undefined)
      @store = Emu.Store.create()
      spyOn(@store, "save")
      @model = Person.createRecord()
      @model.save()
    it "should proxy the call to the store", ->
      expect(@store.save).toHaveBeenCalledWith(@model)
  describe "When modifying a property on a model", ->
    beforeEach ->
      @model = Person.create(isDirty:false)
      @model.set("name", "Harold")
    it "should be in a dirty state", ->
      expect(@model.get("isDirty")).toBeTruthy()
  describe "When modifying a collection property on a model", ->
    beforeEach ->
      @model = Person.create
        isDirty:false             
      @model.get("orders").pushObject(App.Order.create())
    it "should be in a dirty state", ->
      expect(@model.get("isDirty")).toBeTruthy()      

  