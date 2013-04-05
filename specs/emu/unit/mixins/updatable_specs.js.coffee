describe "Emu.Updatable", ->
  describe "init", ->
    beforeEach ->
      @store =
        registerUpdatable: jasmine.createSpy()
      Foo = Emu.Model.extend(Emu.Updatable, store: @store)
      @model = Foo.create()
    it "should register the model as updatable on the store", ->
      expect(@store.registerUpdatable).toHaveBeenCalledWith(@model)