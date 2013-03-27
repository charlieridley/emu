describe "Emu.Serializer", ->	
	Person = Emu.Model.extend
		_fields:
			name: Emu.field()
	describe "When serializing a type name", ->
		beforeEach ->
			App.PersonOrder = Emu.Model.extend()		
			@serializer = Emu.Serializer.create()
			@result = @serializer.serializeTypeName(App.PersonOrder)
		it "should serialize the name to lower case", ->
			expect(@result).toEqual("personorder")
	describe "When deserializing a json object to a model", ->
		beforeEach ->	
			spyOn(Emu.AttributeSerializers.string, "deserialize").andReturn("WINSTON CHURCHILL")			
			@jsonData = 
				name: "Winston Churchill"
				age: "60"
			@serializer = Emu.Serializer.create()
			@model = Person.create()
			@serializer.deserializeModel(@model, @jsonData)
		it "should get the deserialized value from the attribute serializer for type string", ->
			expect(Emu.AttributeSerializers.string.deserialize).toHaveBeenCalledWith("Winston Churchill")
		it "should set the deserialized value on the name field", ->
			expect(@model.get("name")).toEqual("WINSTON CHURCHILL")
		it "should not deserialize the field which isn't defined in the model", ->
			expect(@model.get("age")).toBeUndefined()
	describe "When deserializing a collection", ->
		beforeEach ->
			jsonData = [
				{name: "Donald Duck"}
				{name: "Micky Mouse"}
			]
			@modelCollection = Emu.ModelCollection.create(type: Person)
			@serializer = Emu.Serializer.create()
			spyOn(@serializer, "deserializeModel").andCallThrough()
			spyOn(@modelCollection, "createRecord").andCallThrough()
			@serializer.deserializeCollection(@modelCollection, jsonData)
		it "should populate the model collection with 2 items", ->
			expect(@modelCollection.get("length")).toEqual(2)
		it "should create 2 models", ->
			expect(@modelCollection.createRecord.calls.length).toEqual(2)
		it "should deserialize 2 items", ->
			expect(@serializer.deserializeModel.calls.length).toEqual(2)
	describe "When deserializing a json object with a nested collection", ->
		Order = Emu.Model.extend()
		Customer = Emu.Model.extend
			_fields:
				name: Emu.field(Order)
				orders: Emu.collection(Order)
		beforeEach ->			
			@jsonData = 
				name: "Donald Duck"
				orders: [
					{id: 1}
					{id: 2}
				]			
			@store = Ember.Object.create()
			@serializer = Emu.Serializer.create()
			spyOn(@serializer, "deserializeCollection")	
			@modelCollection = Emu.ModelCollection.create()
			spyOn(Emu.ModelCollection, "create").andReturn(@modelCollection)
			@model = Customer.create()
			@model._store = @store
			@serializer.deserializeModel(@model, @jsonData)
		it "should create a new model collection for that type", ->
			expect(Emu.ModelCollection.create).toHaveBeenCalledWith(type: Order, store: @store, parent: @model)
		it "should call deserializeCollection", ->
			expect(@serializer.deserializeCollection).toHaveBeenCalledWith(@modelCollection,@jsonData.orders)
		it "should set the result on the model", ->
			expect(@model.get("orders")).toBe(@modelCollection)
	describe "When deserializing a json object with a nested collection, when the value of the nested collection is null", ->
		Order = Emu.Model.extend()
		Customer = Emu.Model.extend
			_fields:
				name: Emu.field(Order)
				orders: Emu.collection(Order)
		beforeEach ->			
			@jsonData = 
				name: "Donald Duck"			
			@store = Ember.Object.create()
			@serializer = Emu.Serializer.create()
			spyOn(@serializer, "deserializeCollection")				
			spyOn(Emu.ModelCollection, "create")
			@model = Customer.create()
			@model._store = @store
			@serializer.deserializeModel(@model, @jsonData)
		it "should not create a new model collection for that type", ->
			expect(Emu.ModelCollection.create).not.toHaveBeenCalled()
		it "should not call deserializeCollection", ->
			expect(@serializer.deserializeCollection).not.toHaveBeenCalled()
	describe "When serializing a simple model", ->
		Customer = Emu.Model.extend
			_fields:
				name: Emu.field()
				age: Emu.field()
		beforeEach ->
			customer = Customer.create
				name: "Terry the customer"
				age: "47"
			@serializer = Emu.Serializer.create()
			@jsonResult = @serializer.serializeModel(customer)
		it "should deserialize the object to json", ->
			expect(@jsonResult).toEqual
				name: "Terry the customer"
				age: "47"
	describe "When serializing a model with a nested collection", ->
		Order = Emu.Model.extend
			_fields:
				orderCode: Emu.field()
		Customer = Emu.Model.extend
			_fields:
				name: Emu.field(Order)
				orders: Emu.collection(Order)		
		beforeEach ->
			@customer = Customer.create
				name: "Terry the customer"
				orders: Emu.ModelCollection.create(type: Order)
			@customer.get("orders").pushObject(Order.create(orderCode: "123"))
			@customer.get("orders").pushObject(Order.create(orderCode: "456"))
			spyOn(@customer, "get").andCallThrough()
			@serializer = Emu.Serializer.create()
			@jsonResult = @serializer.serializeModel(@customer)
		it "should deserialize the object to json", ->
			expect(@jsonResult).toEqual
				name: "Terry the customer"
				orders: [
					{orderCode: "123"}
					{orderCode: "456"}
				]	
		it "should have called the get for the property with the doNotLoad argument, to stop it lazy loading", ->
			expect(@customer.get).toHaveBeenCalledWith("orders", {doNotLoad: true})
