describe "Emu.Model", ->  
  Person = Emu.Model.extend
    name: Emu.field("string")
    address: Emu.field("App.Address")
    orders: Emu.field("App.Order", {collection:true})
  
  it "should have a flag to indicate the type is an Emu model", ->
    expect(Person.isEmuModel).toBeTruthy()

  describe "create", ->
    describe "no values", ->
      beforeEach ->
        @person = Person.create()
      
      it "should have hasValue false", ->
        expect(@person.get("hasValue")).toBeFalsy()
    
    describe "multiple primary keys specified", ->
      beforeEach ->
        @Foo = Emu.Model.extend
          fooId: Emu.field("string", {primaryKey: true})
          barId: Emu.field("string", {primaryKey: true})
        try 
          @foo = @Foo.create()
        catch exception
          @exception = exception
      
      it "should throw an exception", ->
        expect(@exception.message).toContain("You can only mark one field as a primary key")
  
  describe "primaryKey", ->

    describe "no primary key specified", ->
      beforeEach ->
        Foo = Emu.Model.extend()
        @foo = Foo.create(id:"10")
      
      it "should have primaryKey as 'id'", ->
        expect(@foo.primaryKey()).toEqual("id")

    describe "primary key specified", ->
      beforeEach ->
        Foo = Emu.Model.extend
          fooId: Emu.field("string", {primaryKey: true})
        @foo = Foo.create()
      
      it "should have primaryKey as 'fooId'", ->
        expect(@foo.primaryKey()).toEqual("fooId")

  describe "primaryKeyValue", ->

    describe "get", ->
      beforeEach ->
        Foo = Emu.Model.extend
          fooId: Emu.field("string", {primaryKey: true})
        @foo = Foo.create(fooId:"10")
      
      it "should have primaryKeyValue as '10'", ->
        expect(@foo.primaryKeyValue()).toEqual("10")

    describe "set", ->

      describe "with existing value", ->
        
        beforeEach ->
          Foo = Emu.Model.extend
            fooId: Emu.field("string", {primaryKey: true})
          @foo = Foo.create(fooId:"10")
          @foo.primaryKeyValue("20")
        
        it "should have primaryKeyValue as '20'", ->
          expect(@foo.primaryKeyValue()).toEqual("20")

        it "should have hasValue true", ->
          expect(@foo.get("hasValue")).toBeTruthy()

      describe "without existing value", ->
        
        beforeEach ->
          Foo = Emu.Model.extend
            fooId: Emu.field("string", {primaryKey: true})
          @foo = Foo.create()
          @foo.primaryKeyValue("20")
        
        it "should have primaryKeyValue as '20'", ->
          expect(@foo.primaryKeyValue()).toEqual("20")

        it "should have hasValue true", ->
          expect(@foo.get("hasValue")).toBeTruthy()

  
  describe "createRecord", ->
    beforeEach ->
        Ember.set(Emu, "defaultStore", undefined)
        @store = Emu.Store.create()
        spyOn(@store, "createRecord")
        @model = Person.createRecord()
      
      it "should proxy the call to the default store", ->
        expect(@store.createRecord).toHaveBeenCalledWith(Person)

  describe "find", ->
    beforeEach ->
      Ember.set(Emu, "defaultStore", undefined)
      @store = Emu.Store.create()
      spyOn(@store, "find")
      @model = Person.find(5)
    
    it "should proxy the call to the default store", ->
      expect(@store.find).toHaveBeenCalledWith(Person, 5)

  describe "save", ->
    
    describe "no store specified", ->
      beforeEach ->
        Ember.set(Emu, "defaultStore", undefined)
        @store = Emu.Store.create()
        spyOn(@store, "save")
        @model = Person.createRecord()
        @model.save()
      
      it "should proxy the call to the store", ->
        expect(@store.save).toHaveBeenCalledWith(@model)
    
    describe "passing a store", ->
      beforeEach ->
        Ember.set(Emu, "defaultStore", undefined)
        @defaultStore = Emu.Store.create()
        @newStore = Emu.Store.create()
        spyOn(@defaultStore, "save")
        spyOn(@newStore, "save")
        @model = Person.create(store: @newStore)
        @model.save()
      
      it "should proxy the call to the specified store", ->
        expect(@newStore.save).toHaveBeenCalledWith(@model)
      
      it "should not proxy the call to the default store", ->
        expect(@defaultStore.save).not.toHaveBeenCalled()

  describe "modifying a property", ->

    describe "simple field", ->
      beforeEach ->
        @model = Person.create(isDirty:false)
        @model.set("name", "Harold")
      
      it "should be in a dirty state", ->
        expect(@model.get("isDirty")).toBeTruthy()
      
      it "should have hasValue set to true", ->
        expect(@model.get("hasValue")).toBeTruthy()
      
    describe "collection field", ->
      beforeEach ->
        @model = Person.create
          isDirty:false             
        @model.get("orders").pushObject(App.Order.create())
      
      it "should be in a dirty state", ->
        expect(@model.get("isDirty")).toBeTruthy()  

      it "should have hasValue set to true", ->
        expect(@model.get("hasValue")).toBeTruthy()

  describe "getAttr", ->    
    
    describe "collection", ->      
      
      describe "not set", ->
        
        describe "get once", ->
          beforeEach ->
            spyOn(Emu.ModelCollection, "create").andCallThrough()
            @store = {}
            @model = Person.create(store: @store)           
            @result = Emu.Model.getAttr(@model, "orders")
          
          it "should create an empty collection", ->
            expect(Emu.ModelCollection.create).toHaveBeenCalled()
          
          it "should have the model as the parent", ->
            expect(@result.get("parent")).toBe(@model)
          
          it "should be of the type specified in the meta data for the field", ->
            expect(@result.get("type")).toBe(App.Order)
          
          it "should pass the store refernece", ->
            expect(@result.get("store")).toBe(@store)

        describe "get twice", ->
          beforeEach ->
            spyOn(Emu.ModelCollection, "create").andCallThrough()
            @model = Person.create()           
            @result1 = Emu.Model.getAttr(@model, "orders")
            @result2 = Emu.Model.getAttr(@model, "orders")
          
          it "should return the same collection", ->
            expect(@result1).toBe(@result2)

        describe "updatable collection", ->
          beforeEach ->
            Foo = Emu.Model.extend
              people: Emu.field("App.Person", {collection: true, updatable: true})
            @collection = Emu.ModelCollection.create()
            spyOn(Emu.ModelCollection, "create").andReturn(@collection)
            spyOn(@collection, "subscribeToUpdates")            
            @model = Foo.create()        
            Emu.Model.getAttr(@model, "people")
          
          it "should create an empty collection", ->
            expect(@collection.subscribeToUpdates).toHaveBeenCalled()
    
    describe "model", ->

      describe "not set", ->

        describe "get once", ->
          beforeEach ->
            spyOn(App.Address, "create").andCallThrough()
            @model = Person.create()
            @result = Emu.Model.getAttr(@model, "address")
          
          it "should create an empty model", ->
            expect(App.Address.create).toHaveBeenCalled()

    describe "subscribeToUpdates", ->
      beforeEach ->
        Ember.set(Emu, "defaultStore", undefined)
        @store = Emu.Store.create()
        spyOn(@store, "subscribeToUpdates")
        @model = Person.createRecord()
        @model.subscribeToUpdates()
      
      it "should proxy the call to the store", ->
        expect(@store.subscribeToUpdates).toHaveBeenCalledWith(@model)

    describe "clear", ->
      beforeEach ->
        @model = Person.create()
        @model.set("name", "Bertie")
        @model.set("address.town", "Dartmouth")
        @model.get("orders").pushObject(App.Order.create(orderCode: "1234"))
        spyOn(@model.get("address"), "clear")
        spyOn(@model.get("orders"), "clear")
        @model.clear()

      it "should clear the simple field", ->
        expect(@model.get("name")).toBeUndefined()

      it "should call clear on the model field", ->
        expect(@model.get("address").clear).toHaveBeenCalled()

      it "should call clear on the collection field", ->
        expect(@model.get("orders").clear).toHaveBeenCalled()

      it "should have hasValue false", ->
        expect(@model.get("hasValue")).toBeFalsy()

  describe "setAttr", ->
    beforeEach ->
      @model = Person.create()
      Emu.Model.setAttr @model, "name", "charlie"
    
    it "should have hasValue true", ->
      expect(@model.get("hasValue")).toBeTruthy()