describe "Creating a model", ->
	beforeEach ->
		TestSetup.setup()	
		spyOn($, "ajax")
		@model = App.Customer.create()
	it "should have made no ajax called", ->
		expect($.ajax).not.toHaveBeenCalled()