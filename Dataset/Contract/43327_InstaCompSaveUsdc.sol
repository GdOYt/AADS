contract InstaCompSaveUsdc is CompoundSave {
    uint public version;
    constructor(uint _version) public {
        version = _version;
    }
    function() external payable {}
}
