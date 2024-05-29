contract FlyDropTokenMgr is DelayedClaimable {
    using SafeMath for uint256;
    address[] dropTokenAddrs;
    SimpleFlyDropToken currentDropTokenContract;
    function prepare(uint256 _rand,
                     address _from,
                     address _token,
                     uint256 _value) onlyOwner public returns (bool) {
        require(_token != address(0));
        require(_from != address(0));
        require(_rand > 0);
        if (ERC20(_token).allowance(_from, this) < _value) {
            return false;
        }
        if (_rand > dropTokenAddrs.length) {
            SimpleFlyDropToken dropTokenContract = new SimpleFlyDropToken();
            dropTokenAddrs.push(address(dropTokenContract));
            currentDropTokenContract = dropTokenContract;
        } else {
            currentDropTokenContract = SimpleFlyDropToken(dropTokenAddrs[_rand.sub(1)]);
        }
        currentDropTokenContract.setToken(_token);
        return ERC20(_token).transferFrom(_from, currentDropTokenContract, _value);
    }
    function flyDrop(address[] _destAddrs, uint256[] _values) onlyOwner public returns (uint256) {
        require(address(currentDropTokenContract) != address(0));
        return currentDropTokenContract.multiSend(_destAddrs, _values);
    }
}
