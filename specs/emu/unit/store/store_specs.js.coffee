describe "Emu.Store", ->    
  adapter = Ember.Object.create
    findAll: ->
    findById: ->
    findQuery: ->
    insert: ->
    update: ->
  Adapter = 
    create: -> adapter
  Person = Emu.Model.extend
    name: Emu.field("string")
  describe "create", ->
    describe "no adapter specified", ->
      beforeEach ->
        Emu.set("defaultStore", undefined)
        spyOn(Emu.RestAdapter, "create")
        @store = Emu.Store.create()
      it "should create a RestAdapter by default", ->
        expect(Emu.RestAdapter.create).toHaveBeenCalled()
      it "should set the instance of itself to the defaultStore property on the EMU namespecs", ->
        expect(Emu.get("defaultStore")).toBe(@store)
      it "should create an new modelCollections", ->
        expect(@store.get("modelCollections")).toEqual({})
      it "should create an new queryCollections", ->
        expect(@store.get("queryCollections")).toEqual({})

    describe "with push data adapter", ->
      beforeEach ->
        @pushAdapter =
          create: -> this
          start: ->
        spyOn(@pushAdapter, "create").andCallThrough()
        spyOn(@pushAdapter, "start")
        @store = Emu.Store.create(pushAdapter: @pushAdapter)
      it "should create a push adapter", ->
        expect(@pushAdapter.create).toHaveBeenCalled()
      it "should start the push adapter", ->
        expect(@pushAdapter.start).toHaveBeenCalledWith(@store)

  describe "findAll", ->   

    describe "starts loading", ->
      beforeEach ->     
        @models = Emu.ModelCollection.create(type: Person)
        spyOn(Emu.ModelCollection, "create").andReturn(@models)
        spyOn(adapter, "findAll")
        @store = Emu.Store.create
          adapter: Adapter
        @result = @store.findAll(Person)
      it "should have created an internal collection for the records, with a reference to the store and the model type", ->     
        expect(Emu.ModelCollection.create).toHaveBeenCalledWith(type: Person, store: @store)
      it "should call the findAll method on the adapter", ->
        expect(adapter.findAll).toHaveBeenCalledWith(Person, @store, @models)
      it "should set isLoading on the models to true" , ->
        expect(@result.get("isLoading")).toBeTruthy()
      it "should return the model collection", ->
        expect(@result).toEqual(@models)    

    describe "second query executes", ->
      beforeEach ->
        @models = Emu.ModelCollection.create()
        spyOn(Emu.ModelCollection, "create").andReturn(@models)
        spyOn(adapter, "findAll")
        @store = Emu.Store.create
          adapter: Adapter
        @store.findAll(Person)
        @result = @store.findAll(Person)
      it "should create a new ModelCollection only once", ->
        expect(Emu.ModelCollection.create.calls.length).toEqual(1)
      it "should call the findAll method on the adapter only once", ->
        expect(adapter.findAll.calls.length).toEqual(1)

    describe "collection already loaded", ->
      beforeEach ->
        @models = Emu.ModelCollection.create(isLoaded: true)
        spyOn(Emu.ModelCollection, "create").andReturn(@models)
        spyOn(adapter, "findAll")
        @store = Emu.Store.create
          adapter: Adapter
        @result = @store.findAll(Person)
      it "should not call the findAll method on the adapter", ->
        expect(adapter.findAll).not.toHaveBeenCalled()
      it "should return the model collection", ->
        expect(@result).toEqual(@models)

  describe "didFindAll", ->
    beforeEach ->
      @models = Emu.ModelCollection.create(isLoading: true)     
      @store = Emu.Store.create
        adapter: Adapter
      @store.didFindAll(@models)      
    it "should set isLoading true on the model collection", ->
      expect(@models.get("isLoading")).toBeFalsy()
    it "should set isLoaded false on the model collection", ->
      expect(@models.get("isLoaded")).toBeTruthy()    

  describe "findById", ->

    describe "starts loading", ->
      
      describe "without custom primaryKey", ->
        beforeEach ->
          @model = Person.create(id: 5)
          @modelCollection = Emu.ModelCollection.create(Person)
          spyOn(Emu.ModelCollection, "create").andReturn(@modelCollection)
          spyOn(@modelCollection, "createRecord").andReturn(@model)
          spyOn(adapter, "findById")
          @store = Emu.Store.create
            adapter: Adapter
          @result = @store.findById(Person, 5)
        it "should set the id on the model with the ID", ->
          expect(@modelCollection.createRecord).toHaveBeenCalled()
        it "should set the model in a loading state", ->
          expect(@model.get("isLoading")).toBeTruthy()
        it "should call the findById method on the adapter", ->
          expect(adapter.findById).toHaveBeenCalledWith(Person, @store, @model, 5)
        it "should return the model", ->
          expect(@result).toEqual(@model)

      describe "with custom primaryKey", ->
        Foo = Emu.Model.extend
            personId: 10
        beforeEach ->
          @model = Foo.create()
          @modelCollection = Emu.ModelCollection.create()
          spyOn(Emu.ModelCollection, "create").andReturn(@modelCollection)
          spyOn(@modelCollection, "createRecord").andReturn(@model)
          spyOn(adapter, "findById")
          @store = Emu.Store.create
            adapter: Adapter
          @result = @store.findById(Foo, 10)
        it "should set the id on the model with the personId", ->
          expect(@result.get("personId")).toEqual(10)
        it "should call the findById method on the adapter", ->
          expect(adapter.findById).toHaveBeenCalledWith(Foo, @store, @model, 10)

    describe "query already pending", ->
      describe "default primaryKey", ->
        beforeEach ->
          spyOn(adapter, "findById")      
          @store = Emu.Store.create
            adapter: Adapter      
          @firstResult = @store.findById(Person, 5)   
          @secondResult = @store.findById(Person, 5)
        it "should return the same model for both calls", ->
          expect(@firstResult).toBe(@secondResult)
        it "should call the findById method on the adapter just once", ->
          expect(adapter.findById.calls.length).toEqual(1)
      
      describe "custom primaryKey", ->
        beforeEach ->
          Foo = Emu.Model.extend
            fooId: Emu.field("string", {primaryKey: true})
          spyOn(adapter, "findById")      
          @store = Emu.Store.create
            adapter: Adapter      
          @firstResult = @store.findById(Foo, 5)   
          @secondResult = @store.findById(Foo, 5)
        it "should return the same model for both calls", ->
          expect(@firstResult).toBe(@secondResult)
        it "should call the findById method on the adapter just once", ->
          expect(adapter.findById.calls.length).toEqual(1)

    describe "record already loaded", ->
      beforeEach ->
        spyOn(adapter, "findById")
        @loadedModel = Person.create(id: 5, isLoaded: true)
        modelCollections = {}
        modelCollections[Person] = Emu.ModelCollection.create()
        modelCollections[Person].pushObject(@loadedModel)
        @store = Emu.Store.create
          adapter: Adapter
          modelCollections: modelCollections        
        @result = @store.findById(Person, 5)    
      it "should return the existing model", ->
        expect(@result).toBe(@loadedModel)
      it "should not call the findById method", ->
        expect(adapter.findById).not.toHaveBeenCalled()

  describe "didFindById", ->
    beforeEach ->
      @model = Person.create(isLoaded: false, isLoading: true, isDirty: true)
      spyOn(Person, "create").andReturn(@model)
      @store = Emu.Store.create
        adapter: Adapter
      @store.didFindById(@model)
    it "should set isLoading to false", ->
      expect(@model.get("isLoading")).toBeFalsy()
    it "should set isLoaded to true", ->
      expect(@model.get("isLoaded")).toBeTruthy()
    it "should have isDirty set to false", ->
      expect(@model.get("isDirty")).toBeFalsy()

  describe "createRecord", ->
    beforeEach ->
      @modelCollections = {}
      @modelCollections[Person] = Emu.ModelCollection.create()
      @store = Emu.Store.create   
        adapter: Adapter
        modelCollections: @modelCollections           
      @model = Person.create()
      spyOn(@modelCollections[Person], "createRecord").andReturn(@model)
      @result = @store.createRecord(Person, name: "bert")
    it "should return the created model", ->
      expect(@result).toEqual(@model)
    it "should should create the model with the propert hash", ->
      expect(@modelCollections[Person].createRecord).toHaveBeenCalledWith(name: "bert")
    it "should set the model to dirty", ->
      expect(@result.get("isDirty")).toEqual(true)

  describe "save", ->
    
    describe "new record", ->
      beforeEach ->
        @store = Emu.Store.create   
          adapter: Adapter
        spyOn(adapter, "insert")
        @model = @store.createRecord(Person)
        @store.save(@model)
      it "should call insert on the adapter", ->
        expect(adapter.insert).toHaveBeenCalledWith(@store, @model)

    describe "existing record (one with an id assigned)", ->
      beforeEach ->
        @store = Emu.Store.create   
          adapter: Adapter
        spyOn(adapter, "update")
        @model = @store.createRecord(Person)
        spyOn(@model, "primaryKeyValue").andReturn(10)
        @store.save(@model)
      it "should call update on the adapter", ->
        expect(adapter.update).toHaveBeenCalledWith(@store, @model)
  
  describe "didSave", ->
    beforeEach ->
      @store = Emu.Store.create   
        adapter: Adapter
      @model = @store.createRecord(Person)
      @model.set("isLoading", true)
      @store.didSave(@model)
    it "should not be dirty", ->
      expect(@model.get("isDirty")).toBeFalsy()
    it "should be loaded", ->
      expect(@model.get("isLoaded")).toBeTruthy()
    it "should not be loading", ->
      expect(@model.get("isLoading")).toBeFalsy()

  describe "loadAll", ->
    beforeEach ->
      @collection = Emu.ModelCollection.create(type:Person)
      spyOn(Emu.ModelCollection, "create")
      spyOn(adapter, "findAll")
      @store = Emu.Store.create   
        adapter: Adapter
      @store.loadAll(@collection)
    it "should call the findAll method on the adapter with the collection which was passed", ->
      expect(adapter.findAll).toHaveBeenCalledWith(Person, @store, @collection)
    it "should not create a new collection", ->
      expect(Emu.ModelCollection.create).not.toHaveBeenCalled()

  describe "loadModel", ->
    describe "start loading", ->
      beforeEach ->
        @model = Person.create(id: 4)
        spyOn(adapter, "findById")
        @store = Emu.Store.create   
          adapter: Adapter
        @store.loadModel(@model)
      it "should set isLoading on the model to true", ->
        expect(@model.get("isLoading")).toBeTruthy()
      it "should call the findById method on the adapter", ->
        expect(adapter.findById).toHaveBeenCalledWith(Person, @store, @model, 4)

    describe "already loading", ->
      beforeEach ->
        @model = Person.create(id: 4, isLoading: true)
        spyOn(adapter, "findById")
        @store = Emu.Store.create   
          adapter: Adapter
        @store.loadModel(@model)
      it "should not call the findById method on the adapter", ->
        expect(adapter.findById).not.toHaveBeenCalled()

  describe "findQuery", ->
    
    describe "starts loading", ->
      beforeEach ->     
        @models = Emu.ModelCollection.create(type: Person)
        spyOn(Emu.ModelCollection, "create").andReturn(@models)
        spyOn(adapter, "findQuery")
        @store = Emu.Store.create
          adapter: Adapter
        @query = {name: "Mr Bean"}
        @result = @store.findQuery(Person, {name: "Mr Bean"})
      it "should have created an internal collection for the records, with a reference to the store and the model type", ->     
        expect(Emu.ModelCollection.create).toHaveBeenCalledWith(type: Person, store: @store)
      it "should call the findQuery method on the adapter", ->
        expect(adapter.findQuery).toHaveBeenCalledWith(Person, @store, @models, {name: "Mr Bean"})
      it "should set isLoading on the models to true" , ->
        expect(@result.get("isLoading")).toBeTruthy()
      it "should return the model collection", ->
        expect(@result).toEqual(@models)

    describe "finishes loaded", ->     
      beforeEach ->
        @models = Emu.ModelCollection.create(isLoading: true)     
        @store = Emu.Store.create
          adapter: Adapter
        @store.didFindQuery(@models)      
      it "should set isLoading true on the model collection", ->
        expect(@models.get("isLoading")).toBeFalsy()
      it "should set isLoaded false on the model collection", ->
        expect(@models.get("isLoaded")).toBeTruthy()   

    describe "same query twice", ->
      beforeEach ->
        spyOn(adapter, "findQuery")
        @store = Emu.Store.create
          adapter: Adapter
        @query = {name: "Mr Bean"}
        @result1 = @store.findQuery(Person, {age: "40", weight: "160lb"})
        @result2 = @store.findQuery(Person, {age: "40", weight: "160lb"})
      it "should call the findQuery method on the adapter only once", ->
        expect(adapter.findQuery.calls.length).toEqual(1)
      it "should return the same collection for both calls", ->
        expect(@result1).toEqual(@result2)

    describe "two different queries", ->
      beforeEach ->
        spyOn(adapter, "findQuery")
        @store = Emu.Store.create
          adapter: Adapter
        @query = {name: "Mr Bean"}
        @result1 = @store.findQuery(Person, {age: "50", weight: "160lb"})
        @result2 = @store.findQuery(Person, {weight: "170lb", age: "40"})
      it "should call the findQuery method on the adapter twice", ->
        expect(adapter.findQuery.calls.length).toEqual(2)
      it "should return a different collection for each call", ->
        expect(@result1).not.toEqual(@result2)

  describe "findPredicate", ->

    describe "when all of that type are loaded", ->
      beforeEach ->
        @collection = Emu.ModelCollection.create(isLoaded: true)
        @collection.pushObject(Person.create(age: 20))
        @collection.pushObject(Person.create(age: 30))
        @store = Emu.Store.create()
        spyOn(@store, "findAll").andReturn(@collection)
        spyOn(Emu.ModelCollection, "create").andCallThrough()
        @predicate = (person) -> person.get("age") > 25
        spyOn(this, "predicate").andCallThrough()
        @result = @store.findPredicate(Person, @predicate)
      it "should find all the records", ->
        expect(@store.findAll).toHaveBeenCalledWith(Person)
      it "should create a new collection to contain the results", ->
        expect(Emu.ModelCollection.create).toHaveBeenCalledWith(type: Person, store: @store, isLoading: false, isLoaded: true)
      it "should run the predicate on each item", ->
        expect(@predicate).toHaveBeenCalledWith(@collection.get("firstObject"))
        expect(@predicate).toHaveBeenCalledWith(@collection.get("lastObject"))
      it "should return 1 result", ->
        expect(@result.get("length")).toEqual(1)
      it "should return the result which passes the predicate function", ->
        expect(@result.get("firstObject")).toEqual(@collection.get("lastObject"))
      it "should be in a loaded state", ->
        expect(@result.get("isLoaded")).toBeTruthy()
      it "should not be in a loading state", ->
        expect(@result.get("isLoading")).toBeFalsy()

    describe "when all of that type are not loaded", ->
      beforeEach ->
        @collection = Emu.ModelCollection.create(isLoaded: false)
        @store = Emu.Store.create()
        spyOn(@store, "findAll").andReturn(@collection)
        @result = @store.findPredicate(Person, -> true)
      it "should find all the records", ->
        expect(@store.findAll).toHaveBeenCalledWith(Person)
      it "should not return an empty collection", ->
        expect(@result.get("length")).toEqual(0)
      it "should not be in a loaded state", ->
        expect(@result.get("isLoaded")).toBeFalsy()
      it "should be in a loading state", ->
        expect(@result.get("isLoading")).toBeTruthy()

    describe "finishes loading", ->
      beforeEach ->
        @collection = Emu.ModelCollection.create(type:Person, isLoaded: false)
        @store = Emu.Store.create()
        spyOn(@store, "findAll").andReturn(@collection)
        @predicate = (person) -> person.get("age") > 25
        spyOn(this, "predicate").andCallThrough()
        @result = @store.findPredicate(Person, @predicate)
        @collection.pushObject(Person.create(age: 20))
        @collection.pushObject(Person.create(age: 30))
        @store.didFindAll(@collection)
      it "should find all the records", ->
        expect(@store.findAll).toHaveBeenCalledWith(Person)
      it "should not return an empty collection", ->
        expect(@result.get("length")).toEqual(1)
      it "should be in a loaded state", ->
        expect(@result.get("isLoaded")).toBeTruthy()
      it "should not be in a loading state", ->
        expect(@result.get("isLoading")).toBeFalsy()

  describe "find", ->

    describe "with ID", ->
      beforeEach ->
        @store = Emu.Store.create()
        spyOn(@store, "findById")
        @store.find(Person, 5)
      it "should forward the call to findById", ->
        expect(@store.findById).toHaveBeenCalledWith(Person, 5)

    describe "with string ID", ->
      beforeEach ->
        @store = Emu.Store.create()
        spyOn(@store, "findById")
        @store.find(Person, "5")
      it "should forward the call to findById", ->
        expect(@store.findById).toHaveBeenCalledWith(Person, "5")

    describe "without an ID", ->
      beforeEach ->
        @store = Emu.Store.create()
        spyOn(@store, "findAll")
        @store.find(Person)
      it "should forward the call to findAll", ->
        expect(@store.findAll).toHaveBeenCalledWith(Person) 

    describe "with a query parameter hash", ->
      beforeEach ->
        @store = Emu.Store.create()
        spyOn(@store, "findQuery")
        @store.find(Person, {name: "charlie"})
      it "should forward the call to findQuery", ->
        expect(@store.findQuery).toHaveBeenCalledWith(Person, {name: "charlie"}) 

    describe "with a predicate function", -> 
      beforeEach ->
        @store = Emu.Store.create()
        spyOn(@store, "findPredicate")
        @predicate = (person) -> person.get("name")
        @store.find(Person, @predicate)
      it "should forward the call to findPredicate", ->
        expect(@store.findPredicate).toHaveBeenCalledWith(Person, @predicate) 

  describe "subscribeToUpdates", ->
    
    describe "when there is a push data adapter", ->
      describe "registering once", ->
        beforeEach ->
          @model = Person.create(id:9)
          @pushAdapter = 
            create: -> this
            start: ->
            listenForUpdates: jasmine.createSpy()
          @store = Emu.Store.create(pushAdapter: @pushAdapter)
          @store.subscribeToUpdates(@model)        
        it "should have the model registered as updatable", ->
          expect(@store.findUpdatable(Person, 9)).toBe(@model)
      
      describe "registering twice", ->
        beforeEach ->
          @model = Person.create(id:9)
          @pushAdapter = 
            create: -> this
            start: ->
            listenForUpdates: jasmine.createSpy()
          @store = Emu.Store.create(pushAdapter: @pushAdapter)
          @store.subscribeToUpdates(@model)
          @store.subscribeToUpdates(@model)
        it "should only have 1 registration in the internal collection", ->
          expect(@store.get("updatableModels")[@model.constructor.toString()]?.length).toEqual(1)

    describe "when there is no push data adapter", ->
      beforeEach ->
        @model = Person.create(id:9)
        @store = Emu.Store.create()
        try
          @store.subscribeToUpdates(@model)
        catch exception
          @exception = exception
      it "should throw an exception", ->
        expect(@exception.message).toEqual("You need to register a Emu.PushDataAdapter on your store: Emu.Store.create({pushAdapter: App.MyPushAdapter.create()});")

