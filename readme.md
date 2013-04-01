#Emu [![Build Status](https://secure.travis-ci.org/charlieridley/emu.png?branch=master)](https://travis-ci.org/charlieridley/emu)

Emu is a simple data access framework for [Ember.js](http://www.emberjs.com).

To Start
--------
```javascript
// you need a store
App.Store = Emu.Store.extend();

// lets define some models
App.Company = Emu.Model.extend({
	name: Emu.field("string"),
	address: Emu.field("App.Address", {partial: true}),	
	employees: Emu.field("App.Employee", {collection: true, lazy: true})
});

App.Address = Emu.Model.extend({
	street: Emu.field("string"),
	town: Emu.field("string")
});

App.Employee = Emu.Model.extend({
	name: Emu.field("string")
});
```
Querying
--------
```javascript
var companies = App.Company.find({searchName: "inc", pageNumber: 3, recordCount: 20});
	//GET request to: 	http://www.mysite.com/company?searchName=inc&pageNumber=3&recordCount=20

var companies = App.Company.find(function(company){return company.get("name").indexOf("inc") > 0;});
	//GET request to: 	http://www.mysite.com/company
	//Filters results by function when collection has loaded
```
Partial loading
---------------
```javascript
//Load a bunch of models - each model is "partially" loaded when getting as a collection
var companies = App.Company.find();  
	//GET request to: 	http://www.mysite.com/company
	//Response: [{id: 1, name: "Apple"}, {id: 2, name: "Facebook"}]

//Getting a partial value triggers a full load of the model
companies.get("firstObject.address");
	//GET request to:	http://www.mysite.com/company/1
	//Response: {id: 1, name: "Apple", address: {street:"1 Infinite Loop", town: "Cupertino"}}
```
Lazy loading of collections
------------
```javascript
//Get a lazy collection property
var members = company.get("employees");
	//GET request to:	http://www.mysite.com/company/1/employee
	//Response: [{name: "Tom"}, {name: "Barny"}]
```
Persistence
-----------
```javascript
//Save an existing model
App.store.save(company);
	//PUT request to:	http://www.mysite.com/company/1

//Save a new model
var company = App.Company.createRecord()
App.store.save(company);
	//POST request to:	http://www.mysite.com/company/1
```
