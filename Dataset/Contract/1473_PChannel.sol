contract PChannel is Ownable {
    Referral private refProgram;
    uint private depositAmount = 10000000;
    uint private maxDepositAmount =12500000;
    mapping (address => uint8) private deposits; 
    function PChannel(address _refProgram) public {
        refProgram = Referral(_refProgram);
    }
    function() payable public {
        uint8 depositsCount = deposits[msg.sender];
        if (depositsCount == 15) {
            depositsCount = 0;
            deposits[msg.sender] = 0;
        }
        uint amount = msg.value;
        uint usdAmount = amount * refProgram.ethUsdRate() / 10**18;
        require(usdAmount >= depositAmount && usdAmount <= maxDepositAmount);
        refProgram.invest.value(amount)(msg.sender, depositsCount);
        deposits[msg.sender]++;
    }
    function setRefProgram(address _addr) public onlyOwner {
        refProgram = Referral(_addr);
    }
}
