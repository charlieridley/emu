# Breaking Changes

Revision 1
----------
The underscore serializer pluralized type names by default, and the base serialize did not. The default behaviour of the base serializer is to now pluralize type names. This can be reverted back like this:

```javascript
App.Store = Emu.Store.extend({
  adapter: Emu.RestAdapter.extend({
    serializer: Emu.Serializer.extend({
      pluralization: false
    })
  })
})
```

See [https://github.com/charlieridley/emu/blob/master/readme.md](https://github.com/charlieridley/emu/blob/master/readme.md) for more details.
