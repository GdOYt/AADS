contract Owned {
    address public owner;
    function changeOwner(address _addr) onlyOwner {
        if (_addr == 0x0) throw;
        owner = _addr;
    }
    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }
}
