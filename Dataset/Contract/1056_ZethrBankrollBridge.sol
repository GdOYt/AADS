contract ZethrBankrollBridge {
    ZethrInterface Zethr;
    address[7] UsedBankrollAddresses; 
    mapping(address => bool) ValidBankrollAddress;
    function setupBankrollInterface(address ZethrMainBankrollAddress) internal {
        Zethr = ZethrInterface(0xD48B633045af65fF636F3c6edd744748351E020D);
        UsedBankrollAddresses = ZethrMainBankroll(ZethrMainBankrollAddress).gameGetTokenBankrollList();
        for(uint i=0; i<7; i++){
            ValidBankrollAddress[UsedBankrollAddresses[i]] = true;
        }
    }
    modifier fromBankroll(){
        require(ValidBankrollAddress[msg.sender], "msg.sender should be a valid bankroll");
        _;
    }
    function RequestBankrollPayment(address to, uint tokens, uint tier) internal {
        address tokenBankrollAddress = UsedBankrollAddresses[tier];
        ZethrTokenBankroll(tokenBankrollAddress).gameRequestTokens(to, tokens);
    }
    function getZethrTokenBankroll(uint divRate) public constant returns (ZethrTokenBankroll){
        return ZethrTokenBankroll(UsedBankrollAddresses[ZethrTierLibrary.getTier(divRate)]);
    }
}
