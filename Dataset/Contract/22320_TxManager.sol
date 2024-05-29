contract TxManager is DSAuth, DSMath, DSNote {
    function execute(address[] tokens, bytes script) public note auth {
        for (uint i = 0; i < tokens.length; i++) {
            uint256 amount = min(ERC20(tokens[i]).balanceOf(msg.sender), ERC20(tokens[i]).allowance(msg.sender, this));
            require(ERC20(tokens[i]).transferFrom(msg.sender, this, amount));
        }
        invokeContracts(script);
        for (uint j = 0; j < tokens.length; j++) {
            require(ERC20(tokens[j]).transfer(msg.sender, ERC20(tokens[j]).balanceOf(this)));
        }
    }
    function invokeContracts(bytes script) internal {
        uint256 location = 0;
        while (location < script.length) {
            address contractAddress = addressAt(script, location);
            uint256 calldataLength = uint256At(script, location + 0x14);
            uint256 calldataStart = locationOf(script, location + 0x14 + 0x20);
            assembly {
                switch delegatecall(sub(gas, 5000), contractAddress, calldataStart, calldataLength, 0, 0)
                case 0 {
                    revert(0, 0)
                }
            }
            location += (0x14 + 0x20 + calldataLength);
        }
    }
    function uint256At(bytes data, uint256 location) pure internal returns (uint256 result) {
        assembly {
            result := mload(add(data, add(0x20, location)))
        }
    }
    function addressAt(bytes data, uint256 location) pure internal returns (address result) {
        uint256 word = uint256At(data, location);
        assembly {
            result := div(and(word, 0xffffffffffffffffffffffffffffffffffffffff000000000000000000000000),
                          0x1000000000000000000000000)
        }
    }
    function locationOf(bytes data, uint256 location) pure internal returns (uint256 result) {
        assembly {
            result := add(data, add(0x20, location))
        }
    }
}
