App.Person = Emu.Model.extend
	_fields:
		name: Emu.field()
App.Order = Emu.Model.extend
	_fields:
		orderCode: Emu.field()
App.Customer = Emu.Model.extend
	_fields:
		name: Emu.field()
		orders: Emu.collection(App.Order).lazy()
		town: Emu.field().partial()