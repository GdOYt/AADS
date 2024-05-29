contract CampaignToken is HumanStandardToken {
    address public tokenController;
    modifier onlyController { if (msg.sender != tokenController) throw; _; }
    function CampaignToken() HumanStandardToken(0,"CharityDAO Token",18,"GIVE") {
        tokenController = msg.sender;
    }
    function createTokens(address beneficiary, uint amount
    ) onlyController returns (bool success) {
        if (sealed()) throw;
        balances[beneficiary] += amount;   
        totalSupply += amount;             
        Transfer(0, beneficiary, amount);  
        return true;
    }
    function seal() onlyController returns (bool success)  {
        tokenController = 0;
        return true;
    }
    function sealed() constant returns (bool) {
        return tokenController == 0;
    }
}
