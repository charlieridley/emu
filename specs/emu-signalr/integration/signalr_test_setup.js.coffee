window.SignalrTestSetup = 
  setup: -> 
    $.connection = {}
    Ember.set(Emu, "defaultStore", undefined);  
    App.Store.create(pushAdapter: Emu.SignalrPushDataAdapter)    