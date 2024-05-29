contract HumanStandardTokenFactory {
    mapping(address => address[]) public created;
    mapping(address => bool) public isHumanToken;  
    bytes public humanStandardByteCode;
    function HumanStandardTokenFactory() {
      address verifiedToken = createHumanStandardToken(10000, "Verify Token", 3, "VTX");
      humanStandardByteCode = codeAt(verifiedToken);
    }
    function verifyHumanStandardToken(address _tokenContract) constant returns (bool) {
      bytes memory fetchedTokenByteCode = codeAt(_tokenContract);
      if (fetchedTokenByteCode.length != humanStandardByteCode.length) {
        return false;  
      }
      for (uint i = 0; i < fetchedTokenByteCode.length; i ++) {
        if (fetchedTokenByteCode[i] != humanStandardByteCode[i]) {
          return false;
        }
      }
      return true;
    }
    function codeAt(address _addr) internal constant returns (bytes o_code) {
      assembly {
          let size := extcodesize(_addr)
          o_code := mload(0x40)
          mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
          mstore(o_code, size)
          extcodecopy(_addr, add(o_code, 0x20), 0, size)
      }
    }
    function createHumanStandardToken(uint256 _initialAmount, string _name, uint8 _decimals, string _symbol) returns (address) {
        HumanStandardToken newToken = (new HumanStandardToken(_initialAmount, _name, _decimals, _symbol));
        created[msg.sender].push(address(newToken));
        isHumanToken[address(newToken)] = true;
        newToken.transfer(msg.sender, _initialAmount);  
        return address(newToken);
    }
}
