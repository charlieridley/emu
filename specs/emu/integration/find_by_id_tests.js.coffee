describe "Find by ID tests", ->

  describe "start request", ->
    beforeEach ->
      TestSetup.setup()
      spyOn($, "ajax")
      App.Person.find(5)

    it "should have made 1 ajax request", ->
      expect($.ajax.calls.length).toEqual(1)

    it "should make a request to the person URL with the correct ID", ->
      expect($.ajax.mostRecentCall.args[0].url).toEqual("api/people/5")

  describe "request completes", ->
    beforeEach ->
      TestSetup.setup()
      spyOn($, "ajax").andCallFake (params) ->
        params.success {name: "Harry"}
      @result = App.Person.find(5)

    it "should deserialize the simple field", ->
      expect(@result.get("name")).toEqual("Harry")

    it "should not be dirty", ->
      expect(@result.get("isDirty")).toBeFalsy()

  describe "request failes", ->
    beforeEach ->
      TestSetup.setup()
      spyOn($, "ajax").andCallFake (params) ->
        params.error()
      @result = App.Person.find(5)

    it "should be error", ->
      expect(@result.get('isError')).toBeTruthy()

    it "should not be loading", ->
      expect(@result.get('isLoading')).toBeFalsy()

  describe "has lazy property", ->
    beforeEach ->
      TestSetup.setup()
      spyOn($, "ajax")
      App.Customer.find(5)

    it "should have made 1 ajax request", ->
      expect($.ajax.calls.length).toEqual(1)