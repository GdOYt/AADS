contract Ownable is IOwnable {
    address internal owner;
    function Ownable() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function getOwner() public view returns (address) {
        return owner;
    }
    function transferOwnership(address _newOwner) public onlyOwner returns (bool) {
        if (_newOwner != address(0)) {
            onTransferOwnership(owner, _newOwner);
            owner = _newOwner;
        }
        return true;
    }
    function onTransferOwnership(address, address) internal returns (bool);
}
