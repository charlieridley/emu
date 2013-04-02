Emu.field = (type, options)->
  options ?= {}
  meta =
    type: -> Ember.get(type) or type
    options: options
    isField: true
    isModel: -> Ember.get(type)?.isEmuModel
  
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
      if not getAttr(this, key) and meta.options.collection       
        collection = Emu.ModelCollection.create(type: meta.type(), parent: this)  
        collection.addObserver "content.@each", => @set("isDirty", true)
        setAttr(this, key, collection)
      if meta.options.lazy        
        @get("store").loadAll(getAttr(this, key))
      else if meta.options.partial 
        @get("store").loadModel(this)
      else if meta.options.defaultValue and not getAttr(this, key)
        setAttr(this, key, meta.options.defaultValue)
    getAttr(this, key)
  ).property().meta(meta)
