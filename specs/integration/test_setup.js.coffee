 window.TestSetup = 
  setup: -> 
    Ember.set(Emu, "defaultStore", undefined);  
    App.Store.create()