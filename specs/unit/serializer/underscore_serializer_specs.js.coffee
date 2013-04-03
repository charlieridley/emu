describe "Emu.UnderscoreSerializer", ->
  
  describe "serializeKey", ->
    describe "non caps first character", ->
      beforeEach ->
        @serializer = Emu.UnderscoreSerializer.create()
        @result = @serializer.serializeKey("daddyFellIntoThePond")
      it "should have underscores as seperators", ->
        expect(@result).toEqual "daddy_fell_into_the_pond"
    describe "caps first character", ->
      beforeEach ->
        @serializer = Emu.UnderscoreSerializer.create()
        @result = @serializer.serializeKey("DaddyFellIntoThePond")
      it "should have underscores as seperators", ->
        expect(@result).toEqual "daddy_fell_into_the_pond"
  
  describe "deserializeKey", ->
    beforeEach ->
      @serializer = Emu.UnderscoreSerializer.create()
      @result = @serializer.deserializeKey("daddy_fell_into_the_pond")
    it "should have camel case", ->
      expect(@result).toEqual "daddyFellIntoThePond"

  describe "serializeTypeName", ->
    beforeEach ->     
      @serializer = Emu.UnderscoreSerializer.create()
      @result = @serializer.serializeTypeName(App.ClubTropicana)
    
    it "should serialize the name to underscore seperated", ->
      expect(@result).toEqual("club_tropicana")

  describe "serializeQueryHash", ->
    beforeEach ->
      serializer = Emu.UnderscoreSerializer.create()
      @result = serializer.serializeQueryHash(roastBeef: "yes", moreGravy: "dontmindifido", code: 10)
    it "should serialize the query object to querystring parameters", ->
      expect(@result).toEqual("?roast_beef=yes&more_gravy=dontmindifido&code=10")

  describe "deserializeModel", ->

    describe "simple fields only", ->
      beforeEach ->    
        @jsonData = 
          id: "46"
          drinks_are_free: "yes of course...I mean..why wouldn't they be?"
        @serializer = Emu.UnderscoreSerializer.create()
        @model = App.ClubTropicana.create()
        @serializer.deserializeModel(@model, @jsonData)
      it "should always deserialize the id", ->
        expect(@model.get("id")).toEqual("46")
      it "should set the deserialized value on the drinksAreFree field", ->
        expect(@model.get("drinksAreFree")).toEqual("yes of course...I mean..why wouldn't they be?")

  describe "serializeModel", ->
    
    describe "simple fields", ->
      beforeEach ->
        model = App.ClubTropicana.create
          id: "55"
          drinksAreFree: "No of course they're not free. What do you think this is? I'm trying to run a business here"
        @serializer = Emu.UnderscoreSerializer.create()
        @jsonResult = @serializer.serializeModel(model)
      it "should deserialize the object to json", ->
        expect(@jsonResult).toEqual
          id: "55"
          drinks_are_free: "No of course they're not free. What do you think this is? I'm trying to run a business here"
    
    