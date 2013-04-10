describe "Emu.AttributeSerializers", ->

  describe "string", ->
    
    describe "serialize", ->
      
      describe "has value", ->
        beforeEach ->
          @result = Emu.AttributeSerializers["string"].serialize("hello")
        it "should be the same as the input", ->
          expect(@result).toEqual("hello")

      describe "empty value", ->
        beforeEach ->
          @result = Emu.AttributeSerializers["string"].serialize(undefined)
        it "should be null", ->
          expect(@result).toBeNull()

    describe "deserialize", ->

      describe "has value", ->
        beforeEach ->
          @result = Emu.AttributeSerializers["string"].deserialize("hello")
        it "should be the same as the input", ->
          expect(@result).toEqual("hello")
    
      describe "empty value", ->
        beforeEach ->
          @result = Emu.AttributeSerializers["string"].deserialize(undefined)
        it "should be null", ->
          expect(@result).toBeNull()
  
  describe "array", ->

    describe "serializing", ->

      describe "has value", -> 
        beforeEach ->
          @result = Emu.AttributeSerializers["array"].serialize([1,2,3,4])
        it "should be the same as the input", ->
          expect(@result).toEqual([1,2,3,4])
      
      describe "empty value", ->
        beforeEach ->
          @result = Emu.AttributeSerializers["array"].serialize(undefined)
        it "should be null", ->
          expect(@result).toBeNull()
  
      describe "string input", ->
        beforeEach ->
          @result = Emu.AttributeSerializers["array"].serialize("hello world")
        it "should be null", ->
          expect(@result).toBeNull()
  
    describe "deserializing", ->
      
      describe "has value", ->
        beforeEach ->
          @result = Emu.AttributeSerializers["array"].deserialize([1,2,3,4])
        it "should be the same as the input", ->
          expect(@result).toEqual([1,2,3,4])
    
      describe "string input", ->
        beforeEach ->
          @result = Emu.AttributeSerializers["array"].deserialize("1,2,3,4")
        it "should be a deserialized array", ->
          expect(@result).toEqual(["1","2","3","4"])
    
      describe "different type", ->
        beforeEach ->
          @result = Emu.AttributeSerializers["array"].deserialize(46)
        it "should be null", ->
          expect(@result).toBeNull()

  describe "boolean", ->

    describe "serialize", ->
      
      describe "has value", ->
        beforeEach ->
          @result = Emu.AttributeSerializers["boolean"].serialize(true)
        it "should be the same as the input", ->
          expect(@result).toEqual(true)

      describe "empty value", ->
        beforeEach ->
          @result = Emu.AttributeSerializers["boolean"].serialize(undefined)
        it "should be null", ->
          expect(@result).toBeNull()

    describe "deserialize", ->

      describe "has value", ->
        beforeEach ->
          @result = Emu.AttributeSerializers["boolean"].deserialize(true)
        it "should be the same as the input", ->
          expect(@result).toEqual(true)
    
      describe "empty value", ->
        beforeEach ->
          @result = Emu.AttributeSerializers["boolean"].deserialize(undefined)
        it "should be null", ->
          expect(@result).toBeNull()
