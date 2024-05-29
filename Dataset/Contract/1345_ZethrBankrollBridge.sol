contract ZethrBankrollBridge{
    ZethrInterface Zethr;
    address[7] UsedBankrollAddresses; 
    mapping(address => bool) ValidBankrollAddress;
    function setupBankrollInterface(address ZethrMainBankrollAddress) internal {
        UsedBankrollAddresses = ZethrMainBankroll(ZethrMainBankrollAddress).gameGetTokenBankrollList();
        for(uint i=0; i<7; i++){
            ValidBankrollAddress[UsedBankrollAddresses[i]] = true;
        }
    }
    modifier fromBankroll(){
        require(ValidBankrollAddress[msg.sender], "msg.sender should be a valid bankroll");
        _;
    }
    function RequestBankrollPayment(address to, uint tokens, uint userDivRate) internal {
        uint tier = ZethrTierLibrary.getTier(userDivRate);
        address tokenBankrollAddress = UsedBankrollAddresses[tier];
        ZethrTokenBankroll(tokenBankrollAddress).gameRequestTokens(to, tokens);
    }
}
