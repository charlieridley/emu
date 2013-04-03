Emu.Model = Ember.Object.extend 
  init: ->
    if not @get("store")
      @set("store", Ember.get(Emu, "defaultStore"))
  
  save: () -> 
    @get("store").save(this)

Emu.proxyToStore = (methodName) ->
  ->
    store = Ember.get(Emu, "defaultStore")
    args = [].slice.call(arguments)
    args.unshift(this)
    Ember.assert("Cannot call " + methodName + ". You need define a store first like this: App.Store = Emu.Store.extend()", !!store);
    store[methodName].apply(store, args)

Emu.Model.reopenClass
  isEmuModel: true
  createRecord: Emu.proxyToStore("createRecord")
  find: Emu.proxyToStore("find")  
  
  eachEmuField: (callback) ->
    @eachComputedProperty (property, meta) ->
      if meta.isField
        callback(property, meta)

  getAttr: (record, key) ->
    meta = record.constructor.metaForProperty(key)
    record._attributes ?= {}    
    if meta.options.collection and not record._attributes[key]
      record._attributes[key] = Emu.ModelCollection.create(parent: record, type: meta.type())
      record._attributes[key].addObserver "content.@each", -> record.set("isDirty", true)
    record._attributes[key] 
  
  setAttr: (record, key, value) ->
    record._attributes ?= {}
    record._attributes[key] = value