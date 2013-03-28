Emu.Model = Ember.Object.extend
	getValueOf: (key) ->
		@_attributes?[key]