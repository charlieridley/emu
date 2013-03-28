Emu.field = (type, options)->
	options ?= {}
	meta =
		type: type
		options: options
	getAttr = (record, key) ->
		record._attributes ?= {}
		record._attributes[key]
	setAttr = (record, key, value) ->
		record._attributes ?= {}
		record._attributes[key] = value
	Ember.computed((key, value, oldValue) ->
		meta = @constructor.metaForProperty(key)		
		if arguments.length > 1
			setAttr(this, key, value)
		else
			if meta.options.lazy and not getAttr(this, key) 
				returnVal = Emu.ModelCollection.create(type: meta.type, store: @_store, parent: this)				
				@_store.loadAll(returnVal)
			else if meta.options.partial 
				@_store.loadModel(this)
		returnVal || getAttr(this, key)
	).property("data").meta(meta)
