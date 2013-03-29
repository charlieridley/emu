Emu.Store = Ember.Object.extend
	init: ->		
		if not Ember.get(Emu, "defaultStore")
			Ember.set(Emu, "defaultStore", this)
		@set("modelCollections", {}) if @get("modelCollections") == undefined
		@_adapter = @get("adapter")?.create() || Emu.RestAdapter.create()
	createRecord: (type) ->
		collection = @_getCollectionForType(type)
		collection.createRecord(isDirty: true)
	find: (type, id) -> 
		if id then @findById(type, id) else @findAll(type)
	findAll: (type) ->
		collection = @_getCollectionForType(type)
		@loadAll(collection)
		collection	
	loadAll: (collection) ->
		if collection.get("isLoading") or collection.get("isLoaded")
			return collection
		collection.set("isLoading", true)
		@_adapter.findAll(collection.get("type"), this, collection)
		collection	
	save: (model) ->
		if model.get("id") then @_adapter.update(this, model) else @_adapter.insert(this, model)
	didFindAll: (collection, options) ->
		collection.set("isLoaded", true)
		collection.set("isLoading", false)
		collection.get("content").forEach (item) -> item.set("isLoaded", options?.fullyLoad)
	findById: (type, id) ->
		collection = @_getCollectionForType(type)
		model = collection.find (item) -> item.get("id") == id
		if not model
			model = collection.createRecord(id: id)			
		@loadModel(model)
	loadModel: (model) ->
		if not model.get("isLoading") and not model.get("isLoaded")
			model.set("isLoading", true)
			@_adapter.findById(model.constructor, this, model, model.get("id"))
		model
	didFindById: (model) ->
		model.set("isLoading", false)
		model.set("isLoaded", true)
	_getCollectionForType: (type) ->
		@get("modelCollections")[type] || @get("modelCollections")[type] = Emu.ModelCollection.create(type: type, store: this)