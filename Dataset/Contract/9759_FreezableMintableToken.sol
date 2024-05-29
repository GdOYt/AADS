contract FreezableMintableToken is FreezableToken, MintableToken {
    function mintAndFreeze(address _to, uint _amount, uint64 _until) onlyOwner canMint public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        bytes32 currentKey = toKey(_to, _until);
        freezings[currentKey] = freezings[currentKey].add(_amount);
        freezingBalance[_to] = freezingBalance[_to].add(_amount);
        freeze(_to, _until);
        Mint(_to, _amount);
        Freezed(_to, _until, _amount);
        return true;
    }
}
