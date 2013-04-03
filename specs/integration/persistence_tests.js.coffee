describe "Saving a new model", ->
	describe "with Emu.Serializer", ->
		beforeEach ->
			TestSetup.setup() 
			spyOn($, "ajax")
			@person = App.Person.createRecord()
			@person.save()
		it "should save to the correct URL", ->
			expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person")
		it "should send a POST request", ->
			expect($.ajax.mostRecentCall.args[0].type).toEqual("POST")	

describe "Saving a existing model", ->
	beforeEach ->
		TestSetup.setup() 
		spyOn($, "ajax")
		@person = App.Person.find(5)
		$.ajax.mostRecentCall.args[0].success({id: 5, name: "Larry"})
		@person.save()
	it "should save to the correct URL", ->
		expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person")
	it "should send a PUT request", ->
		expect($.ajax.mostRecentCall.args[0].type).toEqual("PUT")