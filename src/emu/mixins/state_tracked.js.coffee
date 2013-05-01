Emu.StateTracked = Ember.Mixin.create
  init: ->
    Emu.StateTracker.create().track(this)