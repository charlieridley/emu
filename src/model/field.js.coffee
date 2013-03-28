Emu.Field = Ember.Object.extend
	lazy: ->
		@set("isLazy", true)
		this
Emu.field = (type)->
	Emu.Field.create(type: type or "string")