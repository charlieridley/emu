(function() {
  window.Emu = Ember.Namespace.create();

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
        }
      });
    },
    insert: function(store, model) {
      var jsonData,
        _this = this;

      jsonData = this._serializer.serializeModel(model);
      return $.ajax({
        url: this._getEndpointForModel(model.constructor),
        data: jsonData,
        type: "POST",
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
    var getAttr, meta, setAttr;

    if (options == null) {
      options = {};
    }
    meta = {
      type: type,
      options: options
    };
    getAttr = function(record, key) {
      var _ref;

      if ((_ref = record._attributes) == null) {
        record._attributes = {};
      }
      return record._attributes[key];
    };
    setAttr = function(record, key, value) {
      var _ref;

      if ((_ref = record._attributes) == null) {
        record._attributes = {};
      }
      return record._attributes[key] = value;
    };
    return Ember.computed(function(key, value, oldValue) {
      var returnVal;

      meta = this.constructor.metaForProperty(key);
      if (arguments.length > 1) {
        setAttr(this, key, value);
      } else {
        if (meta.options.lazy && !getAttr(this, key)) {
          returnVal = Emu.ModelCollection.create({
            type: meta.type,
            store: this._store,
            parent: this
          });
          this._store.loadAll(returnVal);
        } else if (meta.options.partial) {
          this._store.loadModel(this);
        }
      }
      return returnVal || getAttr(this, key);
    }).property("data").meta(meta);
  };

}).call(this);
(function() {
  Emu.Model = Ember.Object.extend({
    getValueOf: function(key) {
      var _ref;

      return (_ref = this._attributes) != null ? _ref[key] : void 0;
    }
  });

}).call(this);
(function() {
  Emu.ModelCollection = Ember.ArrayProxy.extend({
    init: function() {
      return this.set("content", Ember.A([]));
    },
    createRecord: function(hash) {
      var model;

      model = this.get("type").create(hash);
      model._store = this.get("store");
      return this.pushObject(model);
    }
  });

}).call(this);
(function() {
  Emu.AttributeSerializers = {
    string: {
      serialize: function(value) {
        return value;
      },
      deserialize: function(value) {
        return value;
      }
    }
  };

}).call(this);
(function() {
  Emu.Serializer = Ember.Object.extend({
    serializeTypeName: function(type) {
      var parts;

      parts = type.toString().split(".");
      return parts[parts.length - 1].toLowerCase();
    },
    serializeModel: function(model) {
      var jsonData,
        _this = this;

      jsonData = {
        id: model.get("id")
      };
      model.constructor.eachComputedProperty(function(property, meta) {
        return _this._serializeProperty(model, jsonData, property, meta);
      });
      return jsonData;
    },
    deserializeModel: function(model, jsonData) {
      var _this = this;

      if (jsonData.id) {
        model.set("id", jsonData.id);
      }
      model.constructor.eachComputedProperty(function(property, meta) {
        return _this._deserializeProperty(model, property, jsonData[property], meta);
      });
      return model;
    },
    deserializeCollection: function(collection, jsonData) {
      var _this = this;

      return jsonData.forEach(function(item) {
        var model;

        model = collection.createRecord();
        return _this.deserializeModel(model, item);
      });
    },
    _deserializeProperty: function(model, property, value, meta) {
      var attributeSerializer, collection;

      if (meta.options.collection) {
        if (value) {
          collection = Emu.ModelCollection.create({
            type: meta.type,
            store: model._store,
            parent: model
          });
          this.deserializeCollection(collection, value);
          return model.set(property, collection);
        }
      } else {
        attributeSerializer = Emu.AttributeSerializers[meta.type];
        value = attributeSerializer.deserialize(value);
        if (value) {
          return model.set(property, value);
        }
      }
    },
    _serializeProperty: function(model, jsonData, property, meta) {
      var attributeSerializer, collection,
        _this = this;

      if (meta.options.collection) {
        collection = model.get(property);
        return jsonData[property] = collection.map(function(item) {
          return _this.serializeModel(item);
        });
      } else {
        attributeSerializer = Emu.AttributeSerializers[meta.type];
        return jsonData[property] = attributeSerializer.serialize(model.getValueOf(property));
      }
    }
  });

}).call(this);
(function() {
  Emu.Store = Ember.Object.extend({
    init: function() {
      var _ref;

      if (this.get("modelCollections") === void 0) {
        this.set("modelCollections", {});
      }
      return this._adapter = ((_ref = this.get("adapter")) != null ? _ref.create() : void 0) || Emu.RestAdapter.create();
    },
    createRecord: function(type) {
      var collection;

      collection = this._getCollectionForType(type);
      return collection.createRecord({
        isDirty: true
      });
    },
    findAll: function(type) {
      var collection;

      collection = this._getCollectionForType(type);
      this.loadAll(collection);
      return collection;
    },
    loadAll: function(collection) {
      if (collection.get("isLoading") || collection.get("isLoaded")) {
        return collection;
      }
      collection.set("isLoading", true);
      this._adapter.findAll(collection.get("type"), this, collection);
      return collection;
    },
    save: function(model) {
      if (model.get("id")) {
        return this._adapter.update(this, model);
      } else {
        return this._adapter.insert(this, model);
      }
    },
    didFindAll: function(collection, options) {
      collection.set("isLoaded", true);
      collection.set("isLoading", false);
      return collection.get("content").forEach(function(item) {
        return item.set("isLoaded", options != null ? options.fullyLoad : void 0);
      });
    },
    findById: function(type, id) {
      var collection, model;

      collection = this._getCollectionForType(type);
      model = collection.find(function(item) {
        return item.get("id") === id;
      });
      if (!model) {
        model = collection.createRecord({
          id: id
        });
      }
      return this.loadModel(model);
    },
    loadModel: function(model) {
      if (!model.get("isLoading") && !model.get("isLoaded")) {
        model.set("isLoading", true);
        this._adapter.findById(model.constructor, this, model, model.get("id"));
      }
      return model;
    },
    didFindById: function(model) {
      model.set("isLoading", false);
      return model.set("isLoaded", true);
    },
    _getCollectionForType: function(type) {
      return this.get("modelCollections")[type] || (this.get("modelCollections")[type] = Emu.ModelCollection.create({
        type: type,
        store: this
      }));
    }
  });

}).call(this);
