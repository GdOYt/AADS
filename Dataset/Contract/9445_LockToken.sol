contract LockToken is BaseToken {
    struct LockMeta {
        uint256 remain;
        uint256 endtime;
    }
    mapping (address => LockMeta[]) public lockedAddresses;
    function _transfer(address _from, address _to, uint _value) internal {
        require(balanceOf[_from] >= _value);
        uint256 remain = balanceOf[_from].sub(_value);
        uint256 length = lockedAddresses[_from].length;
        for (uint256 i = 0; i < length; i++) {
            LockMeta storage meta = lockedAddresses[_from][i];
            if(block.timestamp < meta.endtime && remain < meta.remain){
                revert();
            }
        }
        super._transfer(_from, _to, _value);
    }
}
