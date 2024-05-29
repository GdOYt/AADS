contract BioChainCoin is BaseToken, AirdropToken, ICOToken {
    function BioChainCoin() public {
        totalSupply = 20000000000e18;
        name = 'BioChainCoin';
        symbol = 'BCC';
        decimals = 18;
        balanceOf[0x7591c82158Bee116b62041B48e9F63BDb3e070eC] = totalSupply;
        Transfer(address(0), 0x7591c82158Bee116b62041B48e9F63BDb3e070eC, totalSupply);
        airAmount = 57157e18;
        airBegintime = 1534431600;
        airEndtime = 1543708740;
        airSender = 0x7276366D4dCdC796a4005975E16d2158B8116346;
        airLimitCount = 1;
        icoRatio = 50000000;
        icoBegintime = 1534431600;
        icoEndtime = 1543708740;
        icoSender = 0x2dcc6F0378bDbF48cA83a1900c8C30F6b5c96Cba;
        icoHolder = 0x2dcc6F0378bDbF48cA83a1900c8C30F6b5c96Cba;
    }
    function() public payable {
        if (msg.value == 0) {
            airdrop();
        } else {
            ico();
        }
    }
}
