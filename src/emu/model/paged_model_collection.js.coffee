Emu.PagedModelCollection = Ember.Object.extend Ember.Enumerable,
  pageSize: 250  
  cursor: -1
  pageCursor: 1
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
    @get("store").loadPage(this, @get("pageCursor"))    
    @get("pages")[@get("pageCursor")].get("content")[@get("cursorOnPage")]

  _incrementCursor: (cursor) ->
    @set(cursor, @get(cursor) + 1)