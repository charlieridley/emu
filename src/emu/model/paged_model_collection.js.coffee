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
    item = @_collectionForPage(@get("pageCursor"))[@get("cursor")]
    @get("store").loadPage(this, @get("pageCursor"))
    item

  _collectionForPage: (pageNumber) ->
    unless @get("pages")[pageNumber]
      @get("pages")[pageNumber] = []
      for i in [0..@get("pageSize") - 1]
        @get("pages")[pageNumber].pushObject(@get("type").create())
    @get("pages")[pageNumber]

  _incrementCursor: (cursor) ->
    @set(cursor, @get(cursor) + 1)