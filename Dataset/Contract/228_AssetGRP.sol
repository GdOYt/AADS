contract AssetGRP is ERC20Token {
    string public name = 'Gripo';
    uint8 public decimals = 18;
    string public symbol = 'GRP';
    string public version = '1';
    address writer = 0xA6bc924715A0B63C6E0a7653d3262D26F254EcFd;
    constructor() public {
        totalSupply = 200000000 * (10**uint256(decimals)); 
        balances[writer] = totalSupply / 10000; 
        balances[admin] = totalSupply.sub(balances[writer]);
        emit Transfer(address(0), writer, balances[writer]);
        emit Transfer(address(0), admin, balances[admin]);
    }
    function() public {
        revert();
    }
}
