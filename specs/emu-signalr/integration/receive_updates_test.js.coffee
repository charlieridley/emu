describe "Receving an update", ->
  describe "simple field", ->
    beforeEach ->
      SignalrTestSetup.setup()
      spyOn($, "ajax")
      @person = App.UpdatablePerson.find(5)
      $.ajax.mostRecentCall.args[0].success(id:5, name:"Bond James Bond")
      $.connection.personHub.updated({id: 5, name: "Bond.....James Bond"})
    #it "should have updated the model", ->
      #expect(@person.get("name")).toEqual("Bond.....James Bond")