contract CardPackFour {
    MigrationInterface public migration;
    uint public creationBlock;
    constructor(MigrationInterface _core) public payable {
        migration = _core;
        creationBlock = 5939061 + 2000;  
    }
    event Referral(address indexed referrer, uint value, address purchaser);
    function purchase(uint16 packCount, address referrer) public payable;
    function _getPurity(uint16 randOne, uint16 randTwo) internal pure returns (uint16) {
        if (randOne >= 998) {
            return 3000 + randTwo;
        } else if (randOne >= 988) {
            return 2000 + randTwo;
        } else if (randOne >= 938) {
            return 1000 + randTwo;
        } else {
            return randTwo;
        }
    }
}
