contract MultiTransfer is Ownable {
    ERC20 public tkcAddress;
    function MultiTransfer() public {
    }
    function setTKC(address tkc) public onlyOwner {
        require(tkcAddress == address(0));
        tkcAddress = ERC20(tkc);
    }
    function transfer(address[] to, uint[] value) public onlyOwner {
        require(to.length == value.length);
        for (uint i = 0; i < to.length; i++) {
            tkcAddress.transferFrom(owner, to[i], value[i]);
        }
    }
}
