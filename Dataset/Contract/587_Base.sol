contract Base {
    uint private bitlocks = 0;
    modifier noAnyReentrancy {
        uint _locks = bitlocks;
        require(_locks <= 0);
        bitlocks = uint(-1);
        _;
        bitlocks = _locks;
    }
    modifier only(address allowed) {
        require(msg.sender == allowed);
        _;
    }
    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length == size + 4);
        _;
    } 
}
