describe "Lazy loading collection tests", ->
	describe "When getting a lazy loaded collection which hasn't been loaded", ->
		beforeEach ->			
			store = TestHelpers.createStore()
			spyOn($, "ajax")
			@customer = store.findById(App.Customer, 5)
			$.ajax.mostRecentCall.args[0].success
				name: "Harry"
			@customer.get("orders")
		it "should make an request to the the orders for that customer", ->
			expect($.ajax.mostRecentCall.args[0].url).toEqual("api/customer/5/order")
	describe "When getting a lazy loaded collection and the property finishes loading", ->
		beforeEach ->			
			store = TestHelpers.createStore()
			spyOn($, "ajax")
			customer = store.findById(App.Customer, 5)
			$.ajax.mostRecentCall.args[0].success
				name: "Harry"
			@orders = customer.get("orders")
			$.ajax.mostRecentCall.args[0].success [
				{orderCode: "123"}
				{orderCode: "456"}
			]
		it "should have the orders in the returned collection", ->
			expect(@orders.get("length")).toEqual(2)
			expect(@orders.get("firstObject.orderCode")).toEqual("123")
			expect(@orders.get("lastObject.orderCode")).toEqual("456")
	describe "When loading a lazy collection upfront", ->
		beforeEach ->			
			store = TestHelpers.createStore()
			spyOn($, "ajax")
			customer = store.findById(App.Customer, 5)
			$.ajax.mostRecentCall.args[0].success
				name: "Harry"
				orders: [
					{orderCode: "123"}
					{orderCode: "456"}
				]
			@orders = customer.get("orders")
		it "should have the orders in the returned collection", ->
			expect(@orders.get("length")).toEqual(2)
			expect(@orders.get("firstObject.orderCode")).toEqual("123")
			expect(@orders.get("lastObject.orderCode")).toEqual("456")
		it "should not make an request to the the orders for that customer", ->
			expect($.ajax.mostRecentCall.args[0].url).not.toEqual("api/customer/5/order")