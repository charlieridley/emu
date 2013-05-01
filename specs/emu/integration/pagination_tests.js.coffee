describe "Pagination tests", ->
  
  describe "loading one page", ->
    
    describe "start loading", ->
      beforeEach ->
        TestSetup.setup() 
        spyOn($, "ajax")
        @customers = App.Customer.findPaged(500)

      it "should make a web request to get the first page", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/customer?pageNumber=1&pageSize=500")

      it "should have the first page in a loading state", ->
        expect(@customers.get("pages")[1].get("isLoading")).toBeTruthy()

    describe "finish loading", ->
      beforeEach ->
        TestSetup.setup() 
        spyOn($, "ajax")
        @result = App.Address.findPaged(4)
        $.ajax.mostRecentCall.args[0].success
          totalRecordCount: 2000
          results: [
            {id: 1, town: "London"}
            {id: 2, town: "New York"}
            {id: 3, town: "Paris"}
            {id: 4, town: "Berlin"}
          ]

      it "should have the length as the total loaded records", ->
        expect(@result.get("length")).toEqual(4)

      it "should have the totalRecordCount as 2000", ->
        expect(@result.get("totalRecordCount")).toEqual(2000)

      it "should have 4 items on the page 1 collection", ->
        expect(@result.get("pages")[1].get("length")).toEqual(4)

  describe "loading more in a collection", ->

    beforeEach ->
      TestSetup.setup() 
      spyOn($, "ajax")
      @customers = App.Address.findPaged(3)
      $.ajax.mostRecentCall.args[0].success
        totalRecordCount: 6
        results: [
          {id: 1, town: "London"}
          {id: 2, town: "New York"}
          {id: 3, town: "Paris"}            
        ]
      @customers.loadMore()

    it "should make a web request to get page 2", ->
      expect($.ajax.mostRecentCall.args[0].url).toEqual("api/address?pageNumber=2&pageSize=3")
