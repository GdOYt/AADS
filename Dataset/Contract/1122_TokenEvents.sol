contract TokenEvents {
    event LogBurn(address indexed src, uint256 wad);
    event LogMint(address indexed src, uint256 wad);
    event LogLogicReplaced(address newLogic);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
