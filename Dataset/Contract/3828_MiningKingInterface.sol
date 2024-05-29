contract MiningKingInterface {
    function getKing() public returns (address);
    function transferKing(address newKing) public;
    event TransferKing(address from, address to);
}
