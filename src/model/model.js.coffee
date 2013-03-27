Emu.Model = Ember.Object.extend
	get: (key) ->
		fieldInfo = @_fields?[key]
		if (fieldInfo instanceof Emu.CollectionField) and fieldInfo.get("isLazy") and not @_super(key)
			collection = Emu.ModelCollection.create(type: fieldInfo.get("modelType"), store: @_store, parent: this)
			@set(key, collection)
			@_store.findAll(fieldInfo.get("modelType"), {fullyLoad: true, collection: collection})
		@_super(key)