Emu
===

Emu is a simple data access framework for Ember.js.

To Start
--------

	// you need a store
	App.store = Emu.Store.create();

	// lets define some models
	App.Person = Emu.Model.extend({
		name: Emu.field("string")		
	});

	App.Club = Emu.Model.extend({
		name: Emu.field("string"),
		location: Emu.field("string", {partial: true}),
		boardMembers: Emu.field(App.Person, {collection: true, partial: true}),
		members: Emu.field(App.Person, {collection: true, lazy: true})
	});

Partial Loading
---------------
	
	//Load a bunch of models - each model is "partially" loaded on getAll
	var clubs = App.store.getAll(App.Club);  
		//GET request to: 	http://www.megaclubs.crazy/club
		//Response: [{id: 1, name: "Computer club"}]

	//Getting a partial value triggers a full load of the model
	clubs.get("firstObject.location");
		//GET request to:	http://www.megaclubs.crazy/club/1
		//Response: {id: 1, name: "Computer club", location: "New York", boardMembers: [{name: "Bernard"}, {name: "Cuthbert"}]}

Lazy Loading
------------
	
	//Get a lazy property
	var members = club.get("members");
		//GET request to:	http://www.megaclubs.crazy/club/1/members
		//Response: [{name: "Tom"}, {name: "Barny"}]

Persistence
-----------
	
	//Save an existing model
	App.store.save(club);
		//PUT request to:	http://www.megaclubs.crazy/club/1

	//Save a new model
	var club = App.store.createRecord(App.Club)
	App.store.save(club);
		//POST request to:	http://www.megaclubs.crazy/club/1
