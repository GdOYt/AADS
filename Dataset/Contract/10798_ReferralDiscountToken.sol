contract ReferralDiscountToken is StandardToken, Owned {
    mapping(address => address) referrerOf;
    address[] ownersIndex;
    event Referral(address indexed referred, address indexed referrer);
    function referralDiscountPercentage(address _owner) public view returns (uint256 percent) {
        uint256 total = 0;
        if(referrerOf[_owner] != address(0)) {
            total = total.add(10);
        }
        for(uint256 i = 0; i < ownersIndex.length; i++) {
            if(referrerOf[ownersIndex[i]] == _owner) {
                total = total.add(10);
            }
        }
        return total;
    }
    function setReferrer(address _referred, address _referrer) onlyOwner public returns (bool success) {
        require(_referrer != address(0));
        require(_referrer != address(_referred));
        require(referrerOf[_referred] == address(0));
        ownersIndex.push(_referred);
        referrerOf[_referred] = _referrer;
        emit Referral(_referred, _referrer);
        return true;
    }
}
