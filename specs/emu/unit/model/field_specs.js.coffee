describe "Emu.field", ->
  Person = Emu.Model.extend()
  Order = Emu.Model.extend()

  describe "creating", ->

    describe "as string", ->
      beforeEach ->
        @Person = Emu.Model.extend
          name: Emu.field("string")

      it "should have a type of 'string'", ->
        expect(@Person.metaForProperty("name").type()).toEqual("string")

    describe "as number", ->
      beforeEach ->
        @Person = Emu.Model.extend
          age: Emu.field("number")

      it "should have a type of 'number'", ->
        expect(@Person.metaForProperty("age").type()).toEqual("number")

    describe "as a type of model", ->
      beforeEach ->
        @Person = Emu.Model.extend
          order: Emu.field("App.Order")

      it "should mark the field as a model lazy", ->
        expect(@Person.metaForProperty("order").isModel()).toBeTruthy()

      it "should have the type which was specified", ->
        expect(@Person.metaForProperty("order").type()).toBe(App.Order)

    describe "and marking with options", ->
      beforeEach ->
        @Person = Emu.Model.extend
          name: Emu.field("App.Order", {lazy: true, partial: false})

      it "should mark the field as lazy", ->
        expect(@Person.metaForProperty("name").options).toEqual({lazy: true, partial: false})

  describe "get", ->

    describe "normal value", ->

      describe "when it has a value", ->
        beforeEach ->
          Person = Emu.Model.extend
            name: Emu.field("string")
          @model = Person.create(name: "henry")
          @result = @model.get("name")

        it "should get the value", ->
          expect(@result).toEqual("henry")

      describe "no value", ->

        describe "without a defaultValue", ->
          beforeEach ->
            Person = Emu.Model.extend
              name: Emu.field("string")
            @model = Person.create()
            @result = @model.get("name")

          it "should get the value", ->
            expect(@result).toBeUndefined()

        describe "with a defaultValue", ->
          beforeEach ->
            Person = Emu.Model.extend
              name: Emu.field("string", defaultValue: "barry")
            @model = Person.create()
            @result = @model.get("name")

          it "should get the value", ->
            expect(@result).toEqual("barry")

    describe "collection", ->

      describe "which is set", ->
        beforeEach ->
          @orders = Emu.ModelCollection.create(type: App.Order)
          Person = Emu.Model.extend
            name: Emu.field("App.Order", {collection: true})
          @model = Person.create(orders: @orders)
          @result = @model.get("orders")

        it "should return the collection", ->
          expect(@result).toBe(@orders)

      describe "which is not set", ->
        beforeEach ->
          @store = Ember.Object.create
            loadAll: ->
          spyOn(@store, "loadAll")
          @orders = Emu.ModelCollection.create(type: App.Order)
          spyOn(Emu.ModelCollection, "create").andReturn(@orders)
          Person = Emu.Model.extend
            store: @store
            orders: Emu.field("App.Order", {collection: true})
          @model = Person.create()
          @result = @model.get("orders")

        it "should return an empty collection", ->
          expect(@result.get("length")).toEqual(0)

        it "should not query the store", ->
          expect(@store.loadAll).not.toHaveBeenCalled()

    describe "lazy collection", ->

      describe "which is not set", ->
        beforeEach ->
          @store = Ember.Object.create
            loadAll: ->
          @orders = Emu.ModelCollection.create(type: App.Order)
          spyOn(@store, "loadAll")
          spyOn(Emu.ModelCollection, "create").andReturn(@orders)
          Person = Emu.Model.extend
            store: @store
            orders: Emu.field("App.Order", {collection: true, lazy: true})
          @model = Person.create(id:6)
          @result = @model.get("orders")

        it "should get all the models for the collection from the store", ->
          expect(@store.loadAll).toHaveBeenCalledWith(@orders)

        it "should return the collection", ->
          expect(@result).toBe(@orders)

      describe "is loaded", ->
        beforeEach ->
          @store = Ember.Object.create
            loadAll: ->
          @orders = Emu.ModelCollection.create(type: App.Order)
          spyOn(@store, "loadAll")
          spyOn(Emu.ModelCollection, "create").andReturn(@orders)
          Person = Emu.Model.extend
            store: @store
            orders: Emu.field("App.Order", {collection: true, lazy: true})
          @model = Person.create(id:5)
          @model.get("orders")
          @model.get("orders")

        it "should get the models from the store only once", ->
          expect(@store.loadAll.calls.length).toEqual(1)
          @result = @model.get("orders")

      describe "parent does not have primary key", ->
        beforeEach ->
          @store = Ember.Object.create
            loadAll: ->
          @orders = Emu.ModelCollection.create(type: App.Order)
          spyOn(@store, "loadAll")
          spyOn(Emu.ModelCollection, "create").andReturn(@orders)
          Person = Emu.Model.extend
            store: @store
            orders: Emu.field("App.Order", {collection: true, lazy: true})
          @model = Person.create()
          @model.get("orders")

        it "should not load the collection from the store", ->
          expect(@store.loadAll.calls.length).toEqual(0)


    describe "partial property", ->

      describe "passing a store", ->
        beforeEach ->
          @store = Ember.Object.create
            loadModel: ->
          Person = Emu.Model.extend
            name: Emu.field("string", {partial: true})
          @person = Person.create(id: 5, store: @store)
          spyOn(@store, "loadModel")
          @person.get("name")

        it "should load the parent object", ->
          expect(@store.loadModel).toHaveBeenCalledWith(@person)

      describe "not passing a store", ->

        describe "with default store", ->
          beforeEach ->
            Emu.set("defaultStore", undefined)
            @defaultStore = Emu.Store.create()
            spyOn(@defaultStore, "loadModel")
            Person = Emu.Model.extend
              name: Emu.field("string", {partial: true})
            @person = Person.create(id: 5)
            @person.get("name")

          it "should load the parent object", ->
            expect(@defaultStore.loadModel).toHaveBeenCalledWith(@person)

        describe "without default store", ->
          beforeEach ->
            Emu.set("defaultStore", undefined)
            Person = Emu.Model.extend
              name: Emu.field("string", {partial: true})
            person = Person.create(id: 5)
            @result = person.get("name")

          it "should return undefined", ->
            expect(@result).toBeUndefined()

    describe "model property", ->

      describe "when it has no value", ->
        beforeEach ->
          Person = Emu.Model.extend
            order: Emu.field("App.Order")
          @model = Person.create()

        it "should return App.Order", ->
          expect(@model.get("order").constructor.toString()).toEqual("App.Order")

        it "should have hasValue false on the return object", ->
          expect(@model.get("hasValue")).toBeFalsy()

    describe "paged collection", ->

      describe "which is not set", ->
        beforeEach ->
          @store = Ember.Object.create
            loadAll: ->
          @orders = Emu.PagedModelCollection.create(type: App.Order)
          spyOn(@orders, "loadMore")
          spyOn(Emu.PagedModelCollection, "create").andReturn(@orders)
          Person = Emu.Model.extend
            store: @store
            orders: Emu.field("App.Order", {collection: true, paged: true})
          @model = Person.create(id:6)
          @result = @model.get("orders")

        it "should load the first page", ->
          expect(@orders.loadMore).toHaveBeenCalled()

        it "should return the collection", ->
          expect(@result).toBe(@orders)

      describe "specify pageSize", ->
        beforeEach ->
          @store = Ember.Object.create
            loadAll: ->
          @orders = Emu.PagedModelCollection.create(type: App.Order)
          spyOn(@orders, "loadMore")
          spyOn(Emu.PagedModelCollection, "create").andReturn(@orders)
          Person = Emu.Model.extend
            store: @store
            orders: Emu.field("App.Order", {collection: true, paged: true, pageSize: 10})
          @model = Person.create(id:6)
          @result = @model.get("orders")

        it "should create the paged model collection passing the pageSize", ->
          expect(Emu.PagedModelCollection.create.mostRecentCall.args[0].pageSize).toEqual(10)

  describe "set", ->

    describe "simple field", ->
      beforeEach ->
        @model = App.Person.create(isDirty:false)
        @model.on "didStateChange", => @didStateChange = true
        @model.set("name", "Harold")

      it "should have fired a state change event", ->
        expect(@didStateChange).toBeTruthy()

      it "should be in a dirty state", ->
        expect(@model.get("isDirty")).toBeTruthy()

      it "should have hasValue set to true", ->
        expect(@model.get("hasValue")).toBeTruthy()