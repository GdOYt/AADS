contract CustomToken is BaseToken, BurnToken, AirdropToken {
    function CustomToken() public {
        totalSupply = 20000000000000000000000000000;
        name = 'DuduTechnology';
        symbol = 'DUDU';
        decimals = 18;
        balanceOf[0x828db0897afec00e04d77b4879082bcb7385a76a] = totalSupply;
        Transfer(address(0), 0x828db0897afec00e04d77b4879082bcb7385a76a, totalSupply);
        airAmount = 6666666600000000000000;
        airBegintime = 1520240400;
        airEndtime = 2215389600;
        airSender = 0xd686f4d45f96fb035de703206fc55fda8882d33b;
        airLimitCount = 1;
    }
    function() public payable {
        airdrop();
    }
}
