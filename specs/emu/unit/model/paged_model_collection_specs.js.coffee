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

    describe "second ", ->
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

  describe "nextObject", ->

    describe "nothing loaded", ->
      beforeEach ->
        @store = 
          loadPaged: ->
        @collection = Emu.PagedModelCollection.create
          type: App.Person
          store: @store        
        @result = @collection.nextObject()

      it "should return undefined", ->
        expect(@result).toBeUndefined()    

    describe "first page loaded", ->

      describe "first object", ->
        beforeEach ->
          @store = 
            loadPaged: ->
          @collection = Emu.PagedModelCollection.create
            type: App.Person
            store: @store     
          spyOn(@store, "loadPaged").andCallFake () =>
            @collection.get("pages")[1] = Emu.ModelCollection.create()
            @collection.get("pages")[1].pushObject(App.Person.create())
            @collection.get("pages")[1].pushObject(App.Person.create())
          @collection.loadMore()   
          @result = @collection.nextObject()

        it "should return the first result from the first page", ->
          expect(@result).toBe(@collection.get("pages")[1].get("content")[0])

      describe "call twice", ->
        beforeEach ->
          @store = 
            loadPaged: ->
          @collection = Emu.PagedModelCollection.create
            type: App.Person
            store: @store
          spyOn(@store, "loadPaged").andCallFake () =>
            @collection.get("pages")[1] = Emu.ModelCollection.create()
            @collection.get("pages")[1].pushObject(App.Person.create())
            @collection.get("pages")[1].pushObject(App.Person.create())
          @collection.loadMore()   
          @collection.nextObject()
          @result = @collection.nextObject()

        it "should return the second result from the first page", ->
          expect(@result).toBe(@collection.get("pages")[1].get("content")[1])

      describe "call for end of loaded page", ->
        beforeEach ->
          @store = 
            loadPaged: ->
          @collection = Emu.PagedModelCollection.create
            type: App.Person
            store: @store
          spyOn(@store, "loadPaged").andCallFake () =>
            @collection.get("pages")[1] = Emu.ModelCollection.create()
            @collection.get("pages")[1].pushObject(App.Person.create())
            @collection.get("pages")[1].pushObject(App.Person.create())
          @collection.loadMore()   
          @collection.nextObject()
          @collection.nextObject()
          @result = @collection.nextObject()

        it "should return undefined", ->
          expect(@result).toBeUndefined()

    describe "call for the first item on the second page", ->

      beforeEach ->
        @store = 
          loadPaged: ->
        @collection = Emu.PagedModelCollection.create
          pageSize: 2
          type: App.Person
          store: @store
        spyOn(@store, "loadPaged").andCallFake () =>
          @collection.get("pages")[1] = Emu.ModelCollection.create()
          @collection.get("pages")[1].pushObject(App.Person.create())
          @collection.get("pages")[1].pushObject(App.Person.create())
          @collection.get("pages")[2] = Emu.ModelCollection.create()
          @collection.get("pages")[2].pushObject(App.Person.create())
          @collection.get("pages")[2].pushObject(App.Person.create())
        @collection.loadMore()
        @collection.loadMore()
        @collection.nextObject()
        @collection.nextObject()
        @collection.nextObject()

      it "should load the second page from the store", ->
        expect(@store.loadPaged).toHaveBeenCalledWith(@collection, 2)

  describe "objectAt", ->

    beforeEach ->
      @store = 
        loadPaged: ->
      @collection = Emu.PagedModelCollection.create
        pageSize: 2
        type: App.Person
        store: @store        
      @collection.get("pages")[1] = Emu.ModelCollection.create()
      @collection.get("pages")[1].pushObject(App.Person.create())
      @collection.get("pages")[1].pushObject(App.Person.create())
      @collection.get("pages")[2] = Emu.ModelCollection.create()
      @collection.get("pages")[2].pushObject(App.Person.create())
      @collection.get("pages")[2].pushObject(App.Person.create())

    it "has items from the first page", ->
      expect(@collection.objectAt(1)).toBe(@collection.get("pages")[1].get("content")[1])

    it "has items from the second page", ->
      expect(@collection.objectAt(3)).toBe(@collection.get("pages")[2].get("content")[1])
