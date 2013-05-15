describe "Partial loading property tests", ->

  describe "When getting a partial property when the parent object isn't fully loaded", ->
    beforeEach ->
      TestSetup.setup()
      spyOn($, "ajax")
      @models = App.Customer.find()
      $.ajax.mostRecentCall.args[0].success [
        id: "43"
        name: "Harry"
      ]
      Ember.run =>
        @models.get("firstObject.town")

    it "should make an ajax request to load the parent model", ->
      expect($.ajax.mostRecentCall.args[0].url).toEqual("api/customers/43")

  describe "When getting a partial property when the parent object is fully loaded", ->
    beforeEach ->
      TestSetup.setup()
      spyOn($, "ajax")
      @model = App.Customer.find(43)
      $.ajax.mostRecentCall.args[0].success
        name: "Harry"
      @model.get("town")

    it "should not make an ajax request to load the parent model", ->
      expect($.ajax.calls.length).toEqual(1)