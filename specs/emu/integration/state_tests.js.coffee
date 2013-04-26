describe "Changing state", ->

  describe "New model", ->
    beforeEach ->
      TestSetup.setup() 
      @model = App.Person.create()

    it "should have isLoaded false", ->
      expect(@model.get("isLoaded")).toBeFalsy()

    it "should have isLoading false", ->
      expect(@model.get("isLoading")).toBeFalsy()

    it "should have isDirty true", ->
      expect(@model.get("isDirty")).toBeTruthy()

  describe "loading model", ->
    beforeEach ->
      TestSetup.setup() 
      spyOn($, "ajax")
      @model = App.Person.find(5)

    it "should have isLoaded false", ->
      expect(@model.get("isLoaded")).toBeFalsy()

    it "should have isLoading true", ->
      expect(@model.get("isLoading")).toBeTruthy()

    it "should have isDirty true", ->
      expect(@model.get("isDirty")).toBeTruthy()

  describe "loaded model", ->
    beforeEach ->
      TestSetup.setup() 
      spyOn($, "ajax")
      @model = App.Person.find(5)
      $.ajax.mostRecentCall.args[0].success
        name: "Floyd the Barber"
        address: 
          town: "Seattle"

    it "should have isLoaded true", ->
      expect(@model.get("isLoaded")).toBeTruthy()

    it "should have isLoading false", ->
      expect(@model.get("isLoading")).toBeFalsy()

    it "should have isDirty false", ->
      expect(@model.get("isDirty")).toBeFalsy()

  describe "saving model", ->
    beforeEach ->
      TestSetup.setup() 
      spyOn($, "ajax")
      @model = App.Person.create()
      @model.save()      

    it "should have isLoaded false", ->
      expect(@model.get("isLoaded")).toBeFalsy()

    it "should have isLoading false", ->
      expect(@model.get("isLoading")).toBeFalsy()

    it "should have isSaving true", ->
      expect(@model.get("isSaving")).toBeTruthy()

    it "should have isDirty true", ->
      expect(@model.get("isDirty")).toBeTruthy()

  describe "saved model", ->
    beforeEach ->
      TestSetup.setup() 
      spyOn($, "ajax")
      @model = App.Person.create()
      @model.save()    
      $.ajax.mostRecentCall.args[0].success
        name: "Floyd the Barber"
        address: 
          town: "Seattle"

    it "should have isLoaded true", ->
      expect(@model.get("isLoaded")).toBeTruthy()

    it "should have isLoading false", ->
      expect(@model.get("isLoading")).toBeFalsy()

    it "should have isSaving false", ->
      expect(@model.get("isSaving")).toBeFalsy()

    it "should have isDirty false", ->
      expect(@model.get("isDirty")).toBeFalsy()