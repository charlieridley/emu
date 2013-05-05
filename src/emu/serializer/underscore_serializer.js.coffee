Emu.UnderscoreSerializer = Emu.Serializer.extend
  serializeKey: (key) ->
    @_super(key).replace /([A-Z])/g, (x) -> "_" + x.toLowerCase()

  deserializeKey: (key) ->
    key.replace /(\_[a-z])/g, (x) -> x.toUpperCase().replace('_','')