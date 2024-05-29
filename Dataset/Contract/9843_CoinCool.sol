contract CoinCool is Releaseable {
    string public standard = '2018061610';
    string public name = 'CoinCoolToken';
    string public symbol = 'CCT';
    uint8 public decimals = 8;
    function CoinCool() Releaseable(0xe8358AfA9Bc309c4A106dc41782340b91817BC64, mulDecimals.mul(3000000)) public {}
}
