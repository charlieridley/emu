describe "Receving an update", ->
  
  describe "simple field", ->
    beforeEach ->      
      SignalrTestSetup.setup()
      spyOn($, "ajax")
      @person = App.UpdatablePerson.find(5)
      @person.subscribeToUpdates()
      $.ajax.mostRecentCall.args[0].success(id:5, name:"Bond James Bond")
      $.connection.updatablePersonHub.client.updated({id: 5, name: "Bond.....James Bond"})
    it "should have updated the model", ->
      expect(@person.get("name")).toEqual("Bond.....James Bond")