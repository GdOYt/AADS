contract TokenVault is Ownable {
    function withdrawTokenTo(address token, address to, uint amount) public onlyOwner returns (bool) {
        return token.call(bytes4(0xa9059cbb), to, amount);
    }
}
