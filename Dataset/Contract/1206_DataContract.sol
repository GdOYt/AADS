contract DataContract is owned {
    struct Good {
        bytes32 preset;
        uint price;
        uint decision;
        uint time;
    }
    mapping (bytes32 => Good) public goods;
    function setGood(bytes32 _preset, uint _price,uint _decision) onlyOwnerAndtokenContract external {
        goods[_preset] = Good({preset: _preset, price: _price, decision:_decision, time: now});
    }
    function getGoodPreset(bytes32 _preset) view public returns (bytes32) {
        return goods[_preset].preset;
    }
    function getGoodDecision(bytes32 _preset) view public returns (uint) {
        return goods[_preset].decision;
    }
    function getGoodPrice(bytes32 _preset) view public returns (uint) {
        return goods[_preset].price;
    }
}
