describe "Find all tests", ->
  
  describe "When finding all", -> 
    beforeEach ->   
      TestSetup.setup() 
      spyOn($, "ajax")
      App.Person.find()
    
    it "should make a web request to get all the models", ->
      expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person")
  
  describe "When finding all completes", ->
    beforeEach ->
      TestSetup.setup() 
      spyOn($, "ajax")
      @result = App.Person.find()
      $.ajax.mostRecentCall.args[0].success [       
        {id: 1, name: "Harry"}
      ]
    
    it "should have populated the model with the json data", ->
      expect(@result.get("firstObject.name")).toEqual("Harry")
