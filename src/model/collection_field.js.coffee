Emu.CollectionField = Ember.Object.extend
	lazy: ->
		@set("isLazy", true)
		this
Emu.collection = (modelType) ->
	Emu.CollectionField.create(modelType: modelType, type: "array")