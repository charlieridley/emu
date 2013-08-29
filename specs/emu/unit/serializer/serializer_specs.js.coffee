describe "Emu.Serializer", ->
  Person = Emu.Model.extend
    name: Emu.field("string")

  describe "serializeTypeName", ->

    describe "pluralization on", ->

      describe "isSingular false"
        beforeEach ->
          @serializer = Emu.Serializer.create()

        it "should serialize and pluralize the name", ->
          result = @serializer.serializeTypeName(App.ClubTropicana)
          expect(result).toEqual("clubTropicanas")

        it "should serialize the name using a user-defined name", ->
          result = @serializer.serializeTypeName(App.Person)
          expect(result).toEqual("people")

        it "should serialize the name using a user-defined serialization rule if needed", ->
          result = @serializer.serializeTypeName(App.CustomPerson)
          expect(result).toEqual("custom_people")

      describe "isSingular true"
        beforeEach ->
          @serializer = Emu.Serializer.create()

        it "should serialize and pluralize the name", ->
          result = @serializer.serializeTypeName(App.ClubTropicana, true)
          expect(result).toEqual("clubTropicana")

        it "should serialize the name using a user-defined name", ->
          result = @serializer.serializeTypeName(App.Person, true)
          expect(result).toEqual("people")

        it "should serialize the name using a user-defined serialization rule if needed", ->
          result = @serializer.serializeTypeName(App.CustomPerson, true)
          expect(result).toEqual("custom_person")

    describe "pluralization off", ->
      beforeEach ->
        @serializer = Emu.Serializer.create
          pluralization: false

      it "should serialize and not pluralize the name", ->
        result = @serializer.serializeTypeName(App.ClubTropicana)
        expect(result).toEqual("clubTropicana")

      it "should serialize the name using a user-defined name", ->
        result = @serializer.serializeTypeName(App.Person)
        expect(result).toEqual("people")

      it "should serialize the name using a user-defined serialization rule if needed", ->
        result = @serializer.serializeTypeName(App.CustomPerson)
        expect(result).toEqual("custom_people")

  describe "deserializeModel", ->

    describe "simple fields only", ->

      describe "default primaryKey", ->
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

      describe "field with value 0", ->
        beforeEach ->
          @jsonData =
            id: "2"
            orderCode: 0
          @serializer = Emu.Serializer.create()
          @model = App.Order.create()
          @serializer.deserializeModel(@model, @jsonData)

        it "should deserialize the number 0", ->
          expect(@model.get("orderCode")).toBe("0")

      describe "custom primaryKey", ->
        beforeEach ->
          Customer = Emu.Model.extend
            customerId: Emu.field("string", {primaryKey: true})
          @jsonData =
            id: 8
            customerId: "78"
          @serializer = Emu.Serializer.create()
          @model = Customer.create()
          @serializer.deserializeModel(@model, @jsonData)

        it "should have deserialized the id", ->
          expect(@model.get("customerId")).toEqual("78")

        it "should not have deserialized the default id", ->
          expect(@model.get("id")).toBeUndefined()

    describe "collection field", ->
      Customer = Emu.Model.extend
        name: Emu.field("string")
        orders: Emu.field("App.Order", {collection: true})

      describe "has value", ->

        describe "not addative", ->
          beforeEach ->
            @jsonData =
              name: "Donald Duck"
              orders: [
                {id: 1}
                {id: 2}
              ]
            @serializer = Emu.Serializer.create()
            spyOn(@serializer, "deserializeCollection")
            @model = Customer.create()
            @serializer.deserializeModel(@model, @jsonData)

          it "should call deserializeCollection", ->
            expect(@serializer.deserializeCollection).toHaveBeenCalledWith(@model.get("orders"), @jsonData.orders, undefined)

        describe "addative", ->
          beforeEach ->
            @jsonData =
              name: "Donald Duck"
              orders: [
                {id: 1}
                {id: 2}
              ]
            @serializer = Emu.Serializer.create()
            spyOn(@serializer, "deserializeCollection")
            @model = Customer.create()
            @serializer.deserializeModel(@model, @jsonData, true)

          it "should call deserializeCollection", ->
            expect(@serializer.deserializeCollection).toHaveBeenCalledWith(@model.get("orders"), @jsonData.orders, true)

      describe "has no value", ->
        beforeEach ->
          @jsonData =
            name: "Donald Duck"
          @serializer = Emu.Serializer.create()
          spyOn(@serializer, "deserializeCollection")
          @model = Customer.create()
          @serializer.deserializeModel(@model, @jsonData)

        it "should not call deserializeCollection", ->
          expect(@serializer.deserializeCollection).not.toHaveBeenCalled()

    describe "model field", ->

      describe "not addative", ->

        describe "with value", ->
          Customer = Emu.Model.extend
            name: Emu.field("string")
            order: Emu.field("App.Order")
          beforeEach ->
            @jsonData =
              name: "Donald Duck"
              order:
                id: 1
            serializer = Emu.Serializer.create()
            @model = Customer.create()
            serializer.deserializeModel(@model, @jsonData)

          it "should deserialize the nested object property", ->
            expect(@model.get("order.id")).toEqual(1)

          it "should have deserialized the correct type for that property", ->
            expect(@model.get("order").constructor).toBe(App.Order)

          it "should have hasValue true on the model field", ->
            expect(@model.get("order.hasValue")).toBeTruthy()

        describe "with no value", ->
          Customer = Emu.Model.extend
            name: Emu.field("string")
            order: Emu.field("App.Order")
          beforeEach ->
            @jsonData =
              name: "Donald Duck"
            serializer = Emu.Serializer.create()
            @model = Customer.create()
            @model.set("order.orderCode", "1234")
            spyOn(@model.get("order"), "clear").andCallThrough()
            serializer.deserializeModel(@model, @jsonData)

          it "should have cleared the model field", ->
            expect(@model.get("order").clear).toHaveBeenCalled()

          it "should have hasValue false on the return object", ->
            expect(@model.get("order.hasValue")).toBeFalsy()

      describe "addative", ->

        describe "with model field", ->
          Customer = Emu.Model.extend
            name: Emu.field("string")
            order: Emu.field("App.Order")
          beforeEach ->
            @jsonData =
              name: "Donald Duck"
            serializer = Emu.Serializer.create()
            @model = Customer.create()
            @model.set("name", "don duck")
            @model.set("order.orderCode", "1234")
            spyOn(@model.get("order"), "clear").andCallThrough()
            serializer.deserializeModel(@model, @jsonData, true)

          it "should not have cleared the model field", ->
            expect(@model.get("order").clear).not.toHaveBeenCalled()

          it "should not overwrite the model field", ->
            expect(@model.get("order.orderCode")).toEqual("1234")

  describe "deserializeCollection", ->

    describe "collection is empty", ->
      beforeEach ->
        jsonData = [
          {id:1 ,name: "Donald Duck"}
          {id:2 ,name: "Micky Mouse"}
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

    describe "collection has some items loaded", ->

      describe "not addative", ->
        beforeEach ->
          jsonData = [
            {id:1, name: "Donald Duck"}
            {id:2, name: "Micky Mouse"}
            {id:4, name: "Sonic"}
          ]
          @modelCollection = Emu.ModelCollection.create(type: Person)
          @person1 = Person.create(id:1, name: "Mr Duck")
          spyOn(@person1, "primaryKey").andCallThrough()
          spyOn(@person1, "primaryKeyValue").andCallThrough()
          @person2 = Person.create(id:4, name: "Lord Hedgehog")
          @modelCollection.pushObject(@person1)
          @modelCollection.pushObject(Person.create(id:3, name: "eeyore"))
          @modelCollection.pushObject(@person2)
          @modelCollection.pushObject(Person.create(id:5, name: "Road Runner"))
          @serializer = Emu.Serializer.create()
          spyOn(@modelCollection, "createRecord").andCallThrough()
          @serializer.deserializeCollection(@modelCollection, jsonData)

        it "should have used the model.primaryKey", ->
          expect(@person1.primaryKey).toHaveBeenCalled()

        it "should have used the model.primaryKeyValue", ->
          expect(@person1.primaryKeyValue).toHaveBeenCalled()

        it "should populate the model collection with 3 items", ->
          expect(@modelCollection.get("length")).toEqual(3)

        it "should have updated the names of the existing models", ->
          expect(@person1.get("name")).toEqual("Donald Duck")
          expect(@person2.get("name")).toEqual("Sonic")

        it "should have maintained the reference to the existing models", ->
          expect(@modelCollection.find((x) -> x.get("id") == 4)).toBe(@person2)

        it "should have maintained the collection order", ->
          expect(@modelCollection.get("firstObject.id")).toEqual(1)
          expect(@modelCollection.get("lastObject.id")).toEqual(4)

    describe "addative", ->
      beforeEach ->
        jsonData = [
          {id:10, name: "Donald Duck"}
        ]
        @modelCollection = Emu.ModelCollection.create(type: Person)
        @modelCollection.pushObject(Person.create(id:3, name: "eeyore"))
        @modelCollection.pushObject(Person.create(id:5, name: "Road Runner"))
        @serializer = Emu.Serializer.create()
        spyOn(@serializer, "deserializeModel").andCallThrough()
        spyOn(@modelCollection, "createRecord").andCallThrough()
        @serializer.deserializeCollection(@modelCollection, jsonData, true)

      it "should populate the model collection with 3 items", ->
        expect(@modelCollection.get("length")).toEqual(3)

      it "should pass the addative flag to deserializeModel", ->
        expect(@serializer.deserializeModel.mostRecentCall.args[2]).toBeTruthy()


  describe "serializeModel", ->

    describe "simple fields", ->

      describe "default primaryKey", ->
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

      describe "default primaryKey", ->
        Customer = Emu.Model.extend
          customerId: Emu.field("string", {primaryKey: true})
          name: Emu.field("string")
          age: Emu.field("string")
        beforeEach ->
          customer = Customer.create
            id: "8"
            customerId: "55"
            name: "Terry the customer"
            age: "47"
          @serializer = Emu.Serializer.create()
          @jsonResult = @serializer.serializeModel(customer)

        it "should deserialize the object to json", ->
          expect(@jsonResult).toEqual
            customerId: "55"
            name: "Terry the customer"
            age: "47"

      describe "null value", ->
        Customer = Emu.Model.extend
          customerId: Emu.field("string", {primaryKey: true})
          name: Emu.field("string")
          age: Emu.field("string")
        beforeEach ->
          customer = Customer.create
            id: "8"
            customerId: "55"
            name: "Terry the customer"
          @serializer = Emu.Serializer.create()
          @jsonResult = @serializer.serializeModel(customer)

        it "should not include the null value in the serialized object", ->
          expect(@jsonResult).toEqual
            customerId: "55"
            name: "Terry the customer"

      describe "false boolean value", ->
        Job = Emu.Model.extend
          isDone: Emu.field("boolean")
        beforeEach ->
          job = Job.create
            id: "8"
            isDone: false
          @serializer = Emu.Serializer.create()
          @jsonResult = @serializer.serializeModel(job)

        it "should serialize the boolean value", ->
          expect(@jsonResult).toEqual
            id: "8"
            isDone: false

    describe "nested collection", ->

      describe "not null value", ->
        Customer = Emu.Model.extend
          name: Emu.field("string")
          orders: Emu.field("App.Order", {collection: true})
        beforeEach ->
          @customer = Customer.create
            name: "Terry the customer"
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

      describe "lazy collection", ->
        Customer = Emu.Model.extend
          name: Emu.field("string")
          orders:  Emu.field("App.Order", {collection: true, lazy: true})
        beforeEach ->
          orders = Emu.ModelCollection.create
            type: App.Order
          @customer = Customer.create
            id: 6
            name: "Terry the customer"
            orders: orders
          orders.pushObject(App.Order.create(orderCode: "123"))
          orders.pushObject(App.Order.create(orderCode: "456"))
          spyOn(Emu.Model, "getAttr").andCallThrough()
          @serializer = Emu.Serializer.create()
          @jsonResult = @serializer.serializeModel(@customer)

        it "should not deserialize the lazy property", ->
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

  describe "serializeKey", ->
    describe "non caps first character", ->
      beforeEach ->
        @serializer = Emu.Serializer.create()
        @result = @serializer.serializeKey("daddyFellIntoThePond")

      it "have the same result", ->
        expect(@result).toEqual "daddyFellIntoThePond"

    describe "caps first character", ->
      beforeEach ->
        @serializer = Emu.Serializer.create()
        @result = @serializer.serializeKey("DaddyFellIntoThePond")

      it "have lowercase the first letter", ->
        expect(@result).toEqual "daddyFellIntoThePond"

  describe "deserializeKey", ->
    beforeEach ->
      @serializer = Emu.Serializer.create()
      @result = @serializer.deserializeKey("daddyFellIntoThePond")

    it "have the same result", ->
      expect(@result).toEqual "daddyFellIntoThePond"
