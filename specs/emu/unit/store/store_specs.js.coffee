describe "Emu.Store", ->    
  adapter = Ember.Object.create
    findAll: ->
    findById: ->
    findQuery: ->
    findPage: ->
    insert: ->
    update: ->
    delete: -> 
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
        @models.on "didStartLoading", => @didStartLoading = true
        @result = @store.findAll(Person)

      it "should fire didStartLoading", ->
        expect(@didStartLoading).toBeTruthy()
      
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
        @models.on "didStartLoading", => @didStartLoading = true
        @result = @store.findAll(Person)

      it "should not fire didStartLoading", ->
        expect(@didStartLoading).toBeFalsy()
      
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
        @models.on "didStartLoading", => @didStartLoading = true
        @result = @store.findAll(Person)

      it "should not fire didStartLoading", ->
        expect(@didStartLoading).toBeFalsy()
      
      it "should not call the findAll method on the adapter", ->
        expect(adapter.findAll).not.toHaveBeenCalled()
      
      it "should return the model collection", ->
        expect(@result).toEqual(@models)

  describe "didFindAll", ->
    beforeEach ->
      @models = Emu.ModelCollection.create(isLoading: true)     
      @store = Emu.Store.create
        adapter: Adapter
      @models.on "didFinishLoading", => @didFinishLoading = true
      @store.didFindAll(@models)

    it "should fire didFinishLoading", ->
        expect(@didFinishLoading).toBeTruthy()
    
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
          @model.on "didStartLoading", => @didStartLoading = true
          @result = @store.findById(Person, 5)

        it "should fire didStartLoading", ->
          expect(@didStartLoading).toBeTruthy()
        
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
          @firstResult.on "didStartLoading", => @didStartLoading = true
          @secondResult = @store.findById(Person, 5)

        it "should not fire didStartLoading the second time", ->
          expect(@didStartLoading).toBeFalsy()
        
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
        @loadedModel.on "didStartLoading", => @didStartLoading = true  
        @result = @store.findById(Person, 5)    
      
      it "should not fire didStartLoading", ->
        expect(@didStartLoading).to

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
      @model.on "didFinishLoading", => @didFinishLoading = true
      @store.didFindById(@model)
    
    it "should fire didFinishLoading", ->
      expect(@didFinishLoading).toBeTruthy()

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
        @model.on "didStartSaving", => @didStartSaving = true 
        @store.save(@model)

      it "should fire didStartSaving", ->
        expect(@didStartSaving).toBeTruthy()
      
      it "should call insert on the adapter", ->
        expect(adapter.insert).toHaveBeenCalledWith(@store, @model)

    describe "existing record (one with an id assigned)", ->
      beforeEach ->
        @store = Emu.Store.create   
          adapter: Adapter
        spyOn(adapter, "update")
        @model = @store.createRecord(Person)
        spyOn(@model, "primaryKeyValue").andReturn(10)
        @model.on "didStartSaving", => @didStartSaving = true 
        @store.save(@model)

      it "should fire didStartSaving", ->
        expect(@didStartSaving).toBeTruthy()
      
      it "should call update on the adapter", ->
        expect(adapter.update).toHaveBeenCalledWith(@store, @model)
  
  describe "didSave", ->
    beforeEach ->
      @store = Emu.Store.create   
        adapter: Adapter
      @model = @store.createRecord(Person)
      @model.set("isLoading", true)
      @model.on "didFinishSaving", => @didFinishSaving = true 
      @store.didSave(@model)

    it "should fire didFinishSaving", ->
      expect(@didFinishSaving).toBeTruthy()

  describe "didError", ->
    beforeEach ->
      @store = Emu.Store.create   
        adapter: Adapter
      @model = @store.createRecord(Person)
      @model.on "didError", => @didError = true 
      @store.didError(@model)

    it "should raise didError on the model", ->
      expect(@didError).toBeTruthy()

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
        @model.on "didStartLoading", => @didStartLoading = true
        @store.loadModel(@model)

      it "should fire didStartLoading", ->
        expect(@didStartLoading).toBeTruthy()
      
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
        @models.on "didStartLoading", => @didStartLoading = true
        @result = @store.findQuery(Person, {name: "Mr Bean"})
      
      it "should fire didStartLoading", ->
        expect(@didStartLoading).toBeTruthy()

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
        @models.on "didFinishLoading", => @didFinishLoading = true
        @store.didFindQuery(@models)   

      it "should fire didFinishLoading", ->
        expect(@didFinishLoading).toBeTruthy()   
      
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
        @result1.on "didStartLoading", => @didStartLoading = true
        @result2 = @store.findQuery(Person, {age: "40", weight: "160lb"})

      it "should not fire didStartLoading the second time", ->
        expect(@didStartLoading).toBeFalsy()
      
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
        expect(Emu.ModelCollection.create).toHaveBeenCalledWith(type: Person, store: @store)
      
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

  describe "deleteRecord", ->

    describe "record is persisted", ->

      describe "starts", ->
        beforeEach ->
          @store = Emu.Store.create   
            adapter: Adapter
          @model = @store.createRecord(Person, {id: 6, name: "harry"})
          spyOn(adapter, "delete")
          @store.deleteRecord(@model)
        
        it "should call delete on the adapter", ->
          expect(adapter.delete).toHaveBeenCalledWith(@store, @model)

      describe "finishes", ->
        beforeEach ->
          @modelCollections = {}
          @modelCollections[Person] = Emu.ModelCollection.create(type: Person)
          @store = Emu.Store.create
            modelCollections: @modelCollections
          @model = @modelCollections[Person].createRecord()
          spyOn(@modelCollections[Person], "deleteRecord")
          @store.didDeleteRecord(@model)

        it "should delete the record from the modelCollection", ->
          expect(@modelCollections[Person].deleteRecord).toHaveBeenCalledWith(@model)

    describe "record is not persisted", ->
      beforeEach ->
        @modelCollections = {}
        @modelCollections[Person] = Emu.ModelCollection.create(type: Person)
        @store = Emu.Store.create   
          adapter: Adapter
          modelCollections: @modelCollections
        @model = @store.createRecord(Person, {name: "harry"})
        spyOn(adapter, "delete")
        spyOn(@modelCollections[Person], "deleteRecord")
        @store.deleteRecord(@model)
      
      it "should not call delete on the adapter", ->
        expect(adapter.delete).not.toHaveBeenCalled()
      
      it "should delete the record from the modelCollection", ->
        expect(@modelCollections[Person].deleteRecord).toHaveBeenCalledWith(@model)  

  describe "findPaged", ->
    beforeEach ->
      @pagedCollection = Emu.PagedModelCollection.create(type: Person)
      spyOn(Emu.PagedModelCollection, "create").andReturn(@pagedCollection)
      @store = Emu.Store.create   
        adapter: Adapter
      spyOn(@pagedCollection, "loadMore")
      @result = @store.findPaged(App.Address, 500)    

    it "should create a paged model collection", ->
      expect(Emu.PagedModelCollection.create).toHaveBeenCalledWith(type: App.Address, pageSize: 500, store: @store)

    it "should load the first page of the collection", ->
      expect(@pagedCollection.loadMore).toHaveBeenCalled()

    it "should return the result", ->
      expect(@result).toBe(@pagedCollection)

  describe "loadPaged", ->

    describe "page not loaded", ->
      beforeEach ->
        @pagedCollection = Emu.PagedModelCollection.create(pageSize: 100, type: App.Address)
        @collectionForPage = Emu.ModelCollection.create()
        spyOn(Emu.ModelCollection, "create").andReturn(@collectionForPage)
        @store = Emu.Store.create   
          adapter: Adapter
        spyOn(adapter, "findPage")
        @collectionForPage.on "didStartLoading", => @didStartLoading = true
        @store.loadPaged(@pagedCollection, 1, 100)

      it "should have created a collection for the fist page", ->
        expect(Emu.ModelCollection.create).toHaveBeenCalledWith(type: App.Address)
      
      it "should have populated the first page with 10 items", ->
        expect(@collectionForPage.get("length")).toEqual(100)

      it "should have populated with empty objects of the array's type", ->
        expect(@collectionForPage.every (x) => x.constructor == App.Address).toBeTruthy()

      it "should call didStartLoading on the collection for the page", ->
        expect(@didStartLoading).toBeTruthy()

      it "should call findPage on the adapter", ->
        expect(adapter.findPage).toHaveBeenCalledWith(@pagedCollection, @store, 1)

    describe "page loading", ->
      beforeEach ->
        @pagedCollection = Emu.PagedModelCollection.create(pageSize: 10)
        @pagedCollection.get("pages")[1] = Emu.ModelCollection.create(isLoading: true)
        @store = Emu.Store.create   
          adapter: Adapter
        spyOn(adapter, "findPage")        
        @pagedCollection.get("pages")[1].on "didStartLoading", => @didStartLoading = true
        @store.loadPaged(@pagedCollection, 1)

      it "should not call didStartLoading on the collection for the page", ->
        expect(@didStartLoading).toBeFalsy()

      it "should not have called findPage on the adapter", ->
        expect(adapter.findPage).not.toHaveBeenCalled()

    describe "page loaded", ->
      beforeEach ->
        @pagedCollection = Emu.PagedModelCollection.create(pageSize: 10)
        @pagedCollection.get("pages")[1] = Emu.ModelCollection.create(isLoaded: true)
        @store = Emu.Store.create   
          adapter: Adapter
        spyOn(adapter, "findPage")        
        @pagedCollection.get("pages")[1].on "didStartLoading", => @didStartLoading = true
        @store.loadPaged(@pagedCollection, 1)

      it "should not call didStartLoading on the collection for the page", ->
        expect(@didStartLoading).toBeFalsy()

      it "should not have called findPage on the adapter", ->
        expect(adapter.findPage).not.toHaveBeenCalled()

  describe "didFindPage", ->
    beforeEach ->
      @pagedCollection = Emu.PagedModelCollection.create(pageSize: 10)
      @pagedCollection.get("pages")[1] = Emu.ModelCollection.create(isLoaded: true)
      @store = Emu.Store.create   
        adapter: Adapter
      @pagedCollection.get("pages")[1].on "didFinishLoading", => @didFinishLoading = true
      @store.didFindPage(@pagedCollection, 1)

    it "should fire the finished event for the loaded page", ->
      expect(@didFinishLoading).toBeTruthy()
