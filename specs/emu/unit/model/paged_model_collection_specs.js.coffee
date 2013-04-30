describe "Emu.PagedModelCollection", ->
  
  describe "create", ->
    
    describe "not specifying page size", ->
      beforeEach ->
        @collection = Emu.PagedModelCollection.create()

      it "should have a default page size of 250", ->
        expect(@collection.get("pageSize")).toEqual(250)

      it "should have a default length of the page size", ->
        expect(@collection.get("length")).toEqual(250)

    describe "not specifying page size", ->
      beforeEach ->
        @collection = Emu.PagedModelCollection.create(pageSize: 10)

      it "should have a page size of 10", ->
        expect(@collection.get("pageSize")).toEqual(10)

      it "should have a length of the page size", ->
        expect(@collection.get("length")).toEqual(10)

  describe "nextObject", ->

    describe "nothing loaded", ->
      beforeEach ->
        @store = 
          loadPage: ->
        @collection = Emu.PagedModelCollection.create
          type: App.Person
          store: @store
        spyOn(@store, "loadPage").andCallFake () =>
          @collection.get("pages")[1] = Emu.ModelCollection.create()
          @collection.get("pages")[1].pushObject(App.Person.create())
        @result = @collection.nextObject()

      it "should load the first page from the store", ->
        expect(@store.loadPage).toHaveBeenCalledWith(@collection, 1)

      it "should return the first item in the collection", ->
        expect(@result).toBe(@collection.get("pages")[1].get("firstObject"))

    describe "call twice", ->

      beforeEach ->
        @store = 
          loadPage: ->
        @collection = Emu.PagedModelCollection.create
          type: App.Person
          store: @store
        spyOn(@store, "loadPage").andCallFake () =>
          @collection.get("pages")[1] = Emu.ModelCollection.create()
          @collection.get("pages")[1].pushObject(App.Person.create())
          @collection.get("pages")[1].pushObject(App.Person.create())
        @collection.nextObject()
        @result = @collection.nextObject()

      it "should return the second item in the collection of the first page", ->
        expect(@result).toBe(@collection.get("pages")[1].get("content")[1])

    describe "call for the first item on the second page", ->

      beforeEach ->
        @store = 
          loadPage: ->
        @collection = Emu.PagedModelCollection.create
          pageSize: 2
          type: App.Person
          store: @store
        spyOn(@store, "loadPage").andCallFake () =>
          @collection.get("pages")[1] = Emu.ModelCollection.create()
          @collection.get("pages")[1].pushObject(App.Person.create())
          @collection.get("pages")[1].pushObject(App.Person.create())
          @collection.get("pages")[2] = Emu.ModelCollection.create()
          @collection.get("pages")[2].pushObject(App.Person.create())
          @collection.get("pages")[2].pushObject(App.Person.create())
        @collection.nextObject()
        @collection.nextObject()
        @collection.nextObject()

      it "should load the first page from the store", ->
        expect(@store.loadPage).toHaveBeenCalledWith(@collection, 1)

      it "should load the second page from the store", ->
        expect(@store.loadPage).toHaveBeenCalledWith(@collection, 2)
