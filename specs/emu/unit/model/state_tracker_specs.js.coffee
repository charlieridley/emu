describe "Emu.StateTracker", ->

  describe "responding to model events", ->

    describe "didStartLoading", ->
      beforeEach ->
        stateTracker = Emu.StateTracker.create()
        @model = App.Person.create()
        stateTracker.track(@model)
        @model.didStartLoading()

      it "has isLoading true", ->
        expect(@model.get("isLoading")).toBeTruthy()

      it "has isLoaded false", ->
        expect(@model.get("isLoaded")).toBeFalsy()

    describe "didFinishLoading", ->
      beforeEach ->
        stateTracker = Emu.StateTracker.create()
        @model = App.Person.create()
        stateTracker.track(@model)
        @model.didStartLoading()
        @model.didFinishLoading()

      it "has isLoading false", ->
        expect(@model.get("isLoading")).toBeFalsy()

      it "has isLoaded true", ->
        expect(@model.get("isLoaded")).toBeTruthy()

      it "has isDirty false", ->
        expect(@model.get("isDirty")).toBeFalsy()

      it "has isSaved true", ->
        expect(@model.get("isSaved")).toBeTruthy()

    describe "didStartSaving", ->
      beforeEach ->
        stateTracker = Emu.StateTracker.create()
        @model = App.Person.create()
        stateTracker.track(@model)
        @model.didStartSaving()

      it "has isSaving true", ->
        expect(@model.get("isSaving")).toBeTruthy()

    describe "didFinishSaving", ->
      beforeEach ->
        stateTracker = Emu.StateTracker.create()
        @model = App.Person.create()
        stateTracker.track(@model)
        @model.didStartSaving()
        @model.didFinishSaving()

      it "has isSaving false", ->
        expect(@model.get("isSaving")).toBeFalsy()

      it "has isSaved true", ->
        expect(@model.get("isSaved")).toBeTruthy()

      it "has isLoaded true", ->
        expect(@model.get("isLoaded")).toBeTruthy()

      it "has isDirty false", ->
        expect(@model.get("isDirty")).toBeFalsy()

    describe "didStateChange", ->
      beforeEach ->
        stateTracker = Emu.StateTracker.create()
        @model = App.Person.create(isDirty: false)
        stateTracker.track(@model)
        @model.didStateChange()

      it "has isDirty false", ->
        expect(@model.get("isDirty")).toBeTruthy()

    describe "didError", ->
      beforeEach ->
        stateTracker = Emu.StateTracker.create()
        @model = App.Person.create(isDirty: false, isSaved: true)
        stateTracker.track(@model)
        @model.didError()

      it "has isLoaded false", ->
        expect(@model.get("isLoaded")).toBeFalsy()

      it "has isSaving false", ->
        expect(@model.get("isSaving")).toBeFalsy()

      it "has isLoading false", ->
        expect(@model.get("isLoading")).toBeFalsy()

      it "has isDirty true", ->
        expect(@model.get("isDirty")).toBeTruthy()

      it "has isError true", ->
        expect(@model.get("isError")).toBeTruthy()


