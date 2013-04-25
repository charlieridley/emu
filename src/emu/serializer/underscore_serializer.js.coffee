Emu.UnderscoreSerializer = Emu.Serializer.extend
  serializeKey: (key) ->
    @_super(key).replace /([A-Z])/g, (x) -> "_" + x.toLowerCase()

  deserializeKey: (key) ->
    key.replace /(\_[a-z])/g, (x) -> x.toUpperCase().replace('_','')

  serializeTypeName: (type) ->
    if type.resourceName
      name = type.resourceName
      if typeof name is 'function' then name() else name
    else
      typeString = type.toString()
      parts = typeString.split '.'
      name = parts[parts.length - 1]
      name.replace(/([A-Z])/g, '_$1').toLowerCase().slice(1) + 's'
