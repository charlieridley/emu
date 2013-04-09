window.SignalrTestSetup = 
  setup: -> 
    Emu.updatableModels = undefined
    $.connection = 
      updatablePersonHub: {}
      start: ->
    Ember.set(Emu, "defaultStore", undefined);  
    App.Store.create
      pushAdapter: Emu.SignalrPushDataAdapter.extend
        updatableTypes: ["App.UpdatablePerson"]