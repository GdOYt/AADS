contract SalesManagerUpgradable is Ownable {
    using SafeMath for uint256;
    address public ethOwner = 0xe8290a10565CB7aDeE9246661B34BB77CB6e4024;
    uint public price1 = 100;
    uint public price2 = 110;
    uint public price3 = 125;
    uint public lev1 = 2 ether;
    uint public lev2 = 10 ether;
    uint public ethFundRaised;
    address public tokenAddress;
    function SalesManagerUpgradable () public {
        tokenAddress = new AirEX(5550000 ether);
    }
    function () payable public {
        if(msg.value > 0) revert();
    }
    function buyTokens(address _investor) public payable returns (bool){
        if (msg.value <= lev1) {
            uint tokens = msg.value.mul(price1);
            if (!sendTokens(tokens, msg.value, _investor)) revert();
            return true;
        } else if (msg.value > lev1 && msg.value <= lev2) {
            tokens = msg.value.mul(price2);
            if (!sendTokens(tokens, msg.value, _investor)) revert();
            return true;
        } else if (msg.value > lev2) {
            tokens = msg.value.mul(price3);
            if (!sendTokens(tokens, msg.value, _investor)) revert();
            return true;
        }
        return false;
    }
    function sendTokens(uint _amount, uint _ethers, address _investor) private returns (bool) {
        AirEX tokenHolder = AirEX(tokenAddress);
        if (tokenHolder.mint(_investor, _amount)) {
            ethFundRaised = ethFundRaised.add(_ethers);
            ethOwner.transfer(_ethers);
            return true;
        }
        return false;
    }
    function generateTokensManually(uint _amount, address _to) public onlyOwner {
        AirEX tokenHolder = AirEX(tokenAddress);
        tokenHolder.mint(_to, _amount);
    }
    function setColdAddress(address _newAddr) public onlyOwner {
        ethOwner = _newAddr;
    }
    function setPrice1 (uint _price) public onlyOwner {
        price1 = _price;
    }
    function setPrice2 (uint _price) public onlyOwner {
        price2 = _price;
    }
    function setPrice3 (uint _price) public onlyOwner {
        price3 = _price;
    }
    function setLev1 (uint _price) public onlyOwner {
        lev1 = _price;
    }
    function setLev2 (uint _price) public onlyOwner {
        lev2 = _price;
    }
    function transferOwnershipToken(address newTokenOwnerAddress) public onlyOwner {
        AirEX tokenContract = AirEX(tokenAddress);
        tokenContract.transferOwnership(newTokenOwnerAddress);
    }
    function updateHardCap(uint256 _cap) public onlyOwner {
        AirEX tokenContract = AirEX(tokenAddress);
        tokenContract.updateHardCap(_cap);
    }
    function updateSoftCap(uint256 _cap) public onlyOwner {
        AirEX tokenContract = AirEX(tokenAddress);
        tokenContract.updateSoftCap(_cap);
    }
    function unPauseContract() public onlyOwner {
        AirEX tokenContract = AirEX(tokenAddress);
        tokenContract.unpause();
    }
    function pauseContract() public onlyOwner {
        AirEX tokenContract = AirEX(tokenAddress);
        tokenContract.pause();
    }
    function finishMinting() public onlyOwner {
        AirEX tokenContract = AirEX(tokenAddress);
        tokenContract.finishMinting();
    }
    function drop(address[] _destinations, uint256[] _amount) onlyOwner public
    returns (uint) {
        uint i = 0;
        while (i < _destinations.length) {
           AirEX(tokenAddress).mint(_destinations[i], _amount[i]);
           i += 1;
        }
        return(i);
    }
    function withdraw(address _to) public onlyOwner {
        _to.transfer(this.balance);
    }
    function destroySalesManager(address _recipient) public onlyOwner {
        selfdestruct(_recipient);
    }
}
