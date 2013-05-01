Emu.PagedModelCollection = Ember.Object.extend Ember.Array,
  pageSize: 250  
  cursor: -1
  pageCursor: 1
  loadedPageCursor: 1
  cursorOnPage: -1
  init: ->
    @set("length", @get("pageSize"))
    @set("pages", Em.A([]))
  
  nextObject: () ->        
    @_incrementCursor("cursor")
    @_incrementCursor("cursorOnPage")
    if @get("cursorOnPage") >= @get("pageSize")
      @set("cursorOnPage", 0)
      @_incrementCursor("pageCursor")
    @get("pages")[@get("pageCursor")]?.get("content")[@get("cursorOnPage")]

  objectAt: (index) ->
    pageNumber = Math.floor(index / @get("pageSize")) + 1
    pageIndex = index - ((pageNumber - 1) * @get("pageSize"))
    @get("pages")[pageNumber].get("content")[pageIndex]

  loadMore: ->
    @get("store").loadPaged(this, @get("loadedPageCursor"))    
    @_incrementCursor("loadedPageCursor")

  _incrementCursor: (cursor) ->
    @set(cursor, @get(cursor) + 1)