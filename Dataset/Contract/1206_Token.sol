contract Token is owned {
    DataContract DC;
    constructor(address _dataContractAddr) public{
        DC = DataContract(_dataContractAddr);
    }
    event Decision(uint decision,bytes32 preset);
    function postGood(bytes32 _preset, uint _price) onlyOwner public {
        require(DC.getGoodPreset(_preset) == "");
        uint _decision = uint(keccak256(keccak256(blockhash(block.number),_preset),now))%(_price);
        DC.setGood(_preset, _price, _decision);
        Decision(_decision, _preset);
    }
}
