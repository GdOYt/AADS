contract ColdWalletToken is PackageContract {
    address internal coldWalletAddress;
    uint internal percentageCW = 30;
    event CWStorageTransferred(address indexed previousCWAddress, address indexed newCWAddress);
    event CWPercentageChanged(uint previousPCW, uint newPCW);
    function setColdWalletAddress(address _newCWAddress) onlyOwner public {
        require(_newCWAddress != coldWalletAddress && _newCWAddress != address(0));
        CWStorageTransferred(coldWalletAddress, _newCWAddress);
        coldWalletAddress = _newCWAddress;
    }
    function getColdWalletAddress() onlyOwner public view returns (address) {
        return coldWalletAddress;
    }
    function setPercentageCW(uint _newPCW) onlyOwner public {
        require(_newPCW != percentageCW && _newPCW < 100);
        CWPercentageChanged(percentageCW, _newPCW);
        percentageCW = _newPCW;
    }
    function getPercentageCW() onlyOwner public view returns (uint) {
        return percentageCW;
    }
    function saveToCW() onlyOwner public {
        coldWalletAddress.transfer(this.balance.mul(percentageCW).div(100));
    }
}
