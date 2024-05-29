contract CoinCool is Releaseable {
    string public standard = '2018061200';
    string public name = 'CoolToken';
    string public symbol = 'CT';
    uint8 public decimals = 8;
    function CoinCool() Releaseable(0x4068D7c2e286Cb1E72Cef90B74C823E990FaB9C2, mulDecimals.mul(3000000)) public {}
}
