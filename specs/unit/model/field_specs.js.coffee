describe "Emu.Field", ->
	describe "When creating", ->
		beforeEach ->
			@field = Emu.field()
		it "should have a default type of 'string'", ->
			expect(@field.get("type")).toEqual("string")