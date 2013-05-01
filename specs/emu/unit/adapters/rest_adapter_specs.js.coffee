describe "Emu.RestAdapter", ->  
  Person = Emu.Model.extend()
  serializer = Ember.Object.create
    serializeTypeName: ->
    deserializeCollection: ->
    deserializeModel: ->
    serializeModel: ->
    serializeQueryHash: ->
    serializeKey: ->
  Serializer = 
    create: -> serializer
  
  describe "create", ->

    describe "no serializer specified", ->
      beforeEach ->
        spyOn(Emu.Serializer, "create")
        @adapter = Emu.RestAdapter.create()
      
      it "should create the default serializer", ->
        expect(Emu.Serializer.create).toHaveBeenCalled()

    describe "serializer specified", ->
      MySerializer = Ember.Object.extend()      
      beforeEach ->        
        spyOn(MySerializer, "create")
        @adapter = Emu.RestAdapter.create(serializer: MySerializer)
      
      it "should create the default serializer", ->
        expect(MySerializer.create).toHaveBeenCalled()
  
  describe "findAll", ->
    
    describe "with namespace", ->
      beforeEach ->
        spyOn($, "ajax")      
        models = Emu.ModelCollection.create(type: Person)
        store = Ember.Object.create()
        spyOn(serializer, "serializeTypeName").andReturn("person")
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        @adapter.findAll(Person, store, models)
      
      it "should make a GET request to the endpoint for the entity", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person")
        expect($.ajax.mostRecentCall.args[0].type).toEqual("GET")
    
    describe "no namespace", ->
      beforeEach ->
        spyOn($, "ajax")      
        models = Emu.ModelCollection.create()
        store = Ember.Object.create()
        spyOn(serializer, "serializeTypeName").andReturn("person")
        @adapter = Emu.RestAdapter.create
          serializer: Serializer
        @adapter.findAll(Person, store, models)
      
      it "should make a GET request to the endpoint for the entity", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("person")
    
    describe "loading finishes successfully", ->
      beforeEach ->
        @jsonData = [
          firstName: "Larry"
          lastName: "Laffer"
        ]
        spyOn($, "ajax")
        @models = Emu.ModelCollection.create()
        @store = Ember.Object.create
          didFindAll: ->
        spyOn(serializer, "serializeTypeName").andReturn("person")
        spyOn(serializer, "deserializeCollection")
        spyOn(@store, "didFindAll")
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        @adapter.findAll(Person, @store, @models)
        $.ajax.mostRecentCall.args[0].success(@jsonData)
      
      it "should deserialize the result", ->
        expect(serializer.deserializeCollection).toHaveBeenCalledWith(@models, @jsonData)
      
      it "should notify the store", ->
        expect(@store.didFindAll).toHaveBeenCalledWith(@models)

    describe "loading fails", ->
      beforeEach ->
        @jsonData = [
          firstName: "Larry"
          lastName: "Laffer"
        ]
        spyOn($, "ajax")
        @models = Emu.ModelCollection.create()
        @store = Ember.Object.create
          didError: ->
        spyOn(serializer, "serializeTypeName").andReturn("person")
        spyOn(serializer, "deserializeCollection")
        spyOn(@store, "didError")
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        @adapter.findAll(Person, @store, @models)
        $.ajax.mostRecentCall.args[0].error()

      it "should notify the store", ->
        expect(@store.didError).toHaveBeenCalledWith(@models)

    describe "collection that has a parent", ->
      beforeEach ->
        spyOn($, "ajax")      
        ParentPerson = Emu.Model.extend()
        parent = ParentPerson.create 
          parent: Emu.ModelCollection.create
            type: ParentPerson
        spyOn(parent, "primaryKeyValue").andReturn(5)
        models = Emu.ModelCollection.create(parent: parent, type: Person)
        store = Ember.Object.create()
        spyOn(serializer, "serializeTypeName").andCallFake (type) ->
          if type == ParentPerson 
            return "parentperson"
          if type == Person
            return "person"
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        @adapter.findAll(Person, store, models)

      it "should make a GET request to the URL for the entity", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/parentperson/5/person")
        expect($.ajax.mostRecentCall.args[0].type).toEqual("GET")
  
  describe "findById", ->
    
    describe "starts loading", ->
      beforeEach ->
        spyOn($, "ajax")      
        model = Person.create    
          parent: Emu.ModelCollection.create
            type: Person
        store = Ember.Object.create()
        spyOn(serializer, "serializeTypeName").andReturn("person")
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        @adapter.findById(Person, store, model, 5)
      
      it "should make a GET request to the endpoint for the entity", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person/5")
        expect($.ajax.mostRecentCall.args[0].type).toEqual("GET")
    
    describe "finishes loading", ->
      beforeEach ->
        @jsonData = 
          firstName: "Larry"
          lastName: "Laffer"    
        spyOn($, "ajax")      
        @model = Person.create()
        @store = Ember.Object.create(didFindById: ->)
        spyOn(serializer, "serializeTypeName").andReturn("person")
        spyOn(serializer, "deserializeModel")
        spyOn(@store, "didFindById")
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        @adapter.findById(Person, @store, @model, 5)
        $.ajax.mostRecentCall.args[0].success(@jsonData)
      
      it "should deserialize the model", ->
        expect(serializer.deserializeModel).toHaveBeenCalledWith(@model, @jsonData)
      
      it "should notify the store", ->
        expect(@store.didFindById).toHaveBeenCalledWith(@model)  
  
  describe "findQuery", ->
    
    describe "starts loading", ->
      beforeEach ->
        spyOn(serializer, "serializeQueryHash").andReturn("?age=40&hairColour=brown")
        spyOn(serializer, "serializeTypeName").andReturn("person")
        spyOn($, "ajax")
        @store = Ember.Object.create()
        @adapter = Emu.RestAdapter.create
            namespace: "api"
            serializer: Serializer
        @adapter.findQuery(Person, @store, @model, {age: "40", hairColour: "brown"})
      
      it "should serialize the query hash", ->
        expect(serializer.serializeQueryHash).toHaveBeenCalledWith({age: "40", hairColour: "brown"})
      
      it "should make a GET request with the serialized query parameters", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person?age=40&hairColour=brown")
        expect($.ajax.mostRecentCall.args[0].type).toEqual("GET")
    
    describe "finishes loading successfully", ->
      beforeEach ->
        @jsonData = [
          firstName: "Larry"
          lastName: "Laffer"   
        ]
        @store = Ember.Object.create
          didFindQuery: ->
        @models = Emu.ModelCollection.create()
        spyOn(serializer, "serializeQueryHash").andReturn("?age=40&hairColour=brown")
        spyOn(serializer, "serializeTypeName").andReturn("person")
        spyOn(serializer, "deserializeCollection")
        spyOn($, "ajax")
        spyOn(@store, "didFindQuery")
        @adapter = Emu.RestAdapter.create
            namespace: "api"
            serializer: Serializer        
        @adapter.findQuery(Person, @store, @models, {age: "40", hairColour: "brown"})
        $.ajax.mostRecentCall.args[0].success(@jsonData)
      
      it "should deserialize the result", ->
        expect(serializer.deserializeCollection).toHaveBeenCalledWith(@models, @jsonData)
      
      it "should notify the store", ->
        expect(@store.didFindQuery).toHaveBeenCalledWith(@models)

    describe "finishes with failure", ->
      beforeEach ->
        @jsonData = [
          firstName: "Larry"
          lastName: "Laffer"   
        ]
        @store = Ember.Object.create
          didError: ->
        @models = Emu.ModelCollection.create()
        spyOn(serializer, "serializeQueryHash").andReturn("?age=40&hairColour=brown")
        spyOn(serializer, "serializeTypeName").andReturn("person")
        spyOn(serializer, "deserializeCollection")
        spyOn($, "ajax")
        spyOn(@store, "didError")
        @adapter = Emu.RestAdapter.create
            namespace: "api"
            serializer: Serializer        
        @adapter.findQuery(Person, @store, @models, {age: "40", hairColour: "brown"})
        $.ajax.mostRecentCall.args[0].error()

      it "should notify the store", ->
        expect(@store.didError).toHaveBeenCalledWith(@models)
  
  describe "insert", ->
    
    describe "start request", ->
      beforeEach ->
        @store = Ember.Object.create()
        spyOn($, "ajax")
        @jsonData = {name: "Henry"}
        @model = Person.create
          parent: Emu.ModelCollection.create
            type: Person
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        spyOn(serializer, "serializeModel").andReturn(@jsonData)
        spyOn(serializer, "serializeTypeName").andReturn("person")
        @adapter.insert(@store, @model)
      
      it "should deserialize the model", ->
        expect(serializer.serializeModel).toHaveBeenCalledWith(@model)
      
      it "should send a POST request", ->
        expect($.ajax.mostRecentCall.args[0].type).toEqual("POST")
      
      it "should send the deserialized model in the request", ->
        expect($.ajax.mostRecentCall.args[0].data).toEqual(@jsonData)
      
      it "should serialize the type name", ->
        expect(serializer.serializeTypeName).toHaveBeenCalledWith(@model.constructor)
      
      it "should send the request to the correct URL for the model", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person")
    
    describe "finish request successfully", ->
      beforeEach ->   
        @store = 
          didSave: ->
        spyOn(@store, "didSave")
        spyOn($, "ajax")
        @jsonData = {name: "Henry"}
        @model = Person.create()
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        spyOn(serializer, "serializeModel").andReturn(@jsonData)
        spyOn(serializer, "serializeTypeName").andReturn("person")
        spyOn(serializer, "deserializeModel")
        @adapter.insert(@store, @model)
        @response =
          id: 5
          name: "Henry"
        $.ajax.mostRecentCall.args[0].success(@response)        
      
      it "should deserialize the model", ->
        expect(serializer.deserializeModel).toHaveBeenCalledWith(@model, @response)
      
      it "should notify the store", ->
        expect(@store.didSave).toHaveBeenCalledWith(@model)

    describe "finish request with failure", ->
      beforeEach ->   
        @store = 
          didError: ->
        spyOn(@store, "didError")
        spyOn($, "ajax")
        @jsonData = {name: "Henry"}
        @model = Person.create()
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        spyOn(serializer, "serializeModel").andReturn(@jsonData)
        spyOn(serializer, "serializeTypeName").andReturn("person")
        spyOn(serializer, "deserializeModel")
        @adapter.insert(@store, @model)
        @response =
          id: 5
          name: "Henry"
        $.ajax.mostRecentCall.args[0].error()        
      
      it "should notify the store", ->
        expect(@store.didError).toHaveBeenCalledWith(@model)

    describe "has parent", ->
      beforeEach ->
        spyOn($, "ajax")
        customer = App.Customer.create
          id: 10
          parent: Emu.ModelCollection.create
            type: App.Customer
        @order = App.Order.create
          parent: Emu.ModelCollection.create
            parent: customer
            type: App.Order
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        spyOn(serializer, "serializeTypeName").andCallFake (type) ->
          if type == App.Customer then "customer" else "order"
        @adapter.insert(Ember.Object.create(), @order)

      it "should send the request to the correct URL for the model", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/customer/10/order")
  
  describe "update", ->
    
    describe "start request", ->
      beforeEach ->
        @store = Ember.Object.create()
        spyOn($, "ajax")
        @jsonData = {name: "Henry"}
        @model = Person.create
          id: 80
          parent: Emu.ModelCollection.create
            type: Person
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        spyOn(serializer, "serializeModel").andReturn(@jsonData)
        spyOn(serializer, "serializeTypeName").andReturn("person")
        @adapter.update(@store, @model)
      
      it "should deserialize the model", ->
        expect(serializer.serializeModel).toHaveBeenCalledWith(@model)
      
      it "should send a PUT request", ->
        expect($.ajax.mostRecentCall.args[0].type).toEqual("PUT")
      
      it "should send the deserialized model in the request", ->
        expect($.ajax.mostRecentCall.args[0].data).toEqual(@jsonData)
      
      it "should serialize the type name", ->
        expect(serializer.serializeTypeName).toHaveBeenCalledWith(@model.constructor)
      
      it "should send the request to the correct URL for the model", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person/80")

  describe "delete", ->

    describe "start request", ->
      beforeEach ->
        spyOn($, "ajax")
        @model = Person.create
          id: 6
          parent: Emu.ModelCollection.create
            type: Person
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        spyOn(serializer, "serializeTypeName").andReturn("person")
        @adapter.delete({}, @model)
      
      it "should send a DELETE request", ->
        expect($.ajax.mostRecentCall.args[0].type).toEqual("DELETE")
      
      it "should serialize the type name", ->
        expect(serializer.serializeTypeName).toHaveBeenCalledWith(@model.constructor)
      
      it "should send the request to the correct URL for the model", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person/6")

    describe "finishes successfully" , ->
      beforeEach ->
        spyOn($, "ajax")
        @store = 
          didDeleteRecord: jasmine.createSpy()
        @model = Person.create(id: 6)
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        spyOn(serializer, "serializeTypeName").andReturn("person")
        @adapter.delete(@store, @model)
        $.ajax.mostRecentCall.args[0].success()

      it "should notify the store", ->
        expect(@store.didDeleteRecord).toHaveBeenCalledWith(@model)

    describe "finishes with failure" , ->
      beforeEach ->
        spyOn($, "ajax")
        @store = 
          didError: jasmine.createSpy()
        @model = Person.create(id: 6)
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        spyOn(serializer, "serializeTypeName").andReturn("person")
        @adapter.delete(@store, @model)
        $.ajax.mostRecentCall.args[0].error()

      it "should notify the store", ->
        expect(@store.didError).toHaveBeenCalledWith(@model)

  describe "findPage", ->

    describe "start request", ->
      beforeEach ->   
        @store = {}
        spyOn($, "ajax")
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        spyOn(serializer, "serializeTypeName").andReturn("person")
        spyOn(serializer, "serializeQueryHash").andReturn("?pageNumber=1&pageSize=10")
        @collection = Emu.PagedModelCollection.create(pageSize: 10, type: App.Person)
        @adapter.findPage(@collection, @store, 1)

      it "should make a GET request", ->        
        expect($.ajax.mostRecentCall.args[0].type).toEqual("GET")
      
      it "should serialize the query hash for", ->
        expect(serializer.serializeQueryHash).toHaveBeenCalledWith(pageNumber: 1, pageSize: 10)

      it "should request to the correct URL", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person?pageNumber=1&pageSize=10")

    describe "finished successfully", ->
      beforeEach ->   
        @store = 
          didFindPage: jasmine.createSpy()
        spyOn($, "ajax")
        @adapter = Emu.RestAdapter.create
          namespace: "api"
          serializer: Serializer
        spyOn(serializer, "serializeTypeName").andReturn("address")
        spyOn(serializer, "serializeQueryHash").andReturn("?pageNumber=1&pageSize=10")
        spyOn(serializer, "serializeKey").andCallFake (key) ->
          if key == "totalRecordCount" then "total_record_count" else "results"
        spyOn(serializer, "deserializeCollection")
        @collection = Emu.PagedModelCollection.create(pageSize: 2, type: App.Address)
        @collection.get("pages")[1] = Emu.ModelCollection.create()
        @adapter.findPage(@collection, @store, 1)
        @jsonData = 
          total_record_count: 2000
          results: [
            {id: 1, town: "London"}
            {id: 2, town: "New York"}
          ]
        $.ajax.mostRecentCall.args[0].success(@jsonData)

      it "should serialize the totalRecordCount key", ->
        expect(serializer.serializeKey).toHaveBeenCalledWith("totalRecordCount")

      it "should serialize the totalRecordCount key", ->
        expect(serializer.serializeKey).toHaveBeenCalledWith("results")

      it "should set the totalRecordCount property on the collection the resultsCount", ->
        expect(@collection.get("totalRecordCount")).toEqual(2000)

      it "should deserialize the collection", ->
        expect(serializer.deserializeCollection).toHaveBeenCalledWith(@collection.get("pages")[1], @jsonData.results)

      it "should notify the store the the page has loaded", ->
        expect(@store.didFindPage).toHaveBeenCalledWith(@collection, 1)