contract Crowdsale is Ownable {
    using SafeMath for uint; 
    event LogStateSwitch(State newState);
    event Withdraw(address indexed from, address indexed to, uint256 amount);
    address myAddress = this;
    uint64 crowdSaleStartTime = 0;
    uint64 crowdSaleEndTime = 0;
    uint public  tokenRate = 942;   
    address public marketingProfitAddress = 0x0;
    address public neironixProfitAddress = 0x0;
    address public lawSupportProfitAddress = 0x0;
    address public hostingProfitAddress = 0x0;
    address public teamProfitAddress = 0x0;
    address public contractorsProfitAddress = 0x0;
    address public saasApiProfitAddress = 0x0;
    NRXtoken public token = new NRXtoken(myAddress);
    ProjectFundAddress public holdAddress1 = new ProjectFundAddress();
    TeamAddress public holdAddress2 = new TeamAddress();
    PartnersAddress public holdAddress3 = new PartnersAddress();
    AdvisorsAddress public holdAddress4 = new AdvisorsAddress();
    BountyAddress public holdAddress5 = new BountyAddress();
    enum State { 
        Init,    
        CrowdSale,
        WorkTime
    }
    State public currentState = State.Init;
    modifier onlyInState(State state){ 
        require(state==currentState); 
        _; 
    }
    constructor() public {
        uint256 TotalTokens = token.INITIAL_SUPPLY().div(1 ether);
        _transferTokens(address(holdAddress1), TotalTokens.mul(7).div(100));
        _transferTokens(address(holdAddress2), TotalTokens.div(10));
        _transferTokens(address(holdAddress3), TotalTokens.div(10));
        _transferTokens(address(holdAddress4), TotalTokens.mul(35).div(1000));
        _transferTokens(address(holdAddress5), TotalTokens.mul(3).div(100));
        crowdSaleStartTime = 1535760000;
        crowdSaleEndTime = crowdSaleStartTime + 91 days;
    }
    function setRate(uint _newRate) public onlyOwner {
        tokenRate = _newRate;
    }
    function setMarketingProfitAddress(address _addr) public onlyOwner onlyInState(State.Init){
        require (_addr != address(0));
        marketingProfitAddress = _addr;
    }
    function setNeironixProfitAddress(address _addr) public onlyOwner onlyInState(State.Init){
        require (_addr != address(0));
        neironixProfitAddress = _addr;
    }
    function setLawSupportProfitAddress(address _addr) public onlyOwner onlyInState(State.Init){
        require (_addr != address(0));
        lawSupportProfitAddress = _addr;
    }
    function setHostingProfitAddress(address _addr) public onlyOwner onlyInState(State.Init){
        require (_addr != address(0));
        hostingProfitAddress = _addr;
    }
    function setTeamProfitAddress(address _addr) public onlyOwner onlyInState(State.Init){
        require (_addr != address(0));
        teamProfitAddress = _addr;
    }
    function setContractorsProfitAddress(address _addr) public onlyOwner onlyInState(State.Init){
        require (_addr != address(0));
        contractorsProfitAddress = _addr;
    }
    function setSaasApiProfitAddress(address _addr) public onlyOwner onlyInState(State.Init){
        require (_addr != address(0));
        saasApiProfitAddress = _addr;
    }
    function acceptTokensFromUsers(address _investor, uint256 _value) public onlyOwner{
        token.acceptTokens(_investor, _value); 
    }
    function transferTokensFromProjectFundAddress(address _investor, uint256 _value) public onlyOwner returns(bool){
        uint256 value = _value;
        require (value >= 1);
        value = value.mul(1 ether);
        token.transferTokensFromSpecialAddress(address(holdAddress1), _investor, value); 
        return true;
    } 
    function transferTokensFromTeamAddress(address _investor, uint256 _value) public onlyOwner returns(bool){
        uint256 value = _value;
        require (value >= 1);
        value = value.mul(1 ether);
        require (now >= crowdSaleEndTime + 182 days, "only after 182 days");
        token.transferTokensFromSpecialAddress(address(holdAddress2), _investor, value); 
        return true;
    } 
    function transferTokensFromPartnersAddress(address _investor, uint256 _value) public onlyOwner returns(bool){
        uint256 value = _value;
        require (value >= 1);
        value = value.mul(1 ether);
        require (now >= crowdSaleEndTime + 91 days, "only after 91 days");
        token.transferTokensFromSpecialAddress(address(holdAddress3), _investor, value); 
        return true;
    } 
    function transferTokensFromAdvisorsAddress(address _investor, uint256 _value) public onlyOwner returns(bool){
        uint256 value = _value;
        require (value >= 1);
        value = value.mul(1 ether);
        require (now >= crowdSaleEndTime + 91 days, "only after 91 days");
        token.transferTokensFromSpecialAddress(address(holdAddress4), _investor, value); 
        return true;
    }     
    function transferTokensFromBountyAddress(address _investor, uint256 _value) public onlyOwner returns(bool){
        uint256 value = _value;
        require (value >= 1);
        value = value.mul(1 ether);
        token.transferTokensFromSpecialAddress(address(holdAddress5), _investor, value); 
        return true;
    }     
    function _transferTokens(address _newInvestor, uint256 _value) internal {
        require (_newInvestor != address(0));
        require (_value >= 1);
        uint256 value = _value;
        value = value.mul(1 ether);
        token.transfer(_newInvestor, value);
    }  
    function transferTokens(address _newInvestor, uint256 _value) public onlyOwner {
        _transferTokens(_newInvestor, _value);
    }
    function setState(State _state) internal {
        currentState = _state;
        emit LogStateSwitch(_state);
    }
    function startSale() public onlyOwner onlyInState(State.Init) {
        require(uint64(now) > crowdSaleStartTime, "Sale time is not coming.");
        require(neironixProfitAddress != address(0));
        setState(State.CrowdSale);
        token.lockTransfer(true);
    }
    function finishCrowdSale() public onlyOwner onlyInState(State.CrowdSale) {
        require (now > crowdSaleEndTime, "CrowdSale stage is not over");
        setState(State.WorkTime);
        token.lockTransfer(false);
        token.burn(token.balanceOf(myAddress));
    }
    function blockExternalTransfer() public onlyOwner onlyInState (State.WorkTime){
        require (token.lockTransfers() == false);
        token.lockTransfer(true);
    }
    function unBlockExternalTransfer() public onlyOwner onlyInState (State.WorkTime){
        require (token.lockTransfers() == true);
        token.lockTransfer(false);
    }
    function setBonus () public view returns(uint256) {
        uint256 actualBonus = 0;
        if ((uint64(now) >= crowdSaleStartTime) && (uint64(now) < crowdSaleStartTime + 30 days)){
            actualBonus = 35;
        }
        if ((uint64(now) >= crowdSaleStartTime + 30 days) && (uint64(now) < crowdSaleStartTime + 61 days)){
            actualBonus = 15;
        }
        if ((uint64(now) >= crowdSaleStartTime + 61 days) && (uint64(now) < crowdSaleStartTime + 91 days)){
            actualBonus = 5;
        }
        return actualBonus;
    }
    function _withdrawProfit () internal {
        uint256 marketingProfit = myAddress.balance.mul(30).div(100);    
        uint256 lawSupportProfit = myAddress.balance.div(20);            
        uint256 hostingProfit = myAddress.balance.div(20);               
        uint256 teamProfit = myAddress.balance.div(10);                  
        uint256 contractorsProfit = myAddress.balance.div(20);           
        uint256 saasApiProfit = myAddress.balance.div(20);               
        if (marketingProfitAddress != address(0)) {
            marketingProfitAddress.transfer(marketingProfit);
            emit Withdraw(msg.sender, marketingProfitAddress, marketingProfit);
        }
        if (lawSupportProfitAddress != address(0)) {
            lawSupportProfitAddress.transfer(lawSupportProfit);
            emit Withdraw(msg.sender, lawSupportProfitAddress, lawSupportProfit);
        }
        if (hostingProfitAddress != address(0)) {
            hostingProfitAddress.transfer(hostingProfit);
            emit Withdraw(msg.sender, hostingProfitAddress, hostingProfit);
        }
        if (teamProfitAddress != address(0)) {
            teamProfitAddress.transfer(teamProfit);
            emit Withdraw(msg.sender, teamProfitAddress, teamProfit);
        }
        if (contractorsProfitAddress != address(0)) {
            contractorsProfitAddress.transfer(contractorsProfit);
            emit Withdraw(msg.sender, contractorsProfitAddress, contractorsProfit);
        }
        if (saasApiProfitAddress != address(0)) {
            saasApiProfitAddress.transfer(saasApiProfit);
            emit Withdraw(msg.sender, saasApiProfitAddress, saasApiProfit);
        }
        require(neironixProfitAddress != address(0));
        uint myBalance = myAddress.balance;
        neironixProfitAddress.transfer(myBalance);
        emit Withdraw(msg.sender, neironixProfitAddress, myBalance);
    }
    function _saleTokens() internal returns(bool) {
        require(uint64(now) > crowdSaleStartTime, "Sale stage is not yet, Contract is init, do not accept ether."); 
        if (currentState == State.Init) {
            require(neironixProfitAddress != address(0),"At least one of profit addresses must be entered");
            setState(State.CrowdSale);
        }
        if (uint64(now) > crowdSaleEndTime){
            require (false, "CrowdSale stage is passed - contract do not accept ether");
        }
        uint tokens = tokenRate.mul(msg.value);
        if (currentState == State.CrowdSale) {
            require (msg.value <= 250 ether, "Maximum 250 ether for transaction all CrowdSale period");
            require (msg.value >= 0.1 ether, "Minimum 0,1 ether for transaction all CrowdSale period");
        }
        tokens = tokens.add(tokens.mul(setBonus()).div(100));
        token.transfer(msg.sender, tokens);
        return true;
    }
    function() external payable {
        if (_saleTokens()) {
            _withdrawProfit();
        }
    }    
}
