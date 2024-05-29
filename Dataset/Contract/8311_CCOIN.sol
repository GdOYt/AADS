contract CCOIN is ERC20, Ownable {
    struct Escrow {
        address creator;
        address brand;
        address agreementContract;
        uint256 reward;
    }
    string public constant name = "CCOIN";
    string public constant symbol = "CCOIN";
    uint public constant decimals = 18;
    uint public totalSupply = 1000000000 * 10 ** 18;
    bool public locked;
    address public multisigETH;  
    address public crowdSaleaddress;  
    uint public ethReceived;  
    uint public totalTokensSent;  
    uint public startBlock;  
    uint public endBlock;  
    uint public maxCap;  
    uint public minCap;  
    uint public minContributionETH;  
    uint public tokenPriceWei;
    uint firstPeriod;
    uint secondPeriod;
    uint thirdPeriod;
    uint fourthPeriod;
    uint fifthPeriod;
    uint firstBonus;
    uint secondBonus;
    uint thirdBonus;
    uint fourthBonus;
    uint fifthBonus;
    uint public multiplier;
    bool public stopInEmergency = false;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => Escrow) escrowAgreements;
    mapping(address => bool) public whitelisted;
    event Whitelist(address indexed participant);
    event Locked();
    event Unlocked();
    event StoppedCrowdsale();
    event RestartedCrowdsale();
    event Burned(uint256 value);
    modifier onlyUnlocked() {
        if (msg.sender != crowdSaleaddress && locked && msg.sender != owner)
            revert();
        _;
    }
    modifier onlyPayloadSize(uint numWords){
        assert(msg.data.length >= numWords * 32 + 4);
        _;
    }
    modifier onlyAuthorized() {
        if (msg.sender != crowdSaleaddress && msg.sender != owner)
            revert();
        _;
    }
    constructor() public {
        locked = true;
        multiplier = 10 ** 18;
        multisigETH = msg.sender;
        minContributionETH = 1;
        startBlock = 0;
        endBlock = 0;
        maxCap = 1000 * multiplier;
        tokenPriceWei = SafeMath.div(1, 1400);
        minCap = 100 * multiplier;
        totalTokensSent = 0;
        firstPeriod = 100;
        secondPeriod = 200;
        thirdPeriod = 300;
        fourthPeriod = 400;
        fifthPeriod = 500;
        firstBonus = 120;
        secondBonus = 115;
        thirdBonus = 110;
        fourthBonus = SafeMath.div(1075, 10);
        fifthBonus = 105;
        balances[multisigETH] = totalSupply;
    }
    function resetCrowdSaleaddress(address _newCrowdSaleaddress) public onlyAuthorized() {
        crowdSaleaddress = _newCrowdSaleaddress;
    }
    function unlock() public onlyAuthorized {
        locked = false;
        emit Unlocked();
    }
    function lock() public onlyAuthorized {
        locked = true;
        emit Locked();
    }
    function burn(address _member, uint256 _value) public onlyAuthorized returns (bool) {
        balances[_member] = SafeMath.sub(balances[_member], _value);
        totalSupply = SafeMath.sub(totalSupply, _value);
        emit Transfer(_member, 0x0, _value);
        emit Burned(_value);
        return true;
    }
    function Airdrop(address _to, uint256 _tokens) external onlyAuthorized returns(bool) {
        require(transfer(_to, _tokens));
    } 
    function transfer(address _to, uint _value) public onlyUnlocked returns (bool) {
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public onlyUnlocked returns (bool success) {
        if (balances[_from] < _value)
            revert();
        if (_value > allowed[_from][msg.sender])
            revert();
        balances[_from] = SafeMath.sub(balances[_from], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }
    function approve(address _spender, uint _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }
    function withdrawFromEscrow(address _agreementAddr, bytes32 _id) {
        require(balances[_agreementAddr] > 0);
        Agreement agreement = Agreement(_agreementAddr);
        require(agreement.creator() == msg.sender);
        uint256 reward = agreement.getClaimableRewards(_id);
        require(reward > 0);
        balances[_agreementAddr] = SafeMath.sub(balances[_agreementAddr], reward);
        balances[msg.sender] = SafeMath.add(balances[msg.sender], reward);
    }
    function WhitelistParticipant(address participant) external onlyAuthorized {
        whitelisted[participant] = true;
        emit Whitelist(participant);
    }
    function BlacklistParticipant(address participant) external onlyAuthorized {
        whitelisted[participant] = false;
        emit Whitelist(participant);
    }
    function() public payable onlyPayloadSize(2) {
        contribute(msg.sender);
    }
    function contribute(address _backer) internal returns (bool res) {
        if (msg.value < minContributionETH)
            revert();
        uint tokensToSend = calculateNoOfTokensToSend();
        if (SafeMath.add(totalTokensSent, tokensToSend) > maxCap)
            revert();
        if (!transfer(_backer, tokensToSend))
            revert();
        ethReceived = SafeMath.add(ethReceived, msg.value);
        totalTokensSent = SafeMath.add(totalTokensSent, tokensToSend);
        return true;
    }
    function calculateNoOfTokensToSend() constant internal returns (uint) {
        uint tokenAmount = SafeMath.div(SafeMath.mul(msg.value, multiplier), tokenPriceWei);
        if (block.number <= startBlock + firstPeriod)
            return tokenAmount + SafeMath.div(SafeMath.mul(tokenAmount, firstBonus), 100);
        else if (block.number <= startBlock + secondPeriod)
            return tokenAmount + SafeMath.div(SafeMath.mul(tokenAmount, secondBonus), 100);
        else if (block.number <= startBlock + thirdPeriod)
            return tokenAmount + SafeMath.div(SafeMath.mul(tokenAmount, thirdBonus), 100);
        else if (block.number <= startBlock + fourthPeriod)
            return tokenAmount + SafeMath.div(SafeMath.mul(tokenAmount, fourthBonus), 100);
        else if (block.number <= startBlock + fifthPeriod)
            return tokenAmount + SafeMath.div(SafeMath.mul(tokenAmount, fifthBonus), 100);
        else
            return tokenAmount;
    }
    function stopCrowdsale() external onlyOwner{
        stopInEmergency = true;
        emit StoppedCrowdsale();
    }
    function restartCrowdsale() external onlyOwner{
        stopInEmergency = false;
        emit RestartedCrowdsale();
    }
}
