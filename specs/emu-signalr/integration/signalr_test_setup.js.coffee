window.SignalrTestSetup = 
  setup: -> 
    Emu.updatableModels = undefined
    $.connection = 
      updatablePersonHub: {}
    Ember.set(Emu, "defaultStore", undefined);  
    App.Store.create(pushAdapter: Emu.SignalrPushDataAdapter)    