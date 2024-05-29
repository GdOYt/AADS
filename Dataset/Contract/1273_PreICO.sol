contract PreICO is Ownable, ERC223ReceivingContract {
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
    uint256 public totalSold = 0;
    uint256 public forSale = 350000e3;  
    DatePeriod public salePeriod;
    ICOToken internal token;
    Beneficiary[] internal beneficiaries;
    constructor(ICOToken _token, uint256 _startTime, uint256 _endTime) public {
        token = _token;
        salePeriod.start = _startTime;
        salePeriod.end = _endTime;
        addBeneficiary(0x7ADCE5a8CDC22b65A07b29Fb9F90ebe16F450aB1, 200 ether);
        addBeneficiary(0xa406b97666Ea3D2093bDE9644794F8809B0F58Cc, 300 ether);
        addBeneficiary(0x3Be990A4031D6A6a9f44c686ccD8B194Bdeea790, 200 ether);
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
        uint256 reward = purchased.multiply(30).divide(100);  
        if (toReturn > 0) {
            msg.sender.transfer(toReturn);
        }
        token.transfer(msg.sender, purchased.add(reward));
        allocateFunds();
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
    function withdrawFunds(address wallet) public onlyOwner afterEnd {
        uint256 balance = address(this).balance;
        require(balance > 0);
        wallet.transfer(balance);
    }
    function allocateFunds() internal {
        uint256 balance = address(this).balance;
        uint length = beneficiaries.length;
        uint256 toTransfer = 0;
        for (uint i = 0; i < length; i++) {
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
}
