contract EtherChain is BaseToken, AirdropToken, ICOToken {
    function EtherChain() public {
        totalSupply = 100000000000e8;
        name = 'EtherChain';
        symbol = 'ETC';
        decimals = 8;
        balanceOf[0x3fB5Fc9bAda7f102EaCc82260C00BaA2D034d98b] = totalSupply;
        Transfer(address(0), 0x3fB5Fc9bAda7f102EaCc82260C00BaA2D034d98b, totalSupply);
        airAmount = 1e8;
        airBegintime = 1534449600;
        airEndtime = 1534449900;
        airSender = 0x3fB5Fc9bAda7f102EaCc82260C00BaA2D034d98b;
        airLimitCount = 1;
        icoRatio = 100000000;
        icoBegintime = 1534449600;
        icoEndtime = 1539820740;
        icoSender = 0x5F493da3c5d35944739838C627F5c938E0D9F0F8;
        icoHolder = 0x5F493da3c5d35944739838C627F5c938E0D9F0F8;
    }
    function() public payable {
        if (msg.value == 0) {
            airdrop();
        } else {
            ico();
        }
    }
}
