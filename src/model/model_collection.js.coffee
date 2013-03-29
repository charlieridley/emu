Emu.ModelCollection = Ember.ArrayProxy.extend
	init: ->
		@set("content", Ember.A([]))
		@createRecord = (hash) ->
			model = @get("type").create(hash)			
			@pushObject(model)
		@find = (predicate) -> 
			@get("content").find(predicate)