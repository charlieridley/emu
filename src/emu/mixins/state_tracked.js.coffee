Emu.StateTracked = Ember.Mixin.create
  init: ->
    @_super()
    Emu.StateTracker.create().track(this)