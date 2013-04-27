describe "Lazy loading collection", ->
  
  describe "collection not loaded", ->
    beforeEach ->     
      TestSetup.setup() 
      spyOn($, "ajax")
      @customer = App.Customer.find(15)
      $.ajax.mostRecentCall.args[0].success
        name: "Harry"
      @customer.get("orders")
    
    it "should have made ajax 2 requests", ->
      expect($.ajax.calls.length).toEqual(2)
    
    it "should make an request to the the orders for that customer", ->
      expect($.ajax.mostRecentCall.args[0].url).toEqual("api/customer/15/order")
  
  describe "collection finishes loading", ->
    beforeEach ->   
      TestSetup.setup()   
      spyOn($, "ajax")
      @customer = App.Customer.find(5)
      $.ajax.mostRecentCall.args[0].success
        name: "Harry"
      @orders = @customer.get("orders")
      $.ajax.mostRecentCall.args[0].success [
        {orderCode: "123"}
        {orderCode: "456"}
      ]
    
    it "should have the orders in the returned collection", ->
      expect(@orders.get("length")).toEqual(2)
      expect(@orders.get("firstObject.orderCode")).toEqual("123")
      expect(@orders.get("lastObject.orderCode")).toEqual("456")
    
    it "should have maintained the same collection reference as returned", ->
      expect(@customer.get("orders")).toEqual(@orders)

  describe "loading object and then lazy collection, lazy collection finishes first", ->
    beforeEach ->
      TestSetup.setup()
      spyOn($, "ajax")
      App.Organization.find(1).get("projects")
      $.ajax.mostRecentCall.args[0].success [
        {name: "123"}
        {name: "456"}
      ]

    it "should have made 2 ajax calls", ->
      expect($.ajax.calls.length).toEqual(2)

    it "should have sent a request to get the organization", ->
      expect($.ajax.calls[0].args[0].url).toEqual("api/organization/1")

    it "should have sent a request to get the organization's projects", ->
      expect($.ajax.calls[1].args[0].url).toEqual("api/organization/1/project")

  describe "parent is a new record", ->
    beforeEach ->
      TestSetup.setup()
      spyOn($, "ajax")
      @model = App.Customer.createRecord()
      @model.get("orders")

    it "should not have made an ajax call", ->
      expect($.ajax.calls.length).toEqual(0)
