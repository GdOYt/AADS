contract MintableToken is StandardToken {
    address public minter;
    bool public mintingDisabled = false;
    event MintingDisabled();
    modifier canMint() {
        require(!mintingDisabled);
        _;
    }
    modifier onlyMinter() {
        require(msg.sender == minter);
        _;
    }
    constructor(address _minter) internal {
        minter = _minter;
    }
    function mint(address _to, uint256 _value) onlyMinter canMint public {
        totalSupply = totalSupply.plus(_value);
        balances[_to] = balances[_to].plus(_value);
        emit Transfer(0x0, _to, _value);
    }
    function disableMinting() onlyMinter canMint public {
        mintingDisabled = true;
        emit MintingDisabled();
    }
}
