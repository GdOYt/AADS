contract controllable is Ownable {
    event AddToBlacklist(address _addr);
    event DeleteFromBlacklist(address _addr);
    mapping (address => bool) internal blacklist;  
    function addtoblacklist(address _addr) public onlyOwner {
        blacklist[_addr] = true;
        emit AddToBlacklist(_addr);
    }
    function deletefromblacklist(address _addr) public onlyOwner {
        blacklist[_addr] = false;
        emit DeleteFromBlacklist(_addr);
    }
    function isBlacklist(address _addr) public view returns(bool) {
        return blacklist[_addr];
    }
}
