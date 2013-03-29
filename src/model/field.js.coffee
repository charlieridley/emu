Emu.field = (type, options)->
	options ?= {}
	meta =
		type: type
		options: options
		isEmuField: true
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
			@set("isDirty", true)
		else
			if not getAttr(this, key) 
				collection = Emu.ModelCollection.create(type: meta.type, parent: this)	
				collection.addObserver "content.@each", => @set("isDirty", true)
				setAttr(this, key, collection)
			if meta.options.lazy				
				@get("store").loadAll(getAttr(this, key))
			else if meta.options.partial 
				@get("store").loadModel(this)
		getAttr(this, key)
	).property("data").meta(meta)
