Emu.ModelCollection = Ember.ArrayProxy.extend
  init: ->
    @set("content", Ember.A([]))
    @createRecord = (hash) ->
      model = @get("type").create(hash)     
      model.set("store", @get("store"))
      @pushObject(model)
    @addObserver "content.@each", =>
      @set("hasValue", true)
      @set("isDirty", true)
    
    @find = (predicate) -> 
      @get("content").find(predicate)