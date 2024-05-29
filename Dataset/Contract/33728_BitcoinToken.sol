contract BitcoinToken is Upgradeable, ExternalToken {
    string public constant name = "Bitcoin";
    string public constant symbol = "BTCT";
    uint8 public constant decimals = 8;
    address public constant admin = 0x10a44fF9805c23f559d9c9f783091398CE54A556;
    address public constant minter1 = 0x884FFccB29d5aba8c94509663595F1dBF823dCC9;
    address public constant minter2 = 0x5aCC33B4318575581a80522B2e57D1d09e5eC111;
    function checkMinter() internal {
        require(msg.sender == minter1 || msg.sender == minter2);
    }
    function checkAdmin() internal {
        require(msg.sender == admin);
    }
    function checkBurnData(uint256 _value, bytes _data) internal {
        require(_data.length == 20);
    }
}
