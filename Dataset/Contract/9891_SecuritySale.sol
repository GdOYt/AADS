contract SecuritySale is Ownable {
    bool public live;         
    IInvestorList public investorList;  
    event SaleLive(bool liveness);
    event EtherIn(address from, uint amount);
    event StartSale();
    event EndSale();
    constructor() public {
        live = false;
    }
    function setInvestorList(address _investorList) public onlyOwner {
        investorList = IInvestorList(_investorList);
    }
    function () public payable {
        require(live);
        require(investorList.inList(msg.sender));
        emit EtherIn(msg.sender, msg.value);
    }
    function setLive(bool newLiveness) public onlyOwner {
        if(live && !newLiveness) {
            live = false;
            emit EndSale();
        }
        else if(!live && newLiveness) {
            live = true;
            emit StartSale();
        }
    }
    function withdraw() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
    function withdrawSome(uint value) public onlyOwner {
        require(value <= address(this).balance);
        msg.sender.transfer(value);
    }
    function withdrawTokens(address token) public onlyOwner {
        ERC20Basic t = ERC20Basic(token);
        require(t.transfer(msg.sender, t.balanceOf(this)));
    }
    function sendReceivedTokens(address token, address sender, uint amount) public onlyOwner {
        ERC20Basic t = ERC20Basic(token);
        require(t.transfer(sender, amount));
    }
}
