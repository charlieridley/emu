describe "Emu.Store", ->		
	adapter = Ember.Object.create
		findAll: ->
		findById: ->
		insert: ->
		update: ->
	Adapter = 
		create: -> adapter
	Person = Emu.Model.extend()
	describe "When creating with no adapter specified", ->
		beforeEach ->
			spyOn(Emu.RestAdapter, "create")
			@store = Emu.Store.create()
		it "should create a RestAdapter by default", ->
			expect(Emu.RestAdapter.create).toHaveBeenCalled()
	describe "When finding all records", ->
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
		it "should set isLoading on the models to true"	, ->
			expect(@result.get("isLoading")).toBeTruthy()
		it "should return the model collection", ->
			expect(@result).toEqual(@models)
	describe "When the adapter finishes loading all records", ->
		beforeEach ->
			@models = Emu.ModelCollection.create(isLoading: true)			
			@store = Emu.Store.create
				adapter: Adapter
			@store.didFindAll(@models)			
		it "should set isLoading true on the model collection", ->
			expect(@models.get("isLoading")).toBeFalsy()
		it "should set isLoaded false on the model collection", ->
			expect(@models.get("isLoaded")).toBeTruthy()		
	describe "When finding all when a findAll query is executing", ->
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
	describe "When finding all when the model collection is loaded", ->
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
	describe "When finding by id", ->
		beforeEach ->
			@modelCollection = Emu.ModelCollection.create()
			spyOn(Emu.ModelCollection, "create").andReturn(@modelCollection)
			spyOn(@modelCollection, "createRecord").andReturn(@model)
			spyOn(adapter, "findById")
			@store = Emu.Store.create
				adapter: Adapter
			@result = @store.findById(Person, 5)
		it "should set the id on the model with the ID and loading and loaded state", ->
			expect(@modelCollection.createRecord).toHaveBeenCalledWith(id: 5, isLoading: true, isLoaded: false)
		it "should call the findById method on the adapter", ->
			expect(adapter.findById).toHaveBeenCalledWith(Person, @store, @model, 5)
		it "should return the model", ->
			expect(@result).toEqual(@model)
	describe "When the adapter finishes finding a record by ID", ->
		beforeEach ->
			@model = Person.create(isLoaded: false, isLoading: true)
			spyOn(Person, "create").andReturn(@model)
			@store = Emu.Store.create
				adapter: Adapter
			@store.didFindById(@model)
		it "should set isLoading to false", ->
			expect(@model.get("isLoading")).toBeFalsy()
		it "should set isLoaded to true", ->
			expect(@model.get("isLoaded")).toBeTruthy()
	describe "When finding by id with a query already pending", ->
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
	describe "When finding a record that has already loaded", ->
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
	describe "When creating a record", ->
		beforeEach ->
			@modelCollections = {}
			@modelCollections[Person] = Emu.ModelCollection.create()
			@store = Emu.Store.create		
				adapter: Adapter
				modelCollections: @modelCollections						
			@model = Person.create()
			spyOn(@modelCollections[Person], "createRecord").andReturn(@model)
			@result = @store.createRecord(Person)
		it "should return the created model", ->
			expect(@result).toEqual(@model)
		it "should should set the initial state of the model to be dirty", ->
			expect(@modelCollections[Person].createRecord).toHaveBeenCalledWith(isDirty: true)
	describe "When saving a new record", ->
		beforeEach ->
			@store = Emu.Store.create		
				adapter: Adapter
			spyOn(adapter, "insert")
			@model = @store.createRecord(Person)
			@store.save(@model)
		it "should call insert on the adapter", ->
			expect(adapter.insert).toHaveBeenCalledWith(@store, @model)
	describe "When saving an existing record (one with an id assigned)", ->
		beforeEach ->
			@store = Emu.Store.create		
				adapter: Adapter
			spyOn(adapter, "update")
			@model = @store.createRecord(Person)
			@model.set("id", 5)
			@store.save(@model)
		it "should call update on the adapter", ->
			expect(adapter.update).toHaveBeenCalledWith(@store, @model)
	describe "When loading all on an existing collection", ->
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
	describe "When loading an existing model", ->
		beforeEach ->
			@model = Person.create(id: 4)
			spyOn(adapter, "findById")
			@store = Emu.Store.create		
				adapter: Adapter
			@store.loadModel(@model)
		it "should call the findById method on the adapter", ->
			expect(adapter.findById).toHaveBeenCalledWith(Person, @store, @model, 4)



