describe "Pagination tests", ->
  
  describe "loading one page", ->
    
    describe "start loading", ->
      beforeEach ->
        TestSetup.setup() 
        spyOn($, "ajax")
        @customers = App.Customer.findPaged(500)

      it "should make a web request to get the first page", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/customer?pageNumber=1&pageSize=500")

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
        expect(@result.get("length")).toEqual(4)

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

  describe "paged property", ->

    describe "getting once", ->
      beforeEach ->
        TestSetup.setup() 
        spyOn($, "ajax")
        @report = App.Report.find(5)
        $.ajax.mostRecentCall.args[0].success
          id: 5
          title: "test report"
        @report.get("records")

      it "should make a web request to get page 1 of the records", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/report/5/reportRecord?pageNumber=1&pageSize=250")

    describe "getting and loading more", ->
      beforeEach ->
        TestSetup.setup() 
        spyOn($, "ajax")
        @report = App.Report.find(5)
        $.ajax.mostRecentCall.args[0].success
          id: 5
          title: "test report"
        @report.get("records").loadMore()

      it "should make a web request to get page 2 of the records", ->
        expect($.ajax.mostRecentCall.args[0].url).toEqual("api/report/5/reportRecord?pageNumber=2&pageSize=250")

