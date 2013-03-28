Emu.CollectionField = Emu.Field.extend()
Emu.collection = (modelType) ->
	Emu.CollectionField.create(modelType: modelType, type: "array")