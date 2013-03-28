Emu.Field = Ember.Object.extend()
Emu.field = (type)->
	Emu.Field.create(type: type or "string")