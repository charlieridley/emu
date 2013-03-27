describe "Emu.CollectionField", ->
	Person = Emu.Model.extend()
	describe "When creating", ->
		beforeEach ->
			@field = Emu.collection(Person)
		it "should have the specified model type", ->
			expect(@field.get("modelType")).toBe(Person)
		it "should have a type of array", ->
			expect(@field.get("type")).toBe("array")
	describe "When creating and marking lazy", ->
		beforeEach ->
			@field = Emu.collection(Person).lazy()
		it "should mark the field as lazy", ->
			expect(@field.get("isLazy")).toBeTruthy()
