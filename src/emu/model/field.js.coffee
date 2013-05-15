Emu.field = (type, options) ->
  options ?= {}
  meta =
    type: -> Ember.get(type) or type
    options: options
    isField: true
    isModel: -> Ember.get(type)?.isEmuModel

  Ember.computed((key, value, oldValue) ->
    meta = @constructor.metaForProperty(key)
    if arguments.length > 1
      Emu.Model.setAttr(this, key, value)
      @didStateChange()
      @set("hasValue", true)
    else
      if meta.options.lazy and @primaryKeyValue()
        @get("store")?.loadAll(Emu.Model.getAttr(this, key))
      else if meta.options.partial
        @get("store")?.loadModel(this)
      if meta.options.paged
        Emu.Model.getAttr(this, key).loadMore()
      if meta.options.defaultValue and not Emu.Model.getAttr(this, key)
        Emu.Model.setAttr(this, key, meta.options.defaultValue)
    Emu.Model.getAttr(this, key)
  ).property().meta(meta)
