contract YunToken is YunMint {
    string public standard = '2018062301';
    string public name = 'YunToken';
    string public symbol = 'YUN';
    uint8 public decimals = 8;
    function YunToken(address _operator) YunMint(_operator) public {}
}
