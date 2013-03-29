describe "Emu.ModelCollection", ->
	Person = Emu.Model.extend()	
	describe "When creating a new record in the collection", ->
		beforeEach ->		
			@modelCollection = Emu.ModelCollection.create
				type: Person
			@model = Person.create()
			spyOn(Person, "create").andReturn(@model)
			@result = @modelCollection.createRecord(id: 1)
		it "should create and return the model", ->
			expect(@result).toBe(@model)
		it "should add the item to the collection", ->
			expect(@modelCollection.get("length")).toEqual(1)
			expect(@modelCollection.get("firstObject")).toBe(@model)
		it "should set the properties on the new object", ->
			expect(Person.create).toHaveBeenCalledWith(id: 1)