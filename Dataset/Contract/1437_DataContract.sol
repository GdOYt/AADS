contract DataContract is owned {
    struct Good {
        bytes32 preset;
        uint price;
        uint time;
    }
    mapping (bytes32 => Good) public goods;
    function setGood(bytes32 _preset, uint _price) onlyOwnerAndtokenContract external {
        goods[_preset] = Good({preset: _preset, price: _price, time: now});
    }
    function getGoodPreset(bytes32 _preset) view public returns (bytes32) {
        return goods[_preset].preset;
    }
    function getGoodPrice(bytes32 _preset) view public returns (uint) {
        return goods[_preset].price;
    }
    mapping (bytes32 => address) public decisionOf;
    function setDecision(bytes32 _preset, address _address) onlyOwnerAndtokenContract external {
        decisionOf[_preset] = _address;
    }
    function getDecision(bytes32 _preset) view public returns (address) {
        return decisionOf[_preset];
    }
}
