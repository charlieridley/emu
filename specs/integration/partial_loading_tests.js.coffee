describe "Partial loading property tests", ->
	describe "When getting a partial property when the parent object isn't fully loaded", ->
		beforeEach ->
			store = TestHelpers.createStore()
			spyOn($, "ajax")
			@models = store.findAll(App.Customer)
			$.ajax.mostRecentCall.args[0].success [
				id: "43"
				name: "Harry"
			]
			@models.get("firstObject").get("town")
		it "should make an ajax request to load the parent model", ->
			expect($.ajax.mostRecentCall.args[0].url).toEqual("api/customer/43")
	describe "When getting a partial property when the parent object is fully loaded", ->
		beforeEach ->
			store = TestHelpers.createStore()
			spyOn($, "ajax")
			@model = store.findById(App.Customer, 43)
			$.ajax.mostRecentCall.args[0].success
				name: "Harry"
			@model.get("town")
		it "should not make an ajax request to load the parent model", ->
			expect($.ajax.calls.length).toEqual(1)