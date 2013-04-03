describe "Emu.Serializer", -> 
  Person = Emu.Model.extend
    name: Emu.field("string")

  describe "serializeTypeName", ->
    beforeEach ->     
      @serializer = Emu.Serializer.create()
      @result = @serializer.serializeTypeName(App.Person)
    it "should serialize the name to lower case", ->
      expect(@result).toEqual("person")

  describe "deserializeModel", ->

    describe "simple fields only", ->
      beforeEach -> 
        spyOn(Emu.AttributeSerializers.string, "deserialize").andReturn("WINSTON CHURCHILL")      
        @jsonData = 
          id: "78"
          name: "Winston Churchill"
          age: "60"
        @serializer = Emu.Serializer.create()
        @model = Person.create()
        @serializer.deserializeModel(@model, @jsonData)
      it "should get the deserialized value from the attribute serializer for type string", ->
        expect(Emu.AttributeSerializers.string.deserialize).toHaveBeenCalledWith("Winston Churchill")
      it "should always deserialize the id", ->
        expect(@model.get("id")).toEqual("78")
      it "should set the deserialized value on the name field", ->
        expect(@model.get("name")).toEqual("WINSTON CHURCHILL")
      it "should not deserialize the field which isn't defined in the model", ->
        expect(@model.get("age")).toBeUndefined()

    describe "collection field", ->
      Customer = Emu.Model.extend
        name: Emu.field("string")
        orders: Emu.field("App.Order", {collection: true})        
      beforeEach ->     
        @jsonData = 
          name: "Donald Duck"
          orders: [
            {id: 1}
            {id: 2}
          ]     
        @store = Ember.Object.create()
        @serializer = Emu.Serializer.create()
        spyOn(@serializer, "deserializeCollection")      
        @model = Customer.create()
        @serializer.deserializeModel(@model, @jsonData)      
      it "should call deserializeCollection", ->
        expect(@serializer.deserializeCollection).toHaveBeenCalledWith(@model.get("orders"), @jsonData.orders)      

    describe "model field", ->
      Customer = Emu.Model.extend
        name: Emu.field("string")
        order: Emu.field("App.Order") 
      beforeEach ->
        @jsonData = 
          name: "Donald Duck"
          order: 
            id: 1
        @store = Ember.Object.create()
        serializer = Emu.Serializer.create()
        @model = Customer.create()
        serializer.deserializeModel(@model, @jsonData)
      it "should deserialize the nested object property", ->
        expect(@model.get("order.id")).toEqual(1)
      it "should have deserialized the correct type for that property", ->
        expect(@model.get("order").constructor).toBe(App.Order)

    describe "model field with no value", ->
      Customer = Emu.Model.extend
        name: Emu.field("string")
        order: Emu.field("App.Order") 
      beforeEach ->
        @jsonData = 
          name: "Donald Duck"
        @store = Ember.Object.create()
        serializer = Emu.Serializer.create()
        @model = Customer.create()
        serializer.deserializeModel(@model, @jsonData)
      it "should have a null value for the object", ->
        expect(@model.get("order")).toBeFalsy()

  describe "deserializeCollection", ->
    beforeEach ->
      jsonData = [
        {name: "Donald Duck"}
        {name: "Micky Mouse"}
      ]
      @modelCollection = Emu.ModelCollection.create(type: Person)
      @serializer = Emu.Serializer.create()
      spyOn(@serializer, "deserializeModel").andCallThrough()
      spyOn(@modelCollection, "createRecord").andCallThrough()
      @serializer.deserializeCollection(@modelCollection, jsonData)
    it "should populate the model collection with 2 items", ->
      expect(@modelCollection.get("length")).toEqual(2)
    it "should create 2 models", ->
      expect(@modelCollection.createRecord.calls.length).toEqual(2)
    it "should deserialize 2 items", ->
      expect(@serializer.deserializeModel.calls.length).toEqual(2)  

  describe "serializeModel", ->
    describe "simple fields", ->
      Customer = Emu.Model.extend
        name: Emu.field("string")
        age: Emu.field("string")      
      beforeEach ->
        customer = Customer.create
          id: "55"
          name: "Terry the customer"
          age: "47"
        @serializer = Emu.Serializer.create()
        @jsonResult = @serializer.serializeModel(customer)
      it "should deserialize the object to json", ->
        expect(@jsonResult).toEqual
          id: "55"
          name: "Terry the customer"
          age: "47"

    describe "nested collection", ->
      describe "not null value", ->
        Customer = Emu.Model.extend
          name: Emu.field("string")
          orders: Emu.field("App.Order", {collection: true})            
        beforeEach ->
          @customer = Customer.create
            name: "Terry the customer"        
            orders: Emu.ModelCollection.create(type: App.Order)
          @customer.get("orders").pushObject(App.Order.create(orderCode: "123"))
          @customer.get("orders").pushObject(App.Order.create(orderCode: "456"))
          spyOn(Emu.Model, "getAttr").andCallThrough()
          @serializer = Emu.Serializer.create()
          @jsonResult = @serializer.serializeModel(@customer)
        it "should deserialize the object to json", ->
          expect(@jsonResult).toEqual
            name: "Terry the customer"        
            orders: [
              {orderCode: "123"}
              {orderCode: "456"}
            ] 
        it "should have called the Emu.Model.getAttr for the property, to stop it lazy loading", ->
          expect(Emu.Model.getAttr).toHaveBeenCalledWith(@customer, "orders")
      
      describe "null value", ->
        Customer = Emu.Model.extend
          name: Emu.field("string")
          orders: Emu.field("App.Order", {collection: true})            
        beforeEach ->
          @customer = Customer.create
            id: 6
            name: "Terry the customer"                    
          @serializer = Emu.Serializer.create()
          @jsonResult = @serializer.serializeModel(@customer)
        it "should deserialize the object to json without the collection value", ->
          expect(@jsonResult).toEqual
            id: 6
            name: "Terry the customer"            

    describe "computed property", ->
      Customer = Emu.Model.extend
        name: Emu.field("string")
        town: Emu.field("string")
        description: (->
          @get("name") + " from " +@get("town")
        ).property("name", "town")
      beforeEach ->
        @customer = Customer.create
          name: "Terry the customer"        
          town: "Swindon"
        @serializer = Emu.Serializer.create()
        @jsonResult = @serializer.serializeModel(@customer)
      it "should not deserialize the computed property", ->
        expect(@jsonResult).toEqual
          name: "Terry the customer"        
          town: "Swindon"

    describe "nested model", ->
      Customer = Emu.Model.extend
        name: Emu.field("string")
        order: Emu.field("App.Order") 
      beforeEach ->
        @customer = Customer.create
          name: "Gladys the difficult customer"
        @customer.set("order", App.Order.create(orderCode: "1234"))
        @serializer = Emu.Serializer.create()
        @jsonResult = @serializer.serializeModel(@customer)
      it "should deserialize the object to json", ->
        expect(@jsonResult).toEqual
          name: "Gladys the difficult customer"       
          order: {orderCode: "1234"}  

    describe "nested model which there is no value for", ->
      Customer = Emu.Model.extend
        name: Emu.field("string")
        order: Emu.field("App.Order") 
      beforeEach ->
        @customer = Customer.create
          name: "Gladys the difficult customer"
        @serializer = Emu.Serializer.create()
        @jsonResult = @serializer.serializeModel(@customer)   
      it "should deserialize the object to json", ->
        expect(@jsonResult).toEqual
          name: "Gladys the difficult customer" 

  describe "serializeQueryHash", ->
    beforeEach ->
      serializer = Emu.Serializer.create()
      @result = serializer.serializeQueryHash(foo: "bar", bar: "foo", colour: "green", code: 10)
    it "should serialize the query object to querystring parameters", ->
      expect(@result).toEqual("?foo=bar&bar=foo&colour=green&code=10")