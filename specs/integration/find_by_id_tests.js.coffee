describe "Find by ID tests", ->	
	describe "When finding by ID", ->
		beforeEach ->
			store = TestHelpers.createStore()
			spyOn($, "ajax")
			store.findById(App.Person, 5)
		it "should make a request to the person URL with the correct ID", ->
			expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person/5")
	describe "When finding by ID completes", ->
		beforeEach ->
			store = TestHelpers.createStore()
			spyOn($, "ajax")
			@result = store.findById(App.Person, 5)
			$.ajax.mostRecentCall.args[0].success
				name: "Harry"
		it "should make a request to the person URL with the correct ID", ->
			expect(@result.get("name")).toEqual("Harry")