(function() {
  window.Emu = Ember.Namespace.create({
    VERSION: "0.1.0"
  });

}).call(this);
(function() {
  var set;

  set = Ember.set;

  Ember.onLoad("Ember.Application", function(Application) {
    if (Application.registerInjection) {
      Application.registerInjection({
        name: "store",
        before: "controllers",
        injection: function(app, stateManager, property) {
          if (!stateManager) {
            return;
          }
          if (property === "Store") {
            return set(stateManager, "store", app[property].create());
          }
        }
      });
      return Application.registerInjection({
        name: "giveStoreToControllers",
        after: ["store", "controllers"],
        injection: function(app, stateManager, property) {
          var controller, controllerName, store;

          if (!stateManager) {
            return;
          }
          if (/^[A-Z].*Controller$/.test(property)) {
            controllerName = property.charAt(0).toLowerCase() + property.substr(1);
            store = stateManager.get("store");
            controller = stateManager.get(controllerName);
            if (!controller) {
              return;
            }
            return controller.set("store", store);
          }
        }
      });
    } else if (Application.initializer) {
      Application.initializer({
        name: "store",
        initialize: function(container, application) {
          application.register("store:main", application.Store);
          return container.lookup("store:main");
        }
      });
      return Application.initializer({
        name: "injectStore",
        initialize: function(container, application) {
          application.inject("controller", "store", "store:main");
          return application.inject("route", "store", "store:main");
        }
      });
    }
  });

}).call(this);
(function() {
  Emu.PushDataAdapter = Ember.Object.extend({
    init: function() {
      var _ref;

      return this._serializer = ((_ref = this.get("serializer")) != null ? _ref.create() : void 0) || Emu.Serializer.create();
    },
    listenForUpdates: function(store, type) {
      return this.registerForUpdates(store, type);
    },
    didUpdate: function(type, store, json) {
      var model, primaryKey;

      primaryKey = Emu.Model.primaryKey(type);
      model = store.findUpdatable(type, json[primaryKey]);
      if (model) {
        return this._serializer.deserializeModel(model, json);
      }
    }
  });

}).call(this);
(function() {
  Emu.RestAdapter = Ember.Object.extend({
    init: function() {
      var _ref;

      return this._serializer = ((_ref = this.get("serializer")) != null ? _ref.create() : void 0) || Emu.Serializer.create();
    },
    findAll: function(type, store, collection) {
      var url,
        _this = this;

      url = collection.get("parent") ? this._getEndpointNestedSubCollection(collection) : this._getEndpointForModel(type);
      return $.ajax({
        url: url,
        type: "GET",
        success: function(jsonData) {
          return _this._didFindAll(store, collection, jsonData);
        }
      });
    },
    findById: function(type, store, model, id) {
      var _this = this;

      return $.ajax({
        url: this._getEndpointForModel(type) + "/" + id,
        type: "GET",
        success: function(jsonData) {
          return _this._didFindById(store, model, jsonData);
        },
        error: function() {
          return _this._didError(store, model);
        }
      });
    },
    findQuery: function(type, store, collection, queryHash) {
      var _this = this;

      return $.ajax({
        url: this._getEndpointForModel(type) + this._serializer.serializeQueryHash(queryHash),
        type: "GET",
        success: function(jsonData) {
          _this._serializer.deserializeCollection(collection, jsonData);
          return store.didFindQuery(collection);
        }
      });
    },
    insert: function(store, model) {
      return this._save(store, model, "POST");
    },
    update: function(store, model) {
      return this._save(store, model, "PUT");
    },
    _save: function(store, model, requestType) {
      var jsonData,
        _this = this;

      jsonData = this._serializer.serializeModel(model);
      return $.ajax({
        url: this._getEndpointForModel(model.constructor),
        data: jsonData,
        type: requestType,
        success: function(jsonData) {
          return _this._didSave(store, model, jsonData);
        }
      });
    },
    _didFindAll: function(store, collection, jsonData) {
      this._serializer.deserializeCollection(collection, jsonData);
      return store.didFindAll(collection);
    },
    _didFindById: function(store, model, jsonData) {
      this._serializer.deserializeModel(model, jsonData);
      return store.didFindById(model);
    },
    _didError: function(store, model) {
      return store.didError(model);
    },
    _didSave: function(store, model, jsonData) {
      this._serializer.deserializeModel(model, jsonData);
      return store.didSave(model);
    },
    _getEndpointNestedSubCollection: function(collection) {
      return this._getBaseUrl() + this._serializer.serializeTypeName(collection.get("parent").constructor) + "/" + collection.get("parent.id") + "/" + this._serializer.serializeTypeName(collection.get("type"));
    },
    _getEndpointForModel: function(type) {
      return this._getBaseUrl() + this._serializer.serializeTypeName(type);
    },
    _getBaseUrl: function() {
      if (this.get("namespace")) {
        return this.get("namespace") + "/";
      } else {
        return "";
      }
    }
  });

}).call(this);
(function() {
  Emu.field = function(type, options) {
    var meta;

    if (options == null) {
      options = {};
    }
    meta = {
      type: function() {
        return Ember.get(type) || type;
      },
      options: options,
      isField: true,
      isModel: function() {
        var _ref;

        return (_ref = Ember.get(type)) != null ? _ref.isEmuModel : void 0;
      }
    };
    return Ember.computed(function(key, value, oldValue) {
      var _ref, _ref1;

      meta = this.constructor.metaForProperty(key);
      if (arguments.length > 1) {
        Emu.Model.setAttr(this, key, value);
        this.set("isDirty", true);
        this.set("hasValue", true);
      } else {
        if (meta.options.lazy) {
          if ((_ref = this.get("store")) != null) {
            _ref.loadAll(Emu.Model.getAttr(this, key));
          }
        } else if (meta.options.partial) {
          if ((_ref1 = this.get("store")) != null) {
            _ref1.loadModel(this);
          }
        } else if (meta.options.defaultValue && !Emu.Model.getAttr(this, key)) {
          Emu.Model.setAttr(this, key, meta.options.defaultValue);
        }
      }
      return Emu.Model.getAttr(this, key);
    }).property().meta(meta);
  };

}).call(this);
(function() {
  Emu.Model = Ember.Object.extend({
    init: function() {
      if (!this.get("store")) {
        this.set("store", Ember.get(Emu, "defaultStore"));
      }
      return this._primaryKey = Emu.Model.primaryKey(this.constructor);
    },
    save: function() {
      return this.get("store").save(this);
    },
    subscribeToUpdates: function() {
      return this.get("store").subscribeToUpdates(this);
    },
    primaryKey: function() {
      return this._primaryKey;
    },
    primaryKeyValue: function(value) {
      if (value) {
        this.set(this.primaryKey(), value);
      }
      return this.get(this.primaryKey());
    }
  });

  Emu.proxyToStore = function(methodName) {
    return function() {
      var args, store;

      store = Ember.get(Emu, "defaultStore");
      args = [].slice.call(arguments);
      args.unshift(this);
      Ember.assert("Cannot call " + methodName + ". You need define a store first like this: App.Store = Emu.Store.extend()", !!store);
      return store[methodName].apply(store, args);
    };
  };

  Emu.Model.reopenClass({
    isEmuModel: true,
    createRecord: Emu.proxyToStore("createRecord"),
    find: Emu.proxyToStore("find"),
    primaryKey: function(type) {
      var primaryKey, primaryKeyCount,
        _this = this;

      primaryKey = "id";
      primaryKeyCount = 0;
      type.eachComputedProperty(function(property, meta) {
        var _ref;

        if ((_ref = meta.options) != null ? _ref.primaryKey : void 0) {
          primaryKey = property;
          return primaryKeyCount++;
        }
      });
      if (primaryKeyCount > 1) {
        throw new Error("Error with " + this + ": You can only mark one field as a primary key");
      }
      return primaryKey;
    },
    eachEmuField: function(callback) {
      return this.eachComputedProperty(function(property, meta) {
        if (meta.isField) {
          return callback(property, meta);
        }
      });
    },
    getAttr: function(record, key) {
      var meta, _ref;

      meta = record.constructor.metaForProperty(key);
      if ((_ref = record._attributes) == null) {
        record._attributes = {};
      }
      if (!record._attributes[key]) {
        if (meta.options.collection) {
          record._attributes[key] = Emu.ModelCollection.create({
            parent: record,
            type: meta.type()
          });
          record._attributes[key].addObserver("isDirty", function() {
            return record.set("isDirty", true);
          });
          if (meta.options.updatable) {
            record._attributes[key].subscribeToUpdates();
          }
        } else if (meta.isModel()) {
          record._attributes[key] = meta.type().create();
        }
      }
      return record._attributes[key];
    },
    setAttr: function(record, key, value) {
      var _ref;

      if ((_ref = record._attributes) == null) {
        record._attributes = {};
      }
      return record._attributes[key] = value;
    }
  });

}).call(this);
(function() {
  Emu.ModelCollection = Ember.ArrayProxy.extend({
    init: function() {
      var _this = this;

      this.set("content", Ember.A([]));
      this.createRecord = function(hash) {
        var model, paramHash, primaryKey;

        primaryKey = Emu.Model.primaryKey(this.get("type"));
        paramHash = {
          store: this.get("store")
        };
        paramHash[primaryKey] = hash != null ? hash.id : void 0;
        model = this.get("type").create(paramHash);
        model.setProperties(hash);
        if (this._subscribeToUpdates) {
          model.subscribeToUpdates();
        }
        return this.pushObject(model);
      };
      this.addObserver("content.@each", function() {
        _this.set("hasValue", true);
        return _this.set("isDirty", true);
      });
      return this.find = function(predicate) {
        return this.get("content").find(predicate);
      };
    },
    subscribeToUpdates: function() {
      return this._subscribeToUpdates = true;
    }
  });

}).call(this);
(function() {
  Emu.AttributeSerializers = {
    string: {
      serialize: function(value) {
        if (Ember.isEmpty(value)) {
          return null;
        } else {
          return value;
        }
      },
      deserialize: function(value) {
        if (Ember.isEmpty(value)) {
          return null;
        } else {
          return value;
        }
      }
    },
    array: {
      serialize: function(value) {
        if (Em.typeOf(value) === 'array') {
          return value;
        } else {
          return null;
        }
      },
      deserialize: function(value) {
        switch (Em.typeOf(value)) {
          case "array":
            return value;
          case "string":
            return value.split(',').map(function(item) {
              return jQuery.trim(item);
            });
          default:
            return null;
        }
      }
    }
  };

}).call(this);
(function() {
  Emu.Serializer = Ember.Object.extend({
    serializeKey: function(key) {
      return key[0].toLowerCase() + key.slice(1);
    },
    deserializeKey: function(key) {
      return key;
    },
    serializeTypeName: function(type) {
      var parts;

      parts = type.toString().split(".");
      return this.serializeKey(parts[parts.length - 1]);
    },
    serializeModel: function(model) {
      var jsonData,
        _this = this;

      jsonData = {};
      jsonData[model.primaryKey()] = model.primaryKeyValue();
      model.constructor.eachEmuField(function(property, meta) {
        return _this._serializeProperty(model, jsonData, property, meta);
      });
      return jsonData;
    },
    deserializeModel: function(model, jsonData) {
      var primaryKeyValue,
        _this = this;

      primaryKeyValue = jsonData[model.primaryKey()];
      if (primaryKeyValue) {
        model.primaryKeyValue(primaryKeyValue);
      }
      model.constructor.eachEmuField(function(property, meta) {
        var serializedProperty;

        serializedProperty = _this.serializeKey(property);
        return _this._deserializeProperty(model, property, jsonData[serializedProperty], meta);
      });
      return model;
    },
    deserializeCollection: function(collection, jsonData) {
      var oldModels,
        _this = this;

      oldModels = collection.toArray();
      collection.clear();
      return jsonData.forEach(function(item) {
        var existingModel, model;

        existingModel = oldModels.find(function(x) {
          return x.primaryKeyValue() === item[x.primaryKey()];
        });
        model = existingModel ? collection.pushObject(existingModel) : collection.createRecord();
        return _this.deserializeModel(model, item);
      });
    },
    serializeQueryHash: function(queryHash) {
      var key, queryString, value;

      queryString = "?";
      for (key in queryHash) {
        value = queryHash[key];
        queryString += this.serializeKey(key) + "=" + value + "&";
      }
      return queryString.slice(0, queryString.length - 1);
    },
    _deserializeProperty: function(model, property, value, meta) {
      var attributeSerializer, modelProperty;

      if (meta.options.collection) {
        if (value) {
          return this.deserializeCollection(Emu.Model.getAttr(model, property), value);
        }
      } else if (meta.isModel()) {
        if (value) {
          modelProperty = Emu.Model.getAttr(model, property);
          return this.deserializeModel(modelProperty, value);
        }
      } else {
        attributeSerializer = Emu.AttributeSerializers[meta.type()];
        value = attributeSerializer.deserialize(value);
        if (value) {
          return model.set(property, value);
        }
      }
    },
    _serializeProperty: function(model, jsonData, property, meta) {
      var attributeSerializer, serializedKey, value,
        _this = this;

      value = Emu.Model.getAttr(model, property);
      serializedKey = this.serializeKey(property);
      if (meta.options.collection) {
        return jsonData[serializedKey] = (value != null ? value.get("hasValue") : void 0) ? value.map(function(item) {
          return _this.serializeModel(item);
        }) : void 0;
      } else if (meta.isModel()) {
        if (value.get("hasValue")) {
          return jsonData[serializedKey] = this.serializeModel(value);
        }
      } else {
        if (value) {
          attributeSerializer = Emu.AttributeSerializers[meta.type()];
          return jsonData[serializedKey] = attributeSerializer.serialize(value);
        }
      }
    }
  });

}).call(this);
(function() {
  Emu.UnderscoreSerializer = Emu.Serializer.extend({
    serializeKey: function(key) {
      return this._super(key).replace(/([A-Z])/g, function(x) {
        return "_" + x.toLowerCase();
      });
    },
    deserializeKey: function(key) {
      return key.replace(/(\_[a-z])/g, function(x) {
        return x.toUpperCase().replace('_', '');
      });
    }
  });

}).call(this);
(function() {
  Emu.Store = Ember.Object.extend({
    init: function() {
      var _ref, _ref1;

      if (!Ember.get(Emu, "defaultStore")) {
        Ember.set(Emu, "defaultStore", this);
      }
      if (!this.get("modelCollections")) {
        this.set("modelCollections", {});
      }
      if (!this.get("queryCollections")) {
        this.set("queryCollections", {});
      }
      if (!this.get("deferredQueries")) {
        this.set("deferredQueries", {});
      }
      if (!this.get("updatableModels")) {
        this.set("updatableModels", {});
      }
      this._adapter = ((_ref = this.get("adapter")) != null ? _ref.create() : void 0) || Emu.RestAdapter.create();
      return this._pushAdapter = (_ref1 = this.get("pushAdapter")) != null ? _ref1.create() : void 0;
    },
    createRecord: function(type) {
      var collection;

      collection = this._getCollectionForType(type);
      return collection.createRecord({
        isDirty: true
      });
    },
    find: function(type, param) {
      if (!param) {
        return this.findAll(type);
      }
      switch (Em.typeOf(param)) {
        case 'string':
        case 'number':
          return this.findById(type, param);
        case 'object':
          return this.findQuery(type, param);
        case 'function':
          return this.findPredicate(type, param);
      }
    },
    findAll: function(type) {
      var collection;

      collection = this._getCollectionForType(type);
      this.loadAll(collection);
      return collection;
    },
    didFindAll: function(collection) {
      var deferredQueries;

      this._didCollectionLoad(collection);
      deferredQueries = this.get("deferredQueries")[collection.type];
      if (deferredQueries) {
        return deferredQueries.forEach(function(deferredQuery) {
          var queryResult;

          queryResult = collection.filter(deferredQuery.predicate);
          return deferredQuery.results.pushObjects(queryResult);
        });
      }
    },
    findById: function(type, id) {
      var collection, model;

      collection = this._getCollectionForType(type);
      model = collection.find(function(item) {
        return item.primaryKeyValue() === id;
      });
      if (!model) {
        model = collection.createRecord({
          id: id
        });
        model.primaryKeyValue(id);
      }
      return this.loadModel(model);
    },
    didFindById: function(model) {
      model.set("isLoading", false);
      model.set("isLoaded", true);
      return model.set("isDirty", false);
    },
    didError: function(model) {
      model.set('isError', true);
      return model.set('isLoading', false);
    },
    findQuery: function(type, queryHash) {
      var collection;

      collection = this._getCollectionForQuery(type, queryHash);
      if (!collection.get("isLoading")) {
        collection.set("isLoading", true);
        this._adapter.findQuery(type, this, collection, queryHash);
      }
      return collection;
    },
    didFindQuery: function(collection) {
      return this._didCollectionLoad(collection);
    },
    findPredicate: function(type, predicate) {
      var allModels, filtered, queries, results;

      allModels = this.findAll(type);
      results = Emu.ModelCollection.create({
        type: type,
        store: this
      });
      if (allModels.get("isLoaded")) {
        filtered = allModels.filter(function(m) {
          return predicate(m);
        });
        results.pushObjects(filtered);
      } else {
        queries = this.get("deferredQueries")[type] || (this.get("deferredQueries")[type] = []);
        queries.pushObject({
          predicate: predicate,
          results: results
        });
      }
      return results;
    },
    save: function(model) {
      if (model.primaryKeyValue()) {
        return this._adapter.update(this, model);
      } else {
        return this._adapter.insert(this, model);
      }
    },
    didSave: function(model) {
      model.set("isDirty", false);
      model.set("isLoaded", true);
      return model.set("isLoading", false);
    },
    loadAll: function(collection) {
      if (collection.get("isLoading") || collection.get("isLoaded")) {
        return collection;
      }
      collection.set("isLoading", true);
      this._adapter.findAll(collection.get("type"), this, collection);
      return collection;
    },
    loadModel: function(model) {
      if (!model.get("isLoading") && !model.get("isLoaded")) {
        model.set("isLoading", true);
        this._adapter.findById(model.constructor, this, model, model.primaryKeyValue());
      }
      return model;
    },
    subscribeToUpdates: function(model) {
      var _base, _name, _ref;

      if (!this._pushAdapter) {
        throw new Error("You need to register a Emu.PushDataAdapter on your store: Emu.Store.create({pushAdapter: App.MyPushAdapter.create()});");
      }
      if (!this.findUpdatable(model.constructor, model.primaryKeyValue())) {
        if ((_ref = (_base = this.get("updatableModels"))[_name = model.constructor]) == null) {
          _base[_name] = [];
        }
        this.get("updatableModels")[model.constructor].pushObject(model);
        return this._pushAdapter.listenForUpdates(this, model.constructor);
      }
    },
    findUpdatable: function(type, id) {
      var _ref;

      return (_ref = this.get("updatableModels")[type]) != null ? _ref.find(function(model) {
        return model.primaryKeyValue() === id;
      }) : void 0;
    },
    _didCollectionLoad: function(collection) {
      collection.set("isLoaded", true);
      return collection.set("isLoading", false);
    },
    _getCollectionForType: function(type) {
      return this.get("modelCollections")[type] || (this.get("modelCollections")[type] = Emu.ModelCollection.create({
        type: type,
        store: this
      }));
    },
    _getCollectionForQuery: function(type, queryHash) {
      var key, queries;

      key = JSON.stringify(queryHash);
      queries = this.get("queryCollections")[type] || (this.get("queryCollections")[type] = {});
      return this.get("queryCollections")[type][key] || (this.get("queryCollections")[type][key] = Emu.ModelCollection.create({
        type: type,
        store: this
      }));
    }
  });

}).call(this);
