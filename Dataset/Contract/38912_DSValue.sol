contract DSValue is DSThing {
    bool    has;
    bytes32 val;
    function peek() constant returns (bytes32, bool) {
        return (val,has);
    }
    function read() constant returns (bytes32) {
        var (wut, has) = peek();
        assert(has);
        return wut;
    }
    function poke(bytes32 wut) note auth {
        val = wut;
        has = true;
    }
    function void() note auth {  
        has = false;
    }
}
