describe "Partial loading property tests", ->
	describe "When getting a partial property when the parent object isn't fully loaded", ->
		beforeEach ->
			store = TestHelpers.createStore()
			spyOn($, "ajax")
			@model = store.findById(App.Customer, 43)
			$.ajax.mostRecentCall.args[0].success
				name: "Harry"
			@model.get("town")
		it "should make an ajax request to load the parent model", ->
			expect($.ajax.mostRecentCall.args[0].url).toEqual("api/customer/43")