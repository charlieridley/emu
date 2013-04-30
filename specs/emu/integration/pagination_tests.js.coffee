describe "Pagination tests", ->
  
  describe "loading one page", ->
    
    describe "start loading", ->
      beforeEach ->
        TestSetup.setup() 
        spyOn($, "ajax")
        @customers = App.Customer.findPage(2, 500)

      it "should make a web request to get the page", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/customer?pageNumber=2&pageSize=500")

      it "should have the first page in a loading state", ->
        expect(@customers.get("pages")[2].get("isLoading")).toBeTruthy()

    describe "finish loading", ->
      beforeEach ->
        TestSetup.setup() 
        spyOn($, "ajax")
        @result = App.Address.findPage(2, 4)
        $.ajax.mostRecentCall.args[0].success
          totalRecordCount: 2000
          results: [
            {id: 1, town: "London"}
            {id: 2, town: "New York"}
            {id: 3, town: "Paris"}
            {id: 4, town: "Berlin"}
          ]

      it "should have the length as the total record count", ->
        expect(@result.get("length")).toEqual(2000)

      it "should have 4 items on the page 2 collection", ->
        expect(@result.get("pages")[2].get("length")).toEqual(4)

  describe "iterating a collection", ->

    beforeEach ->
      TestSetup.setup() 
      spyOn($, "ajax")
      @customers = App.Address.findPage(1, 3)
      $.ajax.mostRecentCall.args[0].success
        totalRecordCount: 6
        results: [
          {id: 1, town: "London"}
          {id: 2, town: "New York"}
          {id: 3, town: "Paris"}            
        ]
      @customers.forEach (item) ->

    it "should make a web request to get page 2", ->
      expect($.ajax.mostRecentCall.args[0].url).toEqual("api/address?pageNumber=2&pageSize=3")
