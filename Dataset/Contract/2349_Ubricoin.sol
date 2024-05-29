contract Ubricoin is UbricoinPresale,Ownable,Haltable, UbricoinCrowdsale,Upgradeable {
    using SafeMath for uint256;
    string public name ='Ubricoin';
    string public symbol ='UBN';
    string public version= "1.0";
    uint public decimals=18;
    uint public totalSupply = 10000000000;
    uint256 public constant RATE = 1000;
    uint256 initialSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    uint256 public AVAILABLE_AIRDROP_SUPPLY = 100000000;  
    uint256 public grandTotalClaimed = 1;
    uint256 public startTime;
    struct Allocation {
    uint8 AllocationSupply;  
    uint256 totalAllocated;  
    uint256 amountClaimed;   
}
    mapping (address => Allocation) public allocations;
    mapping (address => bool) public airdropAdmins;
    mapping (address => bool) public airdrops;
  modifier onlyOwnerOrAdmin() {
    require(msg.sender == owner || airdropAdmins[msg.sender]);
    _;
}
    event Burn(address indexed from, uint256 value);
        bytes32 public currentChallenge;                          
        uint256 public timeOfLastProof;                              
        uint256 public difficulty = 10**32;                          
    function proofOfWork(uint256 nonce) public{
        bytes8 n = bytes8(keccak256(abi.encodePacked(nonce, currentChallenge)));     
        require(n >= bytes8(difficulty));                    
        uint256 timeSinceLastProof = (now - timeOfLastProof);   
        require(timeSinceLastProof >=  5 seconds);          
        balanceOf[msg.sender] += timeSinceLastProof / 60 seconds;   
        difficulty = difficulty * 10 minutes / timeSinceLastProof + 1;   
        timeOfLastProof = now;                               
        currentChallenge = keccak256(abi.encodePacked(nonce, currentChallenge, blockhash(block.number - 1)));   
    }
   function () payable public whenNotPaused {
        require(msg.value > 0);
        uint256 tokens = msg.value.mul(RATE);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(tokens);
        totalSupply = totalSupply.add(tokens);
        owner.transfer(msg.value);
}
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
     function transfer(address _to, uint256 _value) public {
		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;
	}
   function balanceOf(address tokenOwner) public constant returns (uint256 balance) {
        return balanceOf[tokenOwner];
}
   function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining) {
        return allowance[tokenOwner][spender];
}
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);      
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);    
        balanceOf[msg.sender] -= _value;             
        totalSupply -= _value;                       
        emit Burn(msg.sender, _value);
        return true;
    }
    function mintToken(address target, uint256 mintedAmount)private onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(0, owner, mintedAmount);
        emit Transfer(owner, target, mintedAmount);
    }
    function validPurchase() internal returns (bool) {
    bool lessThanMaxInvestment = msg.value <= 1000 ether;  
    return validPurchase() && lessThanMaxInvestment;
}
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                 
        require(_value <= allowance[_from][msg.sender]);     
        balanceOf[_from] -= _value;                          
        allowance[_from][msg.sender] -= _value;              
        totalSupply -= _value;                               
        emit Burn(_from, _value);
        return true;
    }
  function setAirdropAdmin(address _admin, bool _isAdmin) public onlyOwner {
    airdropAdmins[_admin] = _isAdmin;
  }
  function airdropTokens(address[] _recipient) public onlyOwnerOrAdmin {
    uint airdropped;
    for(uint256 i = 0; i< _recipient.length; i++)
    {
        if (!airdrops[_recipient[i]]) {
          airdrops[_recipient[i]] = true;
          Ubricoin.transfer(_recipient[i], 1 * decimals);
          airdropped = airdropped.add(1 * decimals);
        }
    }
    AVAILABLE_AIRDROP_SUPPLY = AVAILABLE_AIRDROP_SUPPLY.sub(airdropped);
    totalSupply = totalSupply.sub(airdropped);
    grandTotalClaimed = grandTotalClaimed.add(airdropped);
}
}
