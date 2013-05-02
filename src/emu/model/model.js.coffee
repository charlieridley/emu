Emu.Model = Ember.Object.extend Emu.ModelEvented, Emu.StateTracked, Ember.Evented,
  init: -> 
    @_super()
    unless @get("store")
      @set("store", Ember.get(Emu, "defaultStore"))  
    @_primaryKey = Emu.Model.primaryKey(@constructor)
    @set("isDirty", true) if @get("isDirty") == undefined
    Emu.StateTracker.create().track(this)
  
  save: -> 
    @get("store").save(this)

  subscribeToUpdates: -> 
    @get("store").subscribeToUpdates(this)

  primaryKey: -> @_primaryKey or @_primaryKey = Emu.Model.primaryKey(@constructor)

  primaryKeyValue: (value) -> 
    if value
      @set(@primaryKey(), value) 
      @set("hasValue", true)
    @get(@primaryKey())

  clear: ->
    @constructor.eachEmuField (property, meta) =>
      if meta.isModel() or meta.options.collection
        Emu.Model.getAttr(this, property).clear()
      else
        @set(property, undefined)
    @set("hasValue", false)

Emu.proxyToStore = (methodName) ->
  ->
    store = Ember.get(Emu, "defaultStore")
    args = [].slice.call(arguments)
    args.unshift(this)
    Ember.assert("Cannot call " + methodName + ". You need define a store first like this: App.Store = Emu.Store.extend()", !!store)
    store[methodName].apply(store, args)

Emu.Model.reopenClass
  isEmuModel: true
  createRecord: Emu.proxyToStore("createRecord")
  find: Emu.proxyToStore("find")  
  findPaged: Emu.proxyToStore("findPaged")  

  primaryKey: (type = this) ->
    primaryKey = "id"  
    primaryKeyCount = 0
    type.eachComputedProperty (property, meta) =>
      if meta.options?.primaryKey
        primaryKey = property 
        primaryKeyCount++
    if primaryKeyCount > 1 
      throw new Error("Error with #{this}: You can only mark one field as a primary key")
    primaryKey
  
  eachEmuField: (callback) ->
    @eachComputedProperty (property, meta) ->
      if meta.isField
        callback(property, meta)

  getAttr: (record, key) ->
    meta = record.constructor.metaForProperty(key)
    record._attributes ?= {}   
    unless record._attributes[key]
      if meta.options.collection
        collectionType = if meta.options.paged then Emu.PagedModelCollection else Emu.ModelCollection
        record._attributes[key] = collectionType.create(parent: record, type: meta.type(), store: record.get("store"), lazy: meta.options.lazy)        
        record._attributes[key].addObserver "hasValue", -> record.set("hasValue", true)
        unless meta.options.lazy
          record._attributes[key].on "didStateChange", -> 
            record.didStateChange()
        record._attributes[key].subscribeToUpdates() if meta.options.updatable
      else if meta.isModel()
        record._attributes[key] = meta.type().create()
        record._attributes[key].on "didStateChange", -> 
          record.didStateChange()
    record._attributes[key] 
  
  setAttr: (record, key, value) ->
    record._attributes ?= {}
    record._attributes[key] = value
    record.set("hasValue", true)
