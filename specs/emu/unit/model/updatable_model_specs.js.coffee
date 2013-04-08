describe "Emu.UpdatableModel", ->
  Car = Emu.UpdatableModel.extend()   
  it "should have an updatable flag set to true", ->
    expect(Car.isUpdatableModel).toBeTruthy()