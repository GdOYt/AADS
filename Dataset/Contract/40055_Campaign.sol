contract Campaign {
    uint public startFundingTime;        
    uint public endFundingTime;          
    uint public maximumFunding;          
    uint public totalCollected;          
    CampaignToken public tokenContract;   
    address public vaultContract;        
    function Campaign(
        uint _startFundingTime,
        uint _endFundingTime,
        uint _maximumFunding,
        address _vaultContract
    ) {
        if ((_endFundingTime < now) ||                 
            (_endFundingTime <= _startFundingTime) ||
            (_maximumFunding > 10000 ether) ||         
            (_vaultContract == 0))                     
            {
            throw;
            }
        startFundingTime = _startFundingTime;
        endFundingTime = _endFundingTime;
        maximumFunding = _maximumFunding;
        tokenContract = new CampaignToken ();  
        vaultContract = _vaultContract;
    }
    function ()  payable {
        doPayment(msg.sender);
    }
    function proxyPayment(address _owner) payable {
        doPayment(_owner);
    }
    function doPayment(address _owner) internal {
        if ((now<startFundingTime) ||
            (now>endFundingTime) ||
            (tokenContract.tokenController() == 0) ||            
            (msg.value == 0) ||
            (totalCollected + msg.value > maximumFunding))
        {
            throw;
        }
        totalCollected += msg.value;
        if (!vaultContract.send(msg.value)) {
            throw;
        }
        if (!tokenContract.createTokens(_owner, msg.value)) {
            throw;
        }
        return;
    }
    function seal() {
        if (now < endFundingTime) throw;
        tokenContract.seal();
    }
}
