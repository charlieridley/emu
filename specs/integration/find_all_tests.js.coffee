describe "Find all tests", ->
	describe "When finding all", ->	
		beforeEach ->
			store = TestHelpers.createStore()
			spyOn($, "ajax")
			store.findAll(App.Person)
		it "should make a web request to get all the models", ->
			expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person")
	describe "When finding all completes", ->
		beforeEach ->
			store = TestHelpers.createStore()
			spyOn($, "ajax")
			@result = store.findAll(App.Person)
			$.ajax.mostRecentCall.args[0].success [				
				{name: "Harry"}
			]
		it "should have populated the model with the json data", ->
			expect(@result.get("firstObject.name")).toEqual("Harry")
