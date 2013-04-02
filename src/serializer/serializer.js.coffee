Emu.Serializer = Ember.Object.extend
  serializeTypeName: (type) ->
    parts = type.toString().split(".")
    parts[parts.length - 1].toLowerCase()
  serializeModel: (model) ->
    jsonData = 
      id: model.get("id")
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
  serializeQueryHash: (queryHash) ->
    queryString = "?"
    for key, value of queryHash
      queryString += key + "=" + value + "&"
    queryString.slice(0, queryString.length - 1)
  _deserializeProperty: (model, property, value, meta) ->   
    if meta.options.collection
      if value
        collection = Emu.ModelCollection.create
          type: meta.type()       
          parent: model
        @deserializeCollection(collection, value)
        model.set(property, collection)
    else if meta.isModel()
      if value
        modelProperty = meta.type().create()
        @deserializeModel(modelProperty, value) 
        model.set(property, modelProperty)
    else
      attributeSerializer = Emu.AttributeSerializers[meta.type()]
      value = attributeSerializer.deserialize(value)
      model.set(property, value) if value
  _serializeProperty: (model, jsonData, property, meta) ->    
    if meta.options.collection
      if collection = model.getValueOf(property)
        jsonData[property] = collection.map (item) => @serializeModel(item)
    else if meta.isModel()
      propertyValue = model.getValueOf(property)
      jsonData[property] = @serializeModel(propertyValue) if propertyValue
    else
      attributeSerializer = Emu.AttributeSerializers[meta.type()]
      jsonData[property] = attributeSerializer.serialize(model.getValueOf(property))
