contract Rental is Owned {
    function Rental(address _owner) {
        if (_owner == 0x0) throw;
        owner = _owner;
    }
    function offer(address from, uint num) {
    }
    function claimBalance(address) returns(uint) {
        return 0;
    }
    function exec(address dest) onlyOwner {
        if (!dest.call(msg.data)) throw;
    }
}
