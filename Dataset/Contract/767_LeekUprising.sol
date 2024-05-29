contract LeekUprising is LockableToken {
    event Burn(address indexed _burner, uint256 _value);
    string  public  constant name = "LeekUprising";
    string  public  constant symbol = "LUP";
    uint8   public  constant decimals = 6;
    constructor() public {
        totalSupply = 10**15;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0x0), msg.sender, totalSupply);   
    }
    function transferAndLock(address _to, uint256 _value, uint256 _releaseTimeS) public returns (bool) {
        setLock(_to,_value,_releaseTimeS);
        transfer(_to, _value);
        return true;
    }
    function transferMulti(address[] adds, uint256 value) public{
        for(uint256 i=0; i<adds.length; i++){
            transfer(adds[i], value);
        }
    }
}
