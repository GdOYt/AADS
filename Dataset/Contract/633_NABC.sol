contract NABC is StandardToken {
	string public constant name = "NABC";
    string public constant symbol = "NABC";
    uint256 public constant decimals = 18;
    string public version = "1.0";
    address private creator;     
	mapping (address => uint256) private blackmap;
	mapping (address => uint256) private releaseamount;
    modifier onlyCreator() {
    require(msg.sender == creator);
    _;
   }
   function _addressNotNull(address _to) private pure returns (bool) {
    return _to != address(0);
   }
   function addBlackAccount(address _b) public onlyCreator {
    require(_addressNotNull(_b));
    blackmap[_b] = 1;
   }
   function clearBlackAccount(address _b) public onlyCreator {
    require(_addressNotNull(_b));
    blackmap[_b] = 0;
   }
   function checkBlackAccount(address _b) public returns (uint256) {
       require(_addressNotNull(_b));
       return blackmap[_b];
   }
   function setReleaseAmount(address _b, uint256 _a) public onlyCreator {
       require(_addressNotNull(_b));
       require(balances[_b] >= _a);
       releaseamount[_b] = _a;
   }
   function checkReleaseAmount(address _b) public returns (uint256) {
       require(_addressNotNull(_b));
       return releaseamount[_b];
   }
    address account1 = 0xA1eA1e293839e2005a8E47f772B758DaBC0515FB;  
	address account2 = 0xD285bB3f0d0A6271d535Bd37798A452892466De0;  
    uint256 public amount1 = 34* 10000 * 10000 * 10**decimals;
	uint256 public amount2 = 14* 10000 * 10000 * 10**decimals;
    function NABC() {
	    creator = msg.sender;
		totalSupply = amount1 + amount2;
		balances[account1] = amount1;                          
		balances[account2] = amount2;
                balances[msg.sender] = 2 * 10000 * 10000 * 10**decimals;
    }
	function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {	
	    if(blackmap[msg.sender] != 0){
	        if(releaseamount[msg.sender] < _value){
	            return false;
	        }
	        else{
	            releaseamount[msg.sender] -= _value;
	            balances[msg.sender] -= _value;
			    balances[_to] += _value;
			    Transfer(msg.sender, _to, _value);
			    return true;
	        }
		}
		else{
			balances[msg.sender] -= _value;
			balances[_to] += _value;
			Transfer(msg.sender, _to, _value);
			return true;
		}
      } else {
        return false;
      }
    }
}
