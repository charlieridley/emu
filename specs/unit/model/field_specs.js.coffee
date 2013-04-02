describe "Emu.field", ->  
  Person = Emu.Model.extend() 
  Order = Emu.Model.extend()
  
  describe "When creating", ->  
    
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
  
  describe "When getting field", ->
    
    describe "as normal value", ->
      
      describe "when it has a value", ->
        beforeEach ->
          Person = Emu.Model.extend
            name: Emu.field("string")
          @model = Person.create(name: "henry")
          @result = @model.get("name")
        it "should get the value", ->
          expect(@result).toEqual("henry")

      describe "when it doesn't have a value", ->
        
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

    describe "as collection", ->

      describe "with is set", ->
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
  
    describe "as lazy collection", ->

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
          @model = Person.create()
          @result = @model.get("orders")    
        it "should get all the models for the collection from the store", ->
          expect(@store.loadAll).toHaveBeenCalledWith(@orders)
        it "should return the collection", ->
          expect(@result).toBe(@orders)
  
      describe "after it has been loaded", ->
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
          @model.get("orders")
        it "should get the models from the store only once", ->
          expect(@store.loadAll.calls.length).toEqual(1)
          @result = @model.get("orders")
  
    describe "as a partial property", ->
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

    describe "as a model property", ->

      describe "when it has no value", ->
        beforeEach ->
          Person = Emu.Model.extend
            order: Emu.field("App.Order")
          @model = Person.create()
        it "should not return anything", ->
          expect(@model.get("order")).toBeFalsy()

