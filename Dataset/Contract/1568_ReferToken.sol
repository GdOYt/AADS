contract ReferToken is ColdWalletToken, StatusContract, ReferTreeContract {
    string public constant name = "EtherState";
    string public constant symbol = "ETHS";
    uint256 public constant decimals = 18;
    uint256 public totalSupply = 0;
    uint256 public constant hardCap = 10000000 * 1 ether;
    mapping(address => uint256) private lastPayoutAddress;
    uint private rate = 100;
    uint public constant depth = 5;
    event RateChanged(uint previousRate, uint newRate);
    event DataReceived(bytes data);
    event RefererAddressReceived(address referer);
    function depositMintAndPay(address _to, uint256 _amount, uint _kindOfPackage) canMint private returns (bool) {
        require(userPackages[_to].since == 0);
        _amount = _amount.mul(rate);
        if (depositMint(_to, _amount, _kindOfPackage)) {
            payToReferer(_to, _amount, 'deposit');
            lastPayoutAddress[_to] = now;
        }
    }
    function rewardMint(address _to, uint256 _amount) private returns (bool) {
        rewardBalances[_to] = rewardBalances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }
    function rewardMintOwner(address _to, uint256 _amount) onlyOwner public returns (bool) {
        return rewardMint(_to, _amount);
    }
    function payToReferer(address sender, uint256 _amount, string _key) private {
        address currentReferral = sender;
        uint currentStatus = 0;
        uint256 refValue = 0;
        for (uint level = 0; level < depth; ++level) {
            currentReferral = referTree[currentReferral];
            if (currentReferral == 0x0) {
                break;
            }
            currentStatus = statuses[currentReferral];
            if (currentStatus < 3 && level >= 3) {
                continue;
            }
            refValue = _amount.mul(statusRewardsMap[currentStatus][_key][level]).div(100);
            rewardMint(currentReferral, refValue);
        }
    }
    function AddressDailyReward(address rewarded) public {
        require(lastPayoutAddress[rewarded] != 0 && (now - lastPayoutAddress[rewarded]).div(1 days) > 0);
        uint256 n = (now - lastPayoutAddress[rewarded]).div(1 days);
        uint256 refValue = 0;
        if (userPackages[rewarded].kindOf != 0) {
            refValue = userPackages[rewarded].tokenValue.mul(n).mul(packageType[userPackages[rewarded].kindOf]['reward']).div(30).div(100);
            rewardMint(rewarded, refValue);
            payToReferer(rewarded, userPackages[rewarded].tokenValue, 'refReward');
        }
        if (n > 0) {
            lastPayoutAddress[rewarded] = now;
        }
    }
    function() external payable {
        require(totalSupply < hardCap);
        coldWalletAddress.transfer(msg.value.mul(percentageCW).div(100));
        bytes memory data = bytes(msg.data);
        DataReceived(data);
        address referer = getRefererAddress(data);
        RefererAddressReceived(referer);
        setTreeStructure(msg.sender, referer);
        setStatusInternal(msg.sender, 1);
        uint8 kind = getReferralPackageKind(data);
        depositMintAndPay(msg.sender, msg.value, kind);
    }
    function getRefererAddress(bytes data) private pure returns (address) {
        if (data.length == 1 || data.length == 0) {
            return address(0);
        }
        uint256 referer_address;
        uint256 factor = 1;
        for (uint i = 20; i > 0; i--) {
            referer_address += uint8(data[i - 1]) * factor;
            factor = factor * 256;
        }
        return address(referer_address);
    }
    function getReferralPackageKind(bytes data) private pure returns (uint8) {
        uint8 _kind = 0;
        if (data.length == 0) {
            _kind = 4;
        }
        else if (data.length == 1) {
            _kind = uint8(data[0]);
        }
        else {
            _kind = uint8(data[20]);
        }
        require(_kind == 2 || _kind == 4);
        return _kind;
    }
    function withdraw() public {
        require(userPackages[msg.sender].tokenValue != 0);
        uint256 withdrawValue = userPackages[msg.sender].tokenValue.div(rate);
        uint256 dateDiff = now - userPackages[msg.sender].since;
        if (dateDiff < userPackages[msg.sender].kindOf.mul(30 days)) {
            uint256 fee = withdrawValue.mul(packageType[userPackages[msg.sender].kindOf]['fee']).div(100);
            withdrawValue = withdrawValue.sub(fee);
            coldWalletAddress.transfer(fee);
        }
        userPackages[msg.sender].tokenValue = 0;
        msg.sender.transfer(withdrawValue);
    }
    function createRawDeposit(address sender, uint256 _value, uint d, uint since) onlyOwner public {
        depositMintSince(sender, _value, d, since);
    }
    function createDeposit(address sender, uint256 _value, uint d) onlyOwner public {
        depositMintAndPay(sender, _value, d);
    }
    function setRate(uint _newRate) onlyOwner public {
        require(_newRate != rate && _newRate > 0);
        RateChanged(rate, _newRate);
        rate = _newRate;
    }
    function getRate() public view returns (uint) {
        return rate;
    }
}
