window.TestSetup = 
  setup: -> 
    Ember.set(Emu, "defaultStore", undefined)
    App.Store = Emu.Store.extend
      adapter: Emu.RestAdapter.extend
        namespace: "api"
    App.reset()