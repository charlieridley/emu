window.TestHelpers = 
	createStore: -> 
		Emu.Store.create
			adapter: Emu.RestAdapter.extend
				namespace: "api"