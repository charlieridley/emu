describe "Emu.Field", ->
	describe "When creating", ->
		beforeEach ->
			@field = Emu.field()
		it "should have a default type of 'string'", ->
			expect(@field.get("type")).toEqual("string")
	describe "When creating with custom type 'number'", ->
		beforeEach ->
			@field = Emu.field("number")
		it "should have a type of 'number'", ->
			expect(@field.get("type")).toEqual("number")
	describe "When creating and marking lazy", ->
		beforeEach ->
			@field = Emu.field().lazy()
		it "should mark the field as lazy", ->
			expect(@field.get("isLazy")).toBeTruthy()