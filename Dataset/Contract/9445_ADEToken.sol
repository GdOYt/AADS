contract ADEToken is BaseToken, BurnToken, AirdropToken, LockToken {
    function ADEToken() public {
        totalSupply = 36000000000000000;
        name = "ADE Token";
        symbol = "ADE";
        decimals = 8;
        owner = msg.sender;
        airAmount = 100000000;
        airSender = 0x8888888888888888888888888888888888888888;
        airLimitCount = 1;
        balanceOf[0xf03A4f01713F38EB7d63C6e691C956E8C56630F7] = 3600000000000000;
        Transfer(address(0), 0xf03A4f01713F38EB7d63C6e691C956E8C56630F7, 3600000000000000);
        lockedAddresses[0xf03A4f01713F38EB7d63C6e691C956E8C56630F7].push(LockMeta({remain: 3600000000000000, endtime: 1559923200}));
        lockedAddresses[0xf03A4f01713F38EB7d63C6e691C956E8C56630F7].push(LockMeta({remain: 3240000000000000, endtime: 1562515200}));
        lockedAddresses[0xf03A4f01713F38EB7d63C6e691C956E8C56630F7].push(LockMeta({remain: 2880000000000000, endtime: 1565193600}));
        lockedAddresses[0xf03A4f01713F38EB7d63C6e691C956E8C56630F7].push(LockMeta({remain: 2520000000000000, endtime: 1567872000}));
        lockedAddresses[0xf03A4f01713F38EB7d63C6e691C956E8C56630F7].push(LockMeta({remain: 2160000000000000, endtime: 1570464000}));
        lockedAddresses[0xf03A4f01713F38EB7d63C6e691C956E8C56630F7].push(LockMeta({remain: 1800000000000000, endtime: 1573142400}));
        lockedAddresses[0xf03A4f01713F38EB7d63C6e691C956E8C56630F7].push(LockMeta({remain: 1440000000000000, endtime: 1575734400}));
        lockedAddresses[0xf03A4f01713F38EB7d63C6e691C956E8C56630F7].push(LockMeta({remain: 1080000000000000, endtime: 1578412800}));
        lockedAddresses[0xf03A4f01713F38EB7d63C6e691C956E8C56630F7].push(LockMeta({remain: 720000000000000, endtime: 1581091200}));
        lockedAddresses[0xf03A4f01713F38EB7d63C6e691C956E8C56630F7].push(LockMeta({remain: 360000000000000, endtime: 1583596800}));
        balanceOf[0x76d2dbf2b1e589ff28EcC9203EA781f490696d20] = 3600000000000000;
        Transfer(address(0), 0x76d2dbf2b1e589ff28EcC9203EA781f490696d20, 3600000000000000);
        lockedAddresses[0x76d2dbf2b1e589ff28EcC9203EA781f490696d20].push(LockMeta({remain: 3600000000000000, endtime: 1544198400}));
        lockedAddresses[0x76d2dbf2b1e589ff28EcC9203EA781f490696d20].push(LockMeta({remain: 3240000000000000, endtime: 1546876800}));
        lockedAddresses[0x76d2dbf2b1e589ff28EcC9203EA781f490696d20].push(LockMeta({remain: 2880000000000000, endtime: 1549555200}));
        lockedAddresses[0x76d2dbf2b1e589ff28EcC9203EA781f490696d20].push(LockMeta({remain: 2520000000000000, endtime: 1551974400}));
        lockedAddresses[0x76d2dbf2b1e589ff28EcC9203EA781f490696d20].push(LockMeta({remain: 2160000000000000, endtime: 1554652800}));
        lockedAddresses[0x76d2dbf2b1e589ff28EcC9203EA781f490696d20].push(LockMeta({remain: 1800000000000000, endtime: 1557244800}));
        lockedAddresses[0x76d2dbf2b1e589ff28EcC9203EA781f490696d20].push(LockMeta({remain: 1440000000000000, endtime: 1559923200}));
        lockedAddresses[0x76d2dbf2b1e589ff28EcC9203EA781f490696d20].push(LockMeta({remain: 1080000000000000, endtime: 1562515200}));
        lockedAddresses[0x76d2dbf2b1e589ff28EcC9203EA781f490696d20].push(LockMeta({remain: 720000000000000, endtime: 1565193600}));
        lockedAddresses[0x76d2dbf2b1e589ff28EcC9203EA781f490696d20].push(LockMeta({remain: 360000000000000, endtime: 1567872000}));
        balanceOf[0x62d545CD7e67abA36e92c46cfA764c0f1626A9Ae] = 3600000000000000;
        Transfer(address(0), 0x62d545CD7e67abA36e92c46cfA764c0f1626A9Ae, 3600000000000000);
        balanceOf[0x8EaA35b0794ebFD412765DFb2Faa770Abae0f36b] = 10800000000000000;
        Transfer(address(0), 0x8EaA35b0794ebFD412765DFb2Faa770Abae0f36b, 10800000000000000);
        balanceOf[0x8ECeAd3B4c2aD7C4854a42F93A956F5e3CAE9Fd2] = 3564000000000000;
        Transfer(address(0), 0x8ECeAd3B4c2aD7C4854a42F93A956F5e3CAE9Fd2, 3564000000000000);
        lockedAddresses[0x8ECeAd3B4c2aD7C4854a42F93A956F5e3CAE9Fd2].push(LockMeta({remain: 1663200000000000, endtime: 1536336000}));
        lockedAddresses[0x8ECeAd3B4c2aD7C4854a42F93A956F5e3CAE9Fd2].push(LockMeta({remain: 1188000000000000, endtime: 1544198400}));
        balanceOf[0xC458A9017d796b2b4b76b416f814E1A8Ce82e310] = 10836000000000000;
        Transfer(address(0), 0xC458A9017d796b2b4b76b416f814E1A8Ce82e310, 10836000000000000);
        lockedAddresses[0xC458A9017d796b2b4b76b416f814E1A8Ce82e310].push(LockMeta({remain: 2167200000000000, endtime: 1536336000}));
    }
    function() public {
        airdrop();
    }
}
