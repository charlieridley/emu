describe "Emu.ModelEvented", ->
  Person = Ember.Object.extend Emu.ModelEvented, Ember.Evented
  
  describe "didFinishLoading", ->
    beforeEach ->
      @model = Person.create()
      @model.on "didFinishLoading", => 
        @didFinishLoading = true
      @model.didFinishLoading()

    it "should have called didFinishLoading event", ->
      expect(@didFinishLoading).toBeTruthy()

  describe "didStartLoading", ->
    beforeEach ->
      @model = Person.create()
      @model.on "didStartLoading", => 
        @didStartLoading = true
      @model.didStartLoading()

    it "should have called didStartLoading event", ->
      expect(@didStartLoading).toBeTruthy()

  describe "didStartSaving", ->
    beforeEach ->
      @model = Person.create()
      @model.on "didStartSaving", => 
        @didStartSaving = true
      @model.didStartSaving()

    it "should have called didStartSaving event", ->
      expect(@didStartSaving).toBeTruthy()

  describe "didFinishSaving", ->
    beforeEach ->
      @model = Person.create()
      @model.on "didFinishSaving", => 
        @didFinishSaving = true
      @model.didFinishSaving()

    it "should have called didFinishSaving event", ->
      expect(@didFinishSaving).toBeTruthy()

  describe "didStateChange", ->
    beforeEach ->
      @model = Person.create()
      @model.on "didStateChange", => 
        @didStateChange = true
      @model.didStateChange()

    it "should have called didStateChange event", ->
      expect(@didStateChange).toBeTruthy()
