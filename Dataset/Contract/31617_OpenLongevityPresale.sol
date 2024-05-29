contract OpenLongevityPresale is PresaleToken {
    function OpenLongevityPresale() payable public PresaleToken() {}
    function killMe() public onlyOwner {
        selfdestruct(owner);
    }
}
