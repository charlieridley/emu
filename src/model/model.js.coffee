Emu.Model = Ember.Object.extend
	getValueOf: (key) ->
		@_attributes?[key]
Emu.proxyToStore = (methodName) ->
	->
		store = Ember.get(Emu, "defaultStore")
		args = [].slice.call(arguments)
		args.unshift(this)
		Ember.assert("Cannot call " + methodName + ". You need define a store first like this: App.Store = Emu.Store.extend()", !!store);
		store[methodName].apply(store, args)
Emu.Model.reopenClass
	createRecord: Emu.proxyToStore("createRecord")
	find: Emu.proxyToStore("find")