Emu.Model = Ember.Object.extend 
  init: ->
    if not @get("store")
      @set("store", Ember.get(Emu, "defaultStore"))   
  getValueOf: (key) ->
    @_attributes?[key]
  save: () -> Ember.get(Emu, "defaultStore").save(this)
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