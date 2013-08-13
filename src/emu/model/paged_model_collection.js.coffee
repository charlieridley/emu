Emu.PagedModelCollection = Emu.ModelCollection.extend
  loadedPageCursor: 1
  init: ->
    @_super()
    @set("pages", Em.A([]))
    @set("pageSize", 250) if not @get("pageSize")

  loadMore: ->
    @get("store").loadPaged(this, @get("loadedPageCursor"))
    @_incrementCursor("loadedPageCursor")

  _incrementCursor: (cursor) ->
    @set(cursor, @get(cursor) + 1)