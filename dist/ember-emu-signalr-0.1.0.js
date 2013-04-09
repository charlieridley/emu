(function() {
  Emu.SignalrPushDataAdapter = Emu.PushDataAdapter.extend({
    registerForUpdates: function(store, type) {
      var hub, modelKey, _ref, _ref1,
        _this = this;

      modelKey = this._serializer.serializeTypeName(type);
      if (hub = (_ref = $.connection) != null ? _ref[modelKey + "Hub"] : void 0) {
        return (_ref1 = hub.updated) != null ? _ref1 : hub.updated = function(json) {
          return _this.didUpdate(type, store, json);
        };
      }
    },
    start: function() {
      return $.connection.start();
    }
  });

}).call(this);
