describe "Emu.Model", ->	
	Person = Emu.Model.extend()	
	Order = Emu.Model.extend()
	describe "When creating", ->
		beforeEach ->					
			@model = Person.create()
		it "should not be fully loaded", ->
			expect(@model.get("isFullyLoaded")).toBeFalsy()
	describe "When getting a normal field", ->
		beforeEach ->
			Person = Emu.Model.extend
				_fields:
					name: Emu.field()
			@model = Person.create(name: "henry")
			@result = @model.get("name")
		it "should get the value", ->
			expect(@result).toEqual("henry")
	describe "When getting the value for that collection", ->
		beforeEach ->
			@orders = Emu.ModelCollection.create()
			Person = Emu.Model.extend
				_fields:
					name: Emu.collection()			
			@model = Person.create(orders: @orders)
			@result = @model.get("orders")
		it "should return the collection", ->
			expect(@result).toBe(@orders)
	describe "When getting the value of a collection which is not set", ->
		beforeEach ->
			@store = Ember.Object.create
				findAll: ->
			spyOn(@store, "findAll")
			@orders = Emu.ModelCollection.create(type: Order)
			spyOn(Emu.ModelCollection, "create").andReturn(@orders)
			Person = Emu.Model.extend
				_store: @store
				_fields:
					orders: Emu.collection(Order)									
			@model = Person.create()
			@result = @model.get("orders")
		it "should get all the models for the collection from the store", ->
			expect(@result).toBeUndefined()
		it "should not query the store", ->
			expect(@store.findAll).not.toHaveBeenCalled()
	describe "When getting the value of a lazy collection which is not set", ->
		beforeEach ->
			@store = Ember.Object.create
				findAll: ->
			@orders = Emu.ModelCollection.create(type: Order)
			spyOn(@store, "findAll")
			spyOn(Emu.ModelCollection, "create").andReturn(@orders)
			Person = Emu.Model.extend
				_store: @store
				_fields:
					orders: Emu.collection(Order).lazy()								
			@model = Person.create()
			@result = @model.get("orders")
		it "should create a new collection", ->
			expect(Emu.ModelCollection.create).toHaveBeenCalledWith(type: Order, store: @store, parent: @model)
		it "should get all the models for the collection from the store", ->
			expect(@store.findAll).toHaveBeenCalledWith(Order, {fullyLoad: true, collection: @orders})
		it "should return the collection", ->
			expect(@result).toBe(@orders)
	describe "When getting the value of a lazy collection again after it has been loaded", ->
		beforeEach ->
			@store = Ember.Object.create
				findAll: ->
			@orders = Emu.ModelCollection.create(type: Order)
			spyOn(@store, "findAll")
			spyOn(Emu.ModelCollection, "create").andReturn(@orders)
			Person = Emu.Model.extend
				_store: @store
				_fields:
					orders: Emu.collection(Order).lazy()								
			@model = Person.create()
			@model.get("orders")
			@model.get("orders")
		it "should get the models from the store only once", ->
			expect(@store.findAll.calls.length).toEqual(1)
			@result = @model.get("orders")
	describe "When getting the value of a lazy collection which is not set, but setting doNotLoad=true", ->
		beforeEach ->
			@store = Ember.Object.create
				findAll: ->		
			Person = Emu.Model.extend
				_store: @store
				_fields:
					orders: Emu.collection(Order).lazy()		
			spyOn(@store, "findAll")
			spyOn(Emu.ModelCollection, "create")							
			@model = Person.create()
			@result = @model.get("orders", {doNotLoad: true})
		it "should not create a new collection", ->
			expect(Emu.ModelCollection.create).not.toHaveBeenCalled()
		it "should not query the store", ->
			expect(@store.findAll).not.toHaveBeenCalled()
		it "should return undefined", ->
			expect(@result).toBeUndefined()
