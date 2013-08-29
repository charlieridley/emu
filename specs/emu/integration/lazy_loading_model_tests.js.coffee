describe "Lazy loading model", ->

  describe "model not loaded", ->
    beforeEach ->
      TestSetup.setup()
      spyOn($, "ajax")
      @student = App.Student.find(15)
      $.ajax.mostRecentCall.args[0].success
        name: "Harry"
      @student.get("teacher")

    it "should have made ajax 2 requests", ->
      expect($.ajax.calls.length).toEqual(2)

    it "should make an request to the the orders for that customer", ->
      expect($.ajax.mostRecentCall.args[0].url).toEqual("api/students/15/teacher")