contract ICO is Ownable, ERC223ReceivingContract {
    using SafeMath for uint256;
    struct DatePeriod {
        uint256 start;
        uint256 end;
    }
    struct Beneficiary {
        address wallet;
        uint256 transferred;
        uint256 toTransfer;
    }
    uint256 public price = 0.002 ether / 1e3;
    uint256 public minPurchase = 0.01 ether;
    mapping(address => uint256) buyers;
    uint256 public totalSold = 0;
    uint256 public forSale = 25000000e3;  
    uint256 public softCap = 2500000e3;  
    DatePeriod public salePeriod;
    ICOToken internal token;
    Beneficiary[] internal beneficiaries;
    constructor(ICOToken _token, uint256 _startTime, uint256 _endTime) public {
        token = _token;
        salePeriod.start = _startTime;
        salePeriod.end = _endTime;
        addBeneficiary(0x1f7672D49eEEE0dfEB971207651A42392e0ed1c5, 5000 ether);
        addBeneficiary(0x7ADCE5a8CDC22b65A07b29Fb9F90ebe16F450aB1, 15000 ether);
        addBeneficiary(0xa406b97666Ea3D2093bDE9644794F8809B0F58Cc, 10000 ether);
        addBeneficiary(0x3Be990A4031D6A6a9f44c686ccD8B194Bdeea790, 10000 ether);
        addBeneficiary(0x80E94901ba1f6661A75aFC19f6E2A6CEe29Ff77a, 10000 ether);
    }
    function () public isRunning payable {
        require(msg.value >= minPurchase);
        uint256 unsold = forSale.subtract(totalSold);
        uint256 paid = msg.value;
        uint256 purchased = paid.divide(price);
        if (purchased > unsold) {
            purchased = unsold;
        }
        uint256 toReturn = paid.subtract(purchased.multiply(price));
        uint256 reward = calculateReward(totalSold, purchased);
        if (toReturn > 0) {
            msg.sender.transfer(toReturn);
        }
        token.transfer(msg.sender, purchased.add(reward));
        allocateFunds();
        buyers[msg.sender] = buyers[msg.sender].add(paid.subtract(toReturn));
        totalSold = totalSold.add(purchased);
    }
    modifier isRunning() {
        require(now >= salePeriod.start);
        require(now <= salePeriod.end);
        _;
    }
    modifier afterEnd() {
        require(now > salePeriod.end);
        _;
    }
    function burnUnsold() public onlyOwner afterEnd {
        uint256 unsold = token.balanceOf(address(this));
        token.burn(unsold);
    }
    function changeStartTime(uint256 _startTime) public onlyOwner {
        salePeriod.start = _startTime;
    }
    function changeEndTime(uint256 _endTime) public onlyOwner {
        salePeriod.end = _endTime;
    }
    function tokenFallback(address _from, uint256 _value, bytes _data) public {
        if (msg.sender != address(token)) {
            revert();
        }
        if (_from != owner) {
            revert();
        }
    }
    function withdrawFunds() public afterEnd {
        if (msg.sender == owner) {
            require(totalSold >= softCap);
            Beneficiary memory beneficiary = beneficiaries[0];
            beneficiary.wallet.transfer(address(this).balance);
        } else {
            require(totalSold < softCap);
            require(buyers[msg.sender] > 0);
            buyers[msg.sender] = 0;
            msg.sender.transfer(buyers[msg.sender]);
        }
    }
    function allocateFunds() internal {
        if (totalSold < softCap) {
            return;
        }
        uint256 balance = address(this).balance - 5000 ether;
        uint length = beneficiaries.length;
        uint256 toTransfer = 0;
        for (uint i = 1; i < length; i++) {
            Beneficiary storage beneficiary = beneficiaries[i];
            toTransfer = beneficiary.toTransfer.subtract(beneficiary.transferred);
            if (toTransfer > 0) {
                if (toTransfer > balance) {
                    toTransfer = balance;
                }
                beneficiary.wallet.transfer(toTransfer);
                beneficiary.transferred = beneficiary.transferred.add(toTransfer);
                break;
            }
        }
    }
    function addBeneficiary(address _wallet, uint256 _toTransfer) internal {
        beneficiaries.push(Beneficiary({
            wallet: _wallet,
            transferred: 0,
            toTransfer: _toTransfer
            }));
    }
    function calculateReward(uint256 _sold, uint256 _purchased) internal pure returns (uint256) {
        uint256 reward = 0;
        uint256 step = 0;
        uint256 firstPart = 0;
        uint256 nextPart = 0;
        for (uint8 i = 1; i <= 4; i++) {
            step = 5000000e2 * i;
            if (_sold < step) {
                if (_purchased.add(_sold) > step) {
                    nextPart = _purchased.add(_sold).subtract(step);
                    firstPart = _purchased.subtract(nextPart);
                    reward = reward.add(nextPart.multiply(20 - 5*i).divide(100));
                } else {
                    firstPart = _purchased;
                }
                reward = reward.add(firstPart.multiply(20 - 5*(i - 1)).divide(100));
                break;
            }
        }
        return reward;
    }
}
