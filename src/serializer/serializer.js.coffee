Emu.Serializer = Ember.Object.extend
	serializeTypeName: (type) ->
		parts = type.toString().split(".")
		parts[parts.length - 1].toLowerCase()
	serializeModel: (model) ->
		jsonData = {id: model.get("id")}
		model.constructor.eachEmuField (property, meta) =>		
			@_serializeProperty(model, jsonData, property, meta)			
		jsonData
	deserializeModel: (model, jsonData) ->
		model.set("id", jsonData.id) if jsonData.id
		model.constructor.eachEmuField (property, meta) =>
			@_deserializeProperty(model, property, jsonData[property], meta)	
		model
	deserializeCollection: (collection, jsonData) ->
		jsonData.forEach (item) =>
			model = collection.createRecord()
			@deserializeModel(model, item)			
	_deserializeProperty: (model, property, value, meta) ->		
		if meta.options.collection
			if value
				collection = Emu.ModelCollection.create
					type: meta.type					
					parent: model
				@deserializeCollection(collection, value)
				model.set(property, collection)
		else
			attributeSerializer = Emu.AttributeSerializers[meta.type]
			value = attributeSerializer.deserialize(value)
			model.set(property, value) if value
	_serializeProperty: (model, jsonData, property, meta) ->		
		if meta.options.collection
			collection = model.getValueOf(property)
			jsonData[property] = collection.map (item) => @serializeModel(item)
		else
			attributeSerializer = Emu.AttributeSerializers[meta.type]
			jsonData[property] = attributeSerializer.serialize(model.getValueOf(property))
