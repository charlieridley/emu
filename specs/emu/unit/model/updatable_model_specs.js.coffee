describe "Emu.UpdatableModel", ->
  Car = Emu.UpdatableModel.extend()   
  it "should have an updatable flag set to true", ->
    expect(Car.isUpdatable).toBeTruthy()

  describe "init", ->
    beforeEach ->
      Emu.updatableTypes = undefined
      @store = {
        registerUpdatable: jasmine.createSpy()
      }

      @model = Car.create(store: @store)
    it "should register the model as updatable type", ->
      expect(Emu.updatableTypes[0]).toBe(Car)
    it "should register the instance as updatable", ->
      expect(@store.registerUpdatable).toHaveBeenCalledWith(@model)