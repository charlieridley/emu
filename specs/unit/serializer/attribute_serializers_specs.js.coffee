describe "Emu.AttributeSerializers", ->
  describe "When serializing a string", ->
    beforeEach ->
      @result = Emu.AttributeSerializers["string"].serialize("hello")
    it "should be the same as the input", ->
      expect(@result).toEqual("hello")
  describe "When serializing an empty value as a string", ->
    beforeEach ->
      @result = Emu.AttributeSerializers["string"].serialize(undefined)
    it "should be null", ->
      expect(@result).toBeNull()
  describe "When deserializing a string", ->
    beforeEach ->
      @result = Emu.AttributeSerializers["string"].deserialize("hello")
    it "should be the same as the input", ->
      expect(@result).toEqual("hello")
  describe "When deserializing an empty value as a string", ->
    beforeEach ->
      @result = Emu.AttributeSerializers["string"].deserialize(undefined)
    it "should be null", ->
      expect(@result).toBeNull()
  describe "When serializing an array", ->
    beforeEach ->
      @result = Emu.AttributeSerializers["array"].serialize([1,2,3,4])
    it "should be the same as the input", ->
      expect(@result).toEqual([1,2,3,4])
  describe "When serializing an empty value as an array", ->
    beforeEach ->
      @result = Emu.AttributeSerializers["array"].serialize(undefined)
    it "should be null", ->
      expect(@result).toBeNull()
  describe "When serializing a string as an array", ->
    beforeEach ->
      @result = Emu.AttributeSerializers["array"].serialize("hello world")
    it "should be null", ->
      expect(@result).toBeNull()
  describe "When deserializing an array", ->
    beforeEach ->
      @result = Emu.AttributeSerializers["array"].deserialize([1,2,3,4])
    it "should be the same as the input", ->
      expect(@result).toEqual([1,2,3,4])
  describe "When deserializing a string as an array", ->
    beforeEach ->
      @result = Emu.AttributeSerializers["array"].deserialize("1,2,3,4")
    it "should be a deserialized array", ->
      expect(@result).toEqual(["1","2","3","4"])
  describe "When deserializing a different type as an array", ->
    beforeEach ->
      @result = Emu.AttributeSerializers["array"].deserialize(46)
    it "should be null", ->
      expect(@result).toBeNull()