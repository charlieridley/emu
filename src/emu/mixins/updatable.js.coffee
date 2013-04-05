Emu.Updatable = Ember.Mixin.create
	init: ->
    @get("store").registerUpdatable(this)