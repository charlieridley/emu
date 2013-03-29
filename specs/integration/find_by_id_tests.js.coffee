describe "Find by ID tests", ->	
	describe "When finding by ID", ->
		beforeEach ->
			TestSetup.setup()	
			spyOn($, "ajax")
			App.Person.find(5)
		it "should have made 1 ajax request", ->
			expect($.ajax.calls.length).toEqual(1)
		it "should make a request to the person URL with the correct ID", ->
			expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person/5")		
	describe "When finding by ID completes", ->
		beforeEach ->
			TestSetup.setup()	
			spyOn($, "ajax")
			@result = App.Person.find(5)
			$.ajax.mostRecentCall.args[0].success
				name: "Harry"
		it "should deserialize the simple field", ->
			expect(@result.get("name")).toEqual("Harry")
	describe "When finding by ID on a model with a lazy property", ->
		beforeEach ->
			TestSetup.setup()	
			spyOn($, "ajax")
			App.Customer.find(5)
		it "should have made 1 ajax request", ->
			expect($.ajax.calls.length).toEqual(1)