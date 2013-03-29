describe "Emu.Model", ->	
	Person = Emu.Model.extend()
	describe "When creating a record", ->
		beforeEach ->
			Ember.set(Emu, "defaultStore", undefined)
			@store = Emu.Store.create()
			spyOn(@store, "createRecord")
			@model = Person.createRecord()
		it "should proxy the call to the store", ->
			expect(@store.createRecord).toHaveBeenCalledWith(Person)
	describe "When finding a record", ->
		beforeEach ->
			Ember.set(Emu, "defaultStore", undefined)
			@store = Emu.Store.create()
			spyOn(@store, "find")
			@model = Person.find(5)
		it "should proxy the call to the store", ->
			expect(@store.find).toHaveBeenCalledWith(Person, 5)
	describe "When finding a record", ->
		beforeEach ->
			Ember.set(Emu, "defaultStore", undefined)
			@store = Emu.Store.create()
			spyOn(@store, "find")
			@model = Person.find(5)
		it "should proxy the call to the store", ->
			expect(@store.find).toHaveBeenCalledWith(Person, 5)
	