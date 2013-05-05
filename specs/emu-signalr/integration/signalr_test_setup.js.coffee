window.SignalrTestSetup = 
  setup: -> 
    Emu.updatableModels = undefined
    $.connection = 
      updatablePersonsHub: 
        client: {}
      hub:
        start: jasmine.createSpy().andReturn
          done: -> this
          fail: -> this
    Ember.set(Emu, "defaultStore", undefined);  
    App.Store.create
      pushAdapter: Emu.SignalrPushDataAdapter.extend
        updatableTypes: ["App.UpdatablePerson"]
    App.reset()