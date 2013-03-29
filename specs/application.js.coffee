App = Ember.Application.create()
App.Store = Emu.Store.extend
	adapter: Emu.RestAdapter.extend
		namespace: "api"