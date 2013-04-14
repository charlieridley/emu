describe "Custom primary key", ->
  
  describe "find by id", ->
    beforeEach ->
      TestSetup.setup() 
      spyOn($, "ajax")
      App.CustomPerson.find(5)
    
    it "should have made 1 ajax request", ->
      expect($.ajax.calls.length).toEqual(1)
    
    it "should make a request to the person URL with the correct ID", ->
      expect($.ajax.mostRecentCall.args[0].url).toEqual("api/customPerson/5") 

  describe "request completes", ->
    beforeEach ->
      TestSetup.setup() 
      spyOn($, "ajax").andCallFake (params) ->
        params.success {name: "Harry"}
      @result = App.CustomPerson.find(5)
    
    it "should deserialize the primary key", ->
      expect(@result.get("personId")).toEqual(5)