contract StarambaToken is StandardToken {
    string public constant name = "STARAMBA.Token";
    string public constant symbol = "STT";
    uint256 public constant decimals = 18;
    string public constant version = "1";
    uint256 public TOKEN_CREATION_CAP = 1000 * (10**6) * 10**decimals; 
    uint256 public constant TOKEN_MIN = 1 * 10**decimals;              
    address public STTadmin1;      
    address public STTadmin2;      
    bool public transactionsActive;
    bool public relocationActive;
    address public newTokenContractAddress;
    uint8 supplyAdjustmentCount = 0;
    mapping (address => bool) public isHolder; 
    address[] public holders;                  
    mapping (address => bytes32) private multiSigHashes;
    mapping (address => bool) public vendors;
    uint8 public vendorCount;
    event LogDeliverSTT(address indexed _to, uint256 _value);
    modifier onlyVendor() {
        require(vendors[msg.sender] == true);
        _;
    }
    modifier isTransferable() {
        require (transactionsActive == true);
        _;
    }
    modifier onlyOwner() {
        require (msg.sender == STTadmin1 || msg.sender == STTadmin2);
        multiSigHashes[msg.sender] = keccak256(msg.data);
        if ((multiSigHashes[STTadmin1]) == (multiSigHashes[STTadmin2])) {
            _;
            multiSigHashes[STTadmin1] = 0x0;
            multiSigHashes[STTadmin2] = 0x0;
        } else {
            return;
        }
    }
    constructor(address _admin1, address _admin2, address[] _vendors)
    public
    {
        require (_admin1 != 0x0);
        require (_admin2 != 0x0);
        require (_admin1 != _admin2);
        require (_vendors.length == 10);
        totalSupply = 0;
        STTadmin1 = _admin1;
        STTadmin2 = _admin2;
        for (uint8 i = 0; i < _vendors.length; i++){
            vendors[_vendors[i]] = true;
            vendorCount++;
        }
    }
    function transfer(address _to, uint256 _value)
    public
    isTransferable 
    returns (bool success)
    {
        bool result = super.transfer(_to, _value);
        if (result) {
            trackHolder(_to); 
        }
        return result;
    }
    function transferFrom(address _from, address _to, uint256 _value)
    public
    isTransferable 
    returns (bool success)
    {
        bool result = super.transferFrom(_from, _to, _value);
        if (result) {
            trackHolder(_to); 
        }
        return result;
    }
    function getBalanceOf(address _owner)
    public
    view
    returns (uint256 _balance)
    {
        return balances[_owner];
    }
    function relocate()
    external 
    {
        require (relocationActive == true);
        RelocationToken newSTT = RelocationToken(newTokenContractAddress);
        uint256 balance = balances[msg.sender];
        balances[msg.sender] = 0;
        require(newSTT.recieveRelocation(msg.sender, balance));
    }
    function getHolderCount()
    public
    view
    returns (uint256 _holderCount)
    {
        return holders.length;
    }
    function getHolder(uint256 _index)
    public
    view
    returns (address _holder)
    {
        return holders[_index];
    }
    function trackHolder(address _to)
    private
    returns (bool success)
    {
        if (isHolder[_to] == false) {
            holders.push(_to);
            isHolder[_to] = true;
        }
        return true;
    }
    function deliverTokens(address _buyer, uint256 _amount)
    external
    onlyVendor
    {
        require(_amount >= TOKEN_MIN);
        uint256 checkedSupply = SafeMath.add(totalSupply, _amount);
        require(checkedSupply <= TOKEN_CREATION_CAP);
        uint256 oldBalance = balances[_buyer];
        balances[_buyer] = SafeMath.add(oldBalance, _amount);
        totalSupply = checkedSupply;
        trackHolder(_buyer);
        emit LogDeliverSTT(_buyer, _amount);
    }
    function deliverTokensBatch(address[] _buyer, uint256[] _amount)
    external
    onlyVendor
    {
        require(_buyer.length == _amount.length);
        for (uint8 i = 0 ; i < _buyer.length; i++) {
            require(_amount[i] >= TOKEN_MIN);
            require(_buyer[i] != 0x0);
            uint256 checkedSupply = SafeMath.add(totalSupply, _amount[i]);
            require(checkedSupply <= TOKEN_CREATION_CAP);
            uint256 oldBalance = balances[_buyer[i]];
            balances[_buyer[i]] = SafeMath.add(oldBalance, _amount[i]);
            totalSupply = checkedSupply;
            trackHolder(_buyer[i]);
            emit LogDeliverSTT(_buyer[i], _amount[i]);
        }
    }
    function transactionSwitch(bool _transactionsActive) 
    external 
    onlyOwner
    {
        transactionsActive = _transactionsActive;
    }
    function relocationSwitch(bool _relocationActive, address _newTokenContractAddress) 
    external 
    onlyOwner
    {
        if (_relocationActive) {
            require(_newTokenContractAddress != 0x0);
        } else {
            require(_newTokenContractAddress == 0x0);
        }
        relocationActive = _relocationActive;
        newTokenContractAddress = _newTokenContractAddress;
    }
    function adjustCap()
    external
    onlyOwner
    {
        require (supplyAdjustmentCount < 4);
        TOKEN_CREATION_CAP = SafeMath.add(TOKEN_CREATION_CAP, 50 * (10**6) * 10**decimals); 
        supplyAdjustmentCount++;
    }
    function burnWholeBalance()
    external
    {
        require(balances[msg.sender] > 0);
        totalSupply = SafeMath.sub(totalSupply, balances[msg.sender]);
        balances[msg.sender] = 0;
    }
}
