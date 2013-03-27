Emu.Serializer = Ember.Object.extend
	serializeTypeName: (type) ->
		parts = type.toString().split(".")
		parts[parts.length - 1].toLowerCase()
	serializeModel: (model) ->
		jsonData = {}
		for property, attributeInfo of model._fields			
			@_serializeProperty(model, jsonData, attributeInfo, property)			
		jsonData
	deserializeModel: (model, jsonData) ->
		for property, attributeInfo of model._fields
			attributeInfo = model._fields[property]
			@_deserializeProperty(model, jsonData, attributeInfo, property)
		model
	deserializeCollection: (collection, jsonData) ->
		jsonData.forEach (item) =>
			model = collection.createRecord()
			@deserializeModel(model, item)			
	_deserializeProperty: (model, jsonData, attributeInfo, property) ->
		type = attributeInfo.get("type")
		if type == "array" 
			if jsonData[property]
				collection = Emu.ModelCollection.create
					type: attributeInfo.get("modelType")
					store: model._store			
					parent: model
				@deserializeCollection(collection, jsonData[property])
				model.set(property, collection)
		else
			attributeSerializer = Emu.AttributeSerializers[type]
			value = attributeSerializer.deserialize(jsonData[property])
			model.set(property, value)
	_serializeProperty: (model, jsonData, attributeInfo, property) ->
		type = attributeInfo.get("type")
		if type == "array" 			
			collection = model.get(property, {doNotLoad: true})
			jsonData[property] = collection.map (item) => @serializeModel(item)
		else
			attributeSerializer = Emu.AttributeSerializers[type]
			jsonData[property] = attributeSerializer.serialize(model.get(property))
