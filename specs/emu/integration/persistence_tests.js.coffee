describe "Saving a new model", ->

  describe "with Emu.Serializer", ->

    describe "empty collection property", ->
      beforeEach ->
        TestSetup.setup()
        spyOn($, "ajax")
        @person = App.Person.createRecord()
        @person.set("name", "dave")
        @person.save()

      it "should save to the correct URL", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/people")

      it "should send a POST request", ->
        expect($.ajax.mostRecentCall.args[0].type).toEqual("POST")

      it "should have the serialized model as the payload", ->
        expect($.ajax.mostRecentCall.args[0].data).toEqual({name: "dave"})

    describe "with lazy collection property", ->
      beforeEach ->
        TestSetup.setup()
        spyOn($, "ajax")
        @customer = App.Customer.createRecord()
        @customer.set("name", "dave")
        @customer.get("orders").pushObject(App.Order.create(orderCode: "1234"))
        @customer.get("orders").pushObject(App.Order.create(orderCode: "5678"))
        @customer.save()

      it "should have the serialized model as the payload, without the lazy collection", ->
        expect($.ajax.mostRecentCall.args[0].data).toEqual
          name: "dave"

    describe "with collection property", ->
      beforeEach ->
        TestSetup.setup()
        spyOn($, "ajax")
        @customer = App.Customer.createRecord()
        @customer.set("name", "dave")
        @customer.get("addresses").pushObject(App.Address.create(town: "London"))
        @customer.get("addresses").pushObject(App.Address.create(town: "New York"))
        @customer.save()

      it "should have the serialized model as the payload, with the collection", ->
        expect($.ajax.mostRecentCall.args[0].data).toEqual
          name: "dave"
          addresses: [
            {town: "London"}
            {town: "New York"}
          ]

describe "Saving a existing model", ->
  beforeEach ->
    TestSetup.setup()
    spyOn($, "ajax")
    @person = App.Person.find(5)
    $.ajax.mostRecentCall.args[0].success({id: 5, name: "Larry"})
    @person.save()

  it "should save to the correct URL", ->
    expect($.ajax.mostRecentCall.args[0].url).toEqual("api/people/5")

  it "should send a PUT request", ->
    expect($.ajax.mostRecentCall.args[0].type).toEqual("PUT")

describe "Saving a model which is in a lazy collection field", ->
  beforeEach ->
    TestSetup.setup()
    spyOn($, "ajax")
    @order = App.Customer.find(5).get("orders").createRecord()
    @order.save()

  it "should save to the correct URL", ->
    expect($.ajax.mostRecentCall.args[0].url).toEqual("api/customers/5/orders")

  it "should send a POST request", ->
    expect($.ajax.mostRecentCall.args[0].type).toEqual("POST")