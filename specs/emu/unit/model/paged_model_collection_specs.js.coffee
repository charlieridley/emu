describe "Emu.PagedModelCollection", ->
  
  describe "create", ->
    
    describe "not specifying page size", ->
      beforeEach ->
        @collection = Emu.PagedModelCollection.create()

      it "should have a default page size of 250", ->
        expect(@collection.get("pageSize")).toEqual(250)

    describe "not specifying page size", ->
      beforeEach ->
        @collection = Emu.PagedModelCollection.create(pageSize: 10)

      it "should have a page size of 10", ->
        expect(@collection.get("pageSize")).toEqual(10)

  describe "loadMore", ->
    
    describe "first load", ->
      beforeEach ->
        @store = 
          loadPaged: ->
        @collection = Emu.PagedModelCollection.create
          type: App.Person
          store: @store
          pageSize: 10
        spyOn(@store, "loadPaged")
        @collection.loadMore()

      it "should load the first page from the store", ->
        expect(@store.loadPaged).toHaveBeenCalledWith(@collection, 1)

    describe "second load", ->
      beforeEach ->
        @store = 
          loadPaged: ->
        @collection = Emu.PagedModelCollection.create
          type: App.Person
          store: @store
          pageSize: 10
        spyOn(@store, "loadPaged")
        @collection.loadMore()
        @collection.loadMore()

      it "should load the first page from the store", ->
        expect(@store.loadPaged).toHaveBeenCalledWith(@collection, 2)
