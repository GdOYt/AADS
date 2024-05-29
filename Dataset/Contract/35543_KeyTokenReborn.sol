contract KeyTokenReborn {
    DSToken public key;
    uint128 public constant TOTAL_SUPPLY = 10 ** 11 * 1 ether;   
    address public keyFoundation;  
    function KeyTokenReborn(address _keyFoundation) {
        require(_keyFoundation != 0x0);
        keyFoundation = _keyFoundation;
        key = new DSToken("KEY");
        key.setName("KEY");
        key.mint(TOTAL_SUPPLY);
        key.transfer(keyFoundation, TOTAL_SUPPLY);
        key.setOwner(keyFoundation);
    }
}
