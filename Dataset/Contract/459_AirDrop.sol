contract AirDrop is Ownable {
    using SafeMath for uint256;
    uint public airDropAmount;
    mapping ( address => bool ) public invalidAirDrop;
    address[] public arrayAirDropReceivers;
    bool public stop = false;
    ERC20BasicInterface public erc20;
    uint256 public startTime;
    uint256 public endTime;
    event LogAirDrop(address indexed receiver, uint amount);
    event LogStop();
    event LogStart();
    event LogWithdrawal(address indexed receiver, uint amount);
    constructor(uint256 _startTime, uint256 _endTime, uint _airDropAmount, address _tokenAddress) public {
        require(_startTime >= now &&
            _endTime >= _startTime &&
            _airDropAmount > 0 &&
            _tokenAddress != address(0)
        );
        startTime = _startTime;
        endTime = _endTime;
        erc20 = ERC20BasicInterface(_tokenAddress);
        uint tokenDecimals = erc20.decimals();
        airDropAmount = _airDropAmount.mul(10 ** tokenDecimals);
    }
    function isValidAirDropForAll() public view returns (bool) {
        bool validNotStop = !stop;
        bool validAmount = getRemainingToken() >= airDropAmount;
        bool validPeriod = now >= startTime && now <= endTime;
        return validNotStop && validAmount && validPeriod;
    }
    function isValidAirDropForIndividual() public view returns (bool) {
        bool validNotStop = !stop;
        bool validAmount = getRemainingToken() >= airDropAmount;
        bool validPeriod = now >= startTime && now <= endTime;
        bool validReceiveAirDropForIndividual = !invalidAirDrop[msg.sender];
        return validNotStop && validAmount && validPeriod && validReceiveAirDropForIndividual;
    }
    function receiveAirDrop() public {
        require(isValidAirDropForIndividual());
        invalidAirDrop[msg.sender] = true;
        arrayAirDropReceivers.push(msg.sender);
        require(erc20.transfer(msg.sender, airDropAmount));
        emit LogAirDrop(msg.sender, airDropAmount);
    }
    function toggle() public onlyOwner {
        stop = !stop;
        if (stop) {
            emit LogStop();
        } else {
            emit LogStart();
        }
    }
    function withdraw(address _address) public onlyOwner {
        require(stop || now > endTime);
        require(_address != address(0));
        uint tokenBalanceOfContract = getRemainingToken();
        require(erc20.transfer(_address, tokenBalanceOfContract));
        emit LogWithdrawal(_address, tokenBalanceOfContract);
    }
    function getTotalNumberOfAddressesReceivedAirDrop() public view returns (uint256) {
        return arrayAirDropReceivers.length;
    }
    function getRemainingToken() public view returns (uint256) {
        return erc20.balanceOf(this);
    }
    function getTotalAirDroppedAmount() public view returns (uint256) {
        return airDropAmount.mul(arrayAirDropReceivers.length);
    }
}
