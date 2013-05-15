Emu.PagedModelCollection = Emu.ModelCollection.extend
  pageSize: 250
  loadedPageCursor: 1
  init: ->
    @_super()
    @set("pages", Em.A([]))

  loadMore: ->
    @get("store").loadPaged(this, @get("loadedPageCursor"))
    @_incrementCursor("loadedPageCursor")

  _incrementCursor: (cursor) ->
    @set(cursor, @get(cursor) + 1)