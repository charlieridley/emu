window.TestHelpers = 
	createStore: -> 
		Ember.set(Emu, "defaultStore", undefined)
		Emu.Store.create
			adapter: Emu.RestAdapter.extend
				namespace: "api"