contract NamiPool {
    using SafeMath for uint256;
    function NamiPool(address _escrow, address _namiMultiSigWallet, address _namiAddress) public {
        require(_namiMultiSigWallet != 0x0);
        escrow = _escrow;
        namiMultiSigWallet = _namiMultiSigWallet;
        NamiAddr = _namiAddress;
    }
    string public name = "Nami Pool";
    address public escrow;
    address public namiMultiSigWallet;
    address public NamiAddr;
    modifier onlyEscrow() {
        require(msg.sender == escrow);
        _;
    }
    modifier onlyNami {
        require(msg.sender == NamiAddr);
        _;
    }
    modifier onlyNamiMultisig {
        require(msg.sender == namiMultiSigWallet);
        _;
    }
    uint public currentRound = 1;
    struct ShareHolder {
        uint stake;
        bool isActive;
        bool isWithdrawn;
    }
    struct Round {
        bool isOpen;
        uint currentNAC;
        uint finalNAC;
        uint ethBalance;
        bool withdrawable;  
        bool topWithdrawable;
        bool isCompleteActive;
        bool isCloseEthPool;
    }
    mapping (uint => mapping (address => ShareHolder)) public namiPool;
    mapping (uint => Round) public round;
    event UpdateShareHolder(address indexed ShareHolderAddress, uint indexed RoundIndex, uint Stake, uint Time);
    event Deposit(address sender,uint indexed RoundIndex, uint value);
    event WithdrawPool(uint Amount, uint TimeWithdraw);
    event UpdateActive(address indexed ShareHolderAddress, uint indexed RoundIndex, bool Status, uint Time);
    event Withdraw(address indexed ShareHolderAddress, uint indexed RoundIndex, uint Ether, uint Nac, uint TimeWithdraw);
    event ActivateRound(uint RoundIndex, uint TimeActive);
    function changeEscrow(address _escrow)
        onlyNamiMultisig
        public
    {
        require(_escrow != 0x0);
        escrow = _escrow;
    }
    function withdrawEther(uint _amount) public
        onlyEscrow
    {
        require(namiMultiSigWallet != 0x0);
        if (this.balance > 0) {
            namiMultiSigWallet.transfer(_amount);
        }
    }
    function withdrawNAC(uint _amount) public
        onlyEscrow
    {
        require(namiMultiSigWallet != 0x0 && _amount != 0);
        NamiCrowdSale namiToken = NamiCrowdSale(NamiAddr);
        if (namiToken.balanceOf(this) > 0) {
            namiToken.transfer(namiMultiSigWallet, _amount);
        }
    }
    function activateRound(uint _roundIndex) 
        onlyEscrow
        public
    {
        require(round[_roundIndex].isOpen == false && round[_roundIndex].isCloseEthPool == false && round[_roundIndex].isCompleteActive == false);
        round[_roundIndex].isOpen = true;
        currentRound = _roundIndex;
        ActivateRound(_roundIndex, now);
    }
    function deactivateRound(uint _roundIndex)
        onlyEscrow
        public
    {
        require(round[_roundIndex].isOpen == true);
        round[_roundIndex].isOpen = false;
    }
    function tokenFallbackExchange(address _from, uint _value, uint _price) onlyNami public returns (bool success) {
        require(round[_price].isOpen == true && _value > 0);
        namiPool[_price][_from].stake = namiPool[_price][_from].stake.add(_value);
        round[_price].currentNAC = round[_price].currentNAC.add(_value);
        UpdateShareHolder(_from, _price, namiPool[_price][_from].stake, now);
        return true;
    }
    function activateUser(address _shareAddress, uint _roundId)
        onlyEscrow
        public
    {
        require(namiPool[_roundId][_shareAddress].isActive == false && namiPool[_roundId][_shareAddress].stake > 0);
        require(round[_roundId].isCompleteActive == false && round[_roundId].isOpen == false);
        namiPool[_roundId][_shareAddress].isActive = true;
        round[_roundId].finalNAC = round[_roundId].finalNAC.add(namiPool[_roundId][_shareAddress].stake);
        UpdateActive(_shareAddress, _roundId ,namiPool[_roundId][_shareAddress].isActive, now);
    }
    function deactivateUser(address _shareAddress, uint _roundId)
        onlyEscrow
        public
    {
        require(namiPool[_roundId][_shareAddress].isActive == true && namiPool[_roundId][_shareAddress].stake > 0);
        require(round[_roundId].isCompleteActive == false && round[_roundId].isOpen == false);
        namiPool[_roundId][_shareAddress].isActive = false;
        round[_roundId].finalNAC = round[_roundId].finalNAC.sub(namiPool[_roundId][_shareAddress].stake);
        UpdateActive(_shareAddress, _roundId ,namiPool[_roundId][_shareAddress].isActive, now);
    }
    function closeActive(uint _roundId)
        onlyEscrow
        public
    {
        require(round[_roundId].isCompleteActive == false && round[_roundId].isOpen == false);
        round[_roundId].isCompleteActive = true;
    }
    function changeWithdrawable(uint _roundIndex)
        onlyEscrow
        public
    {
        require(round[_roundIndex].isCompleteActive == true && round[_roundIndex].isOpen == false);
        round[_roundIndex].withdrawable = !round[_roundIndex].withdrawable;
    }
    function changeTopWithdrawable(uint _roundIndex)
        onlyEscrow
        public
    {
        require(round[_roundIndex].isCompleteActive == true && round[_roundIndex].isOpen == false);
        round[_roundIndex].topWithdrawable = !round[_roundIndex].topWithdrawable;
    }
    function depositEthPool(uint _roundIndex)
        payable public
        onlyEscrow
    {
        require(msg.value > 0 && round[_roundIndex].isCloseEthPool == false && round[_roundIndex].isOpen == false);
        if (msg.value > 0) {
            round[_roundIndex].ethBalance = round[_roundIndex].ethBalance.add(msg.value);
            Deposit(msg.sender, _roundIndex, msg.value);
        }
    }
    function withdrawEthPool(uint _roundIndex, uint _amount)
        public
        onlyEscrow
    {
        require(round[_roundIndex].isCloseEthPool == false && round[_roundIndex].isOpen == false);
        require(namiMultiSigWallet != 0x0);
        if (_amount > 0) {
            namiMultiSigWallet.transfer(_amount);
            round[_roundIndex].ethBalance = round[_roundIndex].ethBalance.sub(_amount);
            WithdrawPool(_amount, now);
        }
    }
    function closeEthPool(uint _roundIndex)
        public
        onlyEscrow
    {
        require(round[_roundIndex].isCloseEthPool == false && round[_roundIndex].isCompleteActive == true && round[_roundIndex].isOpen == false);
        round[_roundIndex].isCloseEthPool = true;
    }
    function _withdrawNAC(address _shareAddress, uint _roundIndex) internal {
        require(namiPool[_roundIndex][_shareAddress].stake > 0);
        NamiCrowdSale namiToken = NamiCrowdSale(NamiAddr);
        uint previousBalances = namiToken.balanceOf(this);
        namiToken.transfer(_shareAddress, namiPool[_roundIndex][_shareAddress].stake);
        round[_roundIndex].currentNAC = round[_roundIndex].currentNAC.sub(namiPool[_roundIndex][_shareAddress].stake);
        namiPool[_roundIndex][_shareAddress].stake = 0;
        assert(previousBalances > namiToken.balanceOf(this));
    }
    function withdrawTopForTeam(address _shareAddress, uint _roundIndex)
        onlyEscrow
        public
    {
        require(round[_roundIndex].isCompleteActive == true && round[_roundIndex].isCloseEthPool == true && round[_roundIndex].isOpen == false);
        require(round[_roundIndex].topWithdrawable);
        if(namiPool[_roundIndex][_shareAddress].isActive == true) {
            require(namiPool[_roundIndex][_shareAddress].isWithdrawn == false);
            assert(round[_roundIndex].finalNAC > namiPool[_roundIndex][_shareAddress].stake);
            uint ethReturn = (round[_roundIndex].ethBalance.mul(namiPool[_roundIndex][_shareAddress].stake)).div(round[_roundIndex].finalNAC);
            _shareAddress.transfer(ethReturn);
            namiPool[_roundIndex][_shareAddress].isWithdrawn = true;
            Withdraw(_shareAddress, _roundIndex, ethReturn, namiPool[_roundIndex][_shareAddress].stake, now);
            _withdrawNAC(_shareAddress, _roundIndex);
        }
    }
    function withdrawNonTopForTeam(address _shareAddress, uint _roundIndex)
        onlyEscrow
        public
    {
        require(round[_roundIndex].isCompleteActive == true && round[_roundIndex].isOpen == false);
        require(round[_roundIndex].withdrawable);
        if(namiPool[_roundIndex][_shareAddress].isActive == false) {
            require(namiPool[_roundIndex][_shareAddress].isWithdrawn == false);
            namiPool[_roundIndex][_shareAddress].isWithdrawn = true;
            Withdraw(_shareAddress, _roundIndex, 0, namiPool[_roundIndex][_shareAddress].stake, now);
            _withdrawNAC(_shareAddress, _roundIndex);
        }
    }
    function withdrawTop(uint _roundIndex)
        public
    {
        require(round[_roundIndex].isCompleteActive == true && round[_roundIndex].isCloseEthPool == true && round[_roundIndex].isOpen == false);
        require(round[_roundIndex].topWithdrawable);
        if(namiPool[_roundIndex][msg.sender].isActive == true) {
            require(namiPool[_roundIndex][msg.sender].isWithdrawn == false);
            uint ethReturn = (round[_roundIndex].ethBalance.mul(namiPool[_roundIndex][msg.sender].stake)).div(round[_roundIndex].finalNAC);
            msg.sender.transfer(ethReturn);
            namiPool[_roundIndex][msg.sender].isWithdrawn = true;
            Withdraw(msg.sender, _roundIndex, ethReturn, namiPool[_roundIndex][msg.sender].stake, now);
            _withdrawNAC(msg.sender, _roundIndex);
        }
    }
    function withdrawNonTop(uint _roundIndex)
        public
    {
        require(round[_roundIndex].isCompleteActive == true && round[_roundIndex].isOpen == false);
        require(round[_roundIndex].withdrawable);
        if(namiPool[_roundIndex][msg.sender].isActive == false) {
            require(namiPool[_roundIndex][msg.sender].isWithdrawn == false);
            namiPool[_roundIndex][msg.sender].isWithdrawn = true;
            Withdraw(msg.sender, _roundIndex, 0, namiPool[_roundIndex][msg.sender].stake, now);
            _withdrawNAC(msg.sender, _roundIndex);
        }
    }
}
