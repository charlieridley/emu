Emu.Model = Ember.Object.extend
	get: (key, options) ->
		fieldInfo = @_fields?[key]
		if options?.doNotLoad or @_super(key) or (not fieldInfo?.get("isPartial") and not fieldInfo?.get("isLazy"))
			return @_super(key)
		if (fieldInfo instanceof Emu.CollectionField) and fieldInfo?.get("isLazy")
			collection = Emu.ModelCollection.create(type: fieldInfo.get("modelType"), store: @_store, parent: this)
			@set(key, collection)
			@_store.loadAll(collection)
		if fieldInfo?.get("isPartial")
			@_store.loadModel(this)
		@_super(key)