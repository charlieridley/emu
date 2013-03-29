describe "Emu.field", ->	
	Person = Emu.Model.extend()	
	Order = Emu.Model.extend()
	describe "When creating as string", ->
		beforeEach ->
			@Person = Emu.Model.extend
				name: Emu.field("string")			
		it "should have a type of 'string'", ->
			expect(@Person.metaForProperty("name").type).toEqual("string")
	describe "When creating as 'number'", ->
		beforeEach ->
			@Person = Emu.Model.extend
				age: Emu.field("number")
		it "should have a type of 'number'", ->
			expect(@Person.metaForProperty("age").type).toEqual("number")
	describe "When creating and marking with options", ->
		beforeEach ->
			@Person = Emu.Model.extend
				name: Emu.field("string", {lazy: true, partial: false})	
		it "should mark the field as lazy", ->
			expect(@Person.metaForProperty("name").options).toEqual({lazy: true, partial: false})	
	describe "When getting a normal field", ->
		beforeEach ->
			Person = Emu.Model.extend
				name: Emu.field("string")
			@model = Person.create(name: "henry")
			@result = @model.get("name")
		it "should get the value", ->
			expect(@result).toEqual("henry")
	describe "When getting the value for a collection", ->
		beforeEach ->
			@orders = Emu.ModelCollection.create(type: Order)			
			Person = Emu.Model.extend
				name: Emu.field(Order, {collection: true})			
			@model = Person.create(orders: @orders)
			@result = @model.get("orders")
		it "should return the collection", ->
			expect(@result).toBe(@orders)
	describe "When getting the value of a collection which is not set", ->
		beforeEach ->
			@store = Ember.Object.create
				loadAll: ->
			spyOn(@store, "loadAll")
			@orders = Emu.ModelCollection.create(type: Order)
			spyOn(Emu.ModelCollection, "create").andReturn(@orders)
			Person = Emu.Model.extend
				store: @store
				orders: Emu.field(Order, {collection: true})
			@model = Person.create()
			@result = @model.get("orders")
		it "should return an empty collection", ->
			expect(@result.get("length")).toEqual(0)
		it "should not query the store", ->
			expect(@store.loadAll).not.toHaveBeenCalled()
	describe "When getting the value of a lazy collection which is not set", ->
		beforeEach ->
			@store = Ember.Object.create
				loadAll: ->
			@orders = Emu.ModelCollection.create(type: Order)
			spyOn(@store, "loadAll")
			spyOn(Emu.ModelCollection, "create").andReturn(@orders)
			Person = Emu.Model.extend
				store: @store
				orders: Emu.field(Order, {collection: true, lazy: true})
			@model = Person.create()
			@result = @model.get("orders")		
		it "should get all the models for the collection from the store", ->
			expect(@store.loadAll).toHaveBeenCalledWith(@orders)
		it "should return the collection", ->
			expect(@result).toBe(@orders)
	describe "When getting the value of a lazy collection again after it has been loaded", ->
		beforeEach ->
			@store = Ember.Object.create
				loadAll: ->
			@orders = Emu.ModelCollection.create(type: Order)
			spyOn(@store, "loadAll")
			spyOn(Emu.ModelCollection, "create").andReturn(@orders)
			Person = Emu.Model.extend
				store: @store
				orders: Emu.field(Order, {collection: true, lazy: true})
			@model = Person.create()
			@model.get("orders")
			@model.get("orders")
		it "should get the models from the store only once", ->
			expect(@store.loadAll.calls.length).toEqual(1)
			@result = @model.get("orders")

	describe "When getting the value of a partial property", ->
		beforeEach ->
			@store = Ember.Object.create
				loadModel: ->		
			Person = Emu.Model.extend
				name: Emu.field("string", {partial: true})
			@person = Person.create(id: 5, store: @store)			
			spyOn(@store, "loadModel")
			@person.get("name")
		it "should load the parent object", ->
			expect(@store.loadModel).toHaveBeenCalledWith(@person)


