contract Token is ERC20 {
    string public constant name = "Array.io Token";
    string public constant symbol = "eRAY";
    uint8 public constant decimals = 18;
    uint public tgrSettingsAmount;  
    uint public tgrSettingsMinimalContribution; 
    uint public tgrSettingsPartContributor;
    uint public tgrSettingsPartProject;
    uint public tgrSettingsPartFounders;
    uint public tgrSettingsBlocksPerStage;
    uint public tgrSettingsPartContributorIncreasePerStage;
    uint public tgrSettingsMaxStages;
    uint public tgrStartBlock;  
    uint public tgrNumber;  
    uint public tgrAmountCollected;  
    uint public tgrContributedAmount;  
    address public projectWallet;
    address public foundersWallet;
    address constant public burnAddress = address(0);
    mapping (address => uint) public invBalances;
    uint public totalInvSupply;
    Whitelist public whitelist;
    modifier isTgrLive(){
        require(tgrLive());
        _;
    }
    modifier isNotTgrLive(){
        require(!tgrLive());
        _;
    }
    event Burn(address indexed _owner,  uint _value);
    event TGRStarted(uint tgrSettingsAmount,
                     uint tgrSettingsMinimalContribution,
                     uint tgrSettingsPartContributor,
                     uint tgrSettingsPartProject, 
                     uint tgrSettingsPartFounders, 
                     uint tgrSettingsBlocksPerStage, 
                     uint tgrSettingsPartContributorIncreasePerStage,
                     uint tgrSettingsMaxStages,
                     uint blockNumber,
                     uint tgrNumber); 
    event TGRFinished(uint blockNumber, uint amountCollected);
    constructor(address _projectWallet, address _foundersWallet) public {
        projectWallet = _projectWallet;
        foundersWallet = _foundersWallet;
    }
    function () public payable isTgrLive isNotFrozenOnly noAnyReentrancy {
        require(whitelist.whitelist(msg.sender));  
        require(tgrAmountCollected < tgrSettingsAmount);  
        require(msg.value >= tgrSettingsMinimalContribution); 
        uint stage = block.number.sub(tgrStartBlock).div(tgrSettingsBlocksPerStage);
        require(stage < tgrSettingsMaxStages);  
        uint etherToRefund = 0;
        uint etherContributed = msg.value;
        uint currentPartContributor = tgrSettingsPartContributor.add(stage.mul(tgrSettingsPartContributorIncreasePerStage));
        uint allStakes = currentPartContributor.add(tgrSettingsPartProject).add(tgrSettingsPartFounders);
        uint remainsToContribute = (tgrSettingsAmount.sub(tgrAmountCollected)).mul(allStakes).div(tgrSettingsPartProject);
        if ((tgrSettingsAmount.sub(tgrAmountCollected)).mul(allStakes) % tgrSettingsPartProject != 0) {
            remainsToContribute = remainsToContribute + allStakes;
        }
        if (remainsToContribute < msg.value) {
            etherToRefund = msg.value.sub(remainsToContribute);
            etherContributed = remainsToContribute;
        }
        uint tokensProject = etherContributed.mul(tgrSettingsPartProject).div(allStakes);
        uint tokensFounders = etherContributed.mul(tgrSettingsPartFounders).div(allStakes);
        uint tokensContributor = etherContributed.sub(tokensProject).sub(tokensFounders);
        tgrAmountCollected = tgrAmountCollected.add(tokensProject);
        tgrContributedAmount = tgrContributedAmount.add(etherContributed);
        _mint(tokensProject, tokensFounders, tokensContributor);
        msg.sender.transfer(etherToRefund);
    }
    function tgrSetLive() public only(projectWallet) isNotTgrLive isNotFrozenOnly {
        tgrNumber +=1;
        tgrStartBlock = block.number;
        tgrAmountCollected = 0;
        tgrContributedAmount = 0;
        emit TGRStarted(tgrSettingsAmount,
                     tgrSettingsMinimalContribution,
                     tgrSettingsPartContributor,
                     tgrSettingsPartProject, 
                     tgrSettingsPartFounders, 
                     tgrSettingsBlocksPerStage, 
                     tgrSettingsPartContributorIncreasePerStage,
                     tgrSettingsMaxStages,
                     block.number,
                     tgrNumber); 
    }
    function tgrSetFinished() public only(projectWallet) isTgrLive isNotFrozenOnly {
        emit TGRFinished(block.number, tgrAmountCollected); 
        tgrStartBlock = 0;
    }
    function burn(uint _amount) public isNotFrozenOnly noAnyReentrancy returns(bool _success) {
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[burnAddress] = balances[burnAddress].add(_amount);
        totalSupply = totalSupply.sub(_amount);
        msg.sender.transfer(_amount);
        emit Transfer(msg.sender, burnAddress, _amount);
        emit Burn(burnAddress, _amount);
        return true;
    }
    function transfer(address _to, uint _value) public isNotFrozenOnly onlyPayloadSize(2 * 32) returns (bool success) {
        require(_to != address(0));
        require(_to != address(this));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function multiTransfer(address[] dests, uint[] values) public isNotFrozenOnly returns(uint) {
        uint i = 0;
        while (i < dests.length) {
           transfer(dests[i], values[i]);
           i += 1;
        }
        return i;
    }
    function withdrawFrozen() public isFrozenOnly noAnyReentrancy {
        uint amountWithdraw = totalSupply.mul(invBalances[msg.sender]).div(totalInvSupply);
        if (amountWithdraw > address(this).balance) {
            amountWithdraw = address(this).balance;
        }
        invBalances[msg.sender] = 0;
        msg.sender.transfer(amountWithdraw);
    }
    function setWhitelist(address _address) public only(projectWallet) isNotFrozenOnly returns (bool) {
        whitelist = Whitelist(_address);
    }
    function executeSettingsChange(
        uint amount, 
        uint minimalContribution,
        uint partContributor,
        uint partProject, 
        uint partFounders, 
        uint blocksPerStage, 
        uint partContributorIncreasePerStage,
        uint maxStages
    ) 
    public
    only(projectWallet)
    isNotTgrLive 
    isNotFrozenOnly
    returns(bool success) 
    {
        tgrSettingsAmount = amount;
        tgrSettingsMinimalContribution = minimalContribution;
        tgrSettingsPartContributor = partContributor;
        tgrSettingsPartProject = partProject;
        tgrSettingsPartFounders = partFounders;
        tgrSettingsBlocksPerStage = blocksPerStage;
        tgrSettingsPartContributorIncreasePerStage = partContributorIncreasePerStage;
        tgrSettingsMaxStages = maxStages;
        return true;
    }
    function setFreeze() public only(projectWallet) isNotFrozenOnly returns (bool) {
        isFrozen = true;
        return true;
    }
    function _mint(uint _tokensProject, uint _tokensFounders, uint _tokensContributor) internal {
        balances[projectWallet] = balances[projectWallet].add(_tokensProject);
        balances[foundersWallet] = balances[foundersWallet].add(_tokensFounders);
        balances[msg.sender] = balances[msg.sender].add(_tokensContributor);
        invBalances[msg.sender] = invBalances[msg.sender].add(_tokensContributor).add(_tokensFounders).add(_tokensProject);
        totalInvSupply = totalInvSupply.add(_tokensContributor).add(_tokensFounders).add(_tokensProject);
        totalSupply = totalSupply.add(_tokensProject).add(_tokensFounders).add(_tokensContributor);
        emit Transfer(0x0, msg.sender, _tokensContributor);
        emit Transfer(0x0, projectWallet, _tokensProject);
        emit Transfer(0x0, foundersWallet, _tokensFounders);
    }
    function tgrLive() view public returns(bool) {
        if (tgrStartBlock == 0) {
            return false;
        }
        uint stage = block.number.sub(tgrStartBlock).div(tgrSettingsBlocksPerStage);
        if (stage < tgrSettingsMaxStages) {
            if (tgrAmountCollected >= tgrSettingsAmount){
                return false;
            } else { 
                return true;
            }
        } else {
            return false;
        }
    }
    function tgrStageBlockLeft() public view returns(int) {
        if (tgrLive()) {
            uint stage = block.number.sub(tgrStartBlock).div(tgrSettingsBlocksPerStage);
            return int(tgrStartBlock.add((stage+1).mul(tgrSettingsBlocksPerStage)).sub(block.number));
        } else {
            return -1;
        }
    }
    function tgrCurrentPartContributor() public view returns(int) {
        if (tgrLive()) {
            uint stage = block.number.sub(tgrStartBlock).div(tgrSettingsBlocksPerStage);
            return int(tgrSettingsPartContributor.add(stage.mul(tgrSettingsPartContributorIncreasePerStage)));
        } else {
            return -1;
        }
    }
    function tgrNextPartContributor() public view returns(int) {
        if (tgrLive()) {
            uint stage = block.number.sub(tgrStartBlock).div(tgrSettingsBlocksPerStage).add(1);        
            return int(tgrSettingsPartContributor.add(stage.mul(tgrSettingsPartContributorIncreasePerStage)));
        } else {
            return -1;
        }
    }
    function tgrCurrentStage() public view returns(int) {
        if (tgrLive()) {
            return int(block.number.sub(tgrStartBlock).div(tgrSettingsBlocksPerStage).add(1));        
        } else {
            return -1;
        }
    }
}
