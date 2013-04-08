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
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person")
      it "should send a POST request", ->
        expect($.ajax.mostRecentCall.args[0].type).toEqual("POST")  
      it "should have the serialized model as the payload", ->
        expect($.ajax.mostRecentCall.args[0].data).toEqual({name: "dave"})

    describe "with collection property", ->
      beforeEach ->
        TestSetup.setup()
        spyOn($, "ajax")
        @customer = App.Customer.createRecord()
        @customer.set("name", "dave")
        @customer.get("orders").pushObject(App.Order.create(orderCode: "1234"))
        @customer.get("orders").pushObject(App.Order.create(orderCode: "5678"))
        @customer.save()
      it "should have the serialized model as the payload", ->
        expect($.ajax.mostRecentCall.args[0].data).toEqual
          name: "dave"
          orders: [
            {orderCode: "1234"}
            {orderCode: "5678"}
          ]

describe "Saving a existing model", ->
  beforeEach ->
    TestSetup.setup() 
    spyOn($, "ajax")
    @person = App.Person.find(5)
    $.ajax.mostRecentCall.args[0].success({id: 5, name: "Larry"})
    @person.save()
  it "should save to the correct URL", ->
    expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person")
  it "should send a PUT request", ->
    expect($.ajax.mostRecentCall.args[0].type).toEqual("PUT")