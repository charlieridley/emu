describe "Emu.RestAdapter", ->  
  Person = Emu.Model.extend()
  serializer = Ember.Object.create
    serializeTypeName: ->
    deserializeCollection: ->
    deserializeModel: ->
    serializeModel: ->
    serializeQueryHash: ->
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
        models = Emu.ModelCollection.create()
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
    
    describe "collection that has a parent", ->
      beforeEach ->
        spyOn($, "ajax")      
        ParentPerson = Emu.Model.extend()
        parent = ParentPerson.create()
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
        model = Person.create()
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
    
    describe "finishes loading", ->
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
  
  describe "insert", ->
    
    describe "start request", ->
      beforeEach ->
        @store = Ember.Object.create()
        spyOn($, "ajax")
        @jsonData = {name: "Henry"}
        @model = Person.create()
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
  
  describe "update", ->
    
    describe "start request", ->
      beforeEach ->
        @store = Ember.Object.create()
        spyOn($, "ajax")
        @jsonData = {name: "Henry"}
        @model = Person.create(id: 80)
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
        @model = Person.create(id: 6)
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

   