Emu.ModelCollection = Ember.ArrayProxy.extend
	init: ->
		@set("content", Ember.A([]))
	createRecord: (hash) ->
		model = @get("type").create(hash)
		model._store = @get("store")
		@pushObject(model)		