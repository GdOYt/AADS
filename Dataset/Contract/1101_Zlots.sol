contract Zlots is ZethrShell {
    using SafeMath for uint;
    event HouseRetrievedTake(
        uint timeTaken,
        uint tokensWithdrawn
    );
    event TokensWagered(
        address _wagerer,
        uint _wagered
    );
    event LogResult(
        address _wagerer,
        uint _result,
        uint _profit,
        uint _wagered,
        uint _category,
        bool _win
    );
    event Loss(address _wagerer, uint _block);                   
    event ThreeMoonJackpot(address _wagerer, uint _block);       
    event TwoMoonPrize(address _wagerer, uint _block);           
    event ZTHPrize(address _wagerer, uint _block);               
    event ThreeZSymbols(address _wagerer, uint _block);          
    event ThreeTSymbols(address _wagerer, uint _block);          
    event ThreeHSymbols(address _wagerer, uint _block);          
    event ThreeEtherIcons(address _wagerer, uint _block);        
    event ThreePurplePyramids(address _wagerer, uint _block);    
    event ThreeGoldPyramids(address _wagerer, uint _block);      
    event ThreeRockets(address _wagerer, uint _block);           
    event OneMoonPrize(address _wagerer, uint _block);           
    event OneOfEachPyramidPrize(address _wagerer, uint _block);  
    event TwoZSymbols(address _wagerer, uint _block);            
    event TwoTSymbols(address _wagerer, uint _block);            
    event TwoHSymbols(address _wagerer, uint _block);            
    event TwoEtherIcons(address _wagerer, uint _block);          
    event TwoPurplePyramids(address _wagerer, uint _block);      
    event TwoGoldPyramids(address _wagerer, uint _block);        
    event TwoRockets(address _wagerer, uint _block);             
    event SpinConcluded(address _wagerer, uint _block);          
    modifier betIsValid(uint _betSize, uint divRate) {
      require(_betSize.mul(100) <= getMaxProfit(divRate));
      _;
    }
    modifier gameIsActive {
      require(gamePaused == false);
      _;
    }
    modifier onlyOwner {
      require(msg.sender == owner); 
      _;
    }
    modifier onlyBankroll {
      require(msg.sender == bankroll);
      _;
    }
    modifier onlyOwnerOrBankroll {
      require(msg.sender == owner || msg.sender == bankroll);
      _;
    }
    uint constant public maxProfitDivisor = 1000000;
    uint constant public houseEdgeDivisor = 1000;
    mapping (uint => uint) public maxProfit;
    uint public maxProfitAsPercentOfHouse;
    uint public minBet = 1e18;
    address public zlotsJackpot;
    address private owner;
    address private bankroll;
    bool gamePaused;
    uint  public totalSpins;
    uint  public totalZTHWagered;
    mapping (uint => uint) public contractBalance;
    mapping(uint => uint) public maxBet;
    bool public gameActive;
    address private ZTHTKNADDR;
    address private ZTHBANKROLL;
    constructor(address BankrollAddress) public {
        setupBankrollInterface(BankrollAddress); 
        owner = msg.sender;
        ownerSetMaxProfitAsPercentOfHouse(50000);
        bankroll      = ZTHBANKROLL;
        gameActive  = true;
        ownerSetMinBet(1e18);
    }
    function() public payable {  }
    struct TKN { address sender; uint value; }
    function execute(address _from, uint _value, uint divRate, bytes  ) public fromBankroll returns (bool){
            TKN memory          _tkn;
            _tkn.sender       = _from;
            _tkn.value        = _value;
            _spinTokens(_tkn, divRate);
            return true;
    }
    struct playerSpin {
        uint200 tokenValue;  
        uint48 blockn;       
        uint8 tier;
    }
    mapping(address => playerSpin) public playerSpins;
    function _spinTokens(TKN _tkn, uint divRate) 
      private 
      betIsValid(_tkn.value, divRate)
    {
        require(gameActive);
        require(1e18 <= _tkn.value);  
        require(_tkn.value < ((2 ** 200) - 1));    
        require(block.number < ((2 ** 56) - 1));   
        address _customerAddress = _tkn.sender;
        uint    _wagered         = _tkn.value;
        playerSpin memory spin = playerSpins[_tkn.sender];
        addContractBalance(divRate, _wagered);
        require(block.number != spin.blockn);
        if (spin.blockn != 0) {
          _finishSpin(_tkn.sender);
        }
        spin.blockn = uint48(block.number);
        spin.tokenValue = uint200(_wagered);
        spin.tier = uint8(ZethrTierLibrary.getTier(divRate));
        playerSpins[_tkn.sender] = spin;
        totalSpins += 1;
        totalZTHWagered += _wagered;
        emit TokensWagered(_customerAddress, _wagered);
    }
    function finishSpin() public
        gameIsActive
        returns (uint)
    {
      return _finishSpin(msg.sender);
    }
    function _finishSpin(address target)
        private returns (uint)
    {
        playerSpin memory spin = playerSpins[target];
        require(spin.tokenValue > 0);  
        require(spin.blockn != block.number);
        uint profit = 0;
        uint category = 0;
        uint result;
        if (block.number - spin.blockn > 255) {
          result = 1000000;  
        } else {
          result = random(1000000, spin.blockn, target) + 1;
        }
        if (result > 476662) {
            RequestBankrollPayment(zlotsJackpot, profit, tier);
            playerSpins[target] = playerSpin(uint200(0), uint48(0), uint8(0));
            emit Loss(target, spin.blockn);
            emit LogResult(target, result, profit, spin.tokenValue, category, false);
        } else if (result < 2) {
            profit = ZlotsJackpotHoldingContract(zlotsJackpot).getJackpot();
            category = 1;
            emit ThreeMoonJackpot(target, spin.blockn);
            emit LogResult(target, result, profit, spin.tokenValue, category, true);
            uint8 tier = spin.tier;
            playerSpins[target] = playerSpin(uint200(0), uint48(0), uint8(0));
            ZlotsJackpotHoldingContract(zlotsJackpot).payOutWinner(target);
        } else {
            if (result < 299) {
                profit = SafeMath.mul(spin.tokenValue, 100);
                category = 2;
                emit TwoMoonPrize(target, spin.blockn);
            } else if (result < 3128) {
                profit = SafeMath.mul(spin.tokenValue, 20);
                category = 3;
                emit ZTHPrize(target, spin.blockn);
            } else if (result < 5957) {
                profit = SafeMath.div(SafeMath.mul(spin.tokenValue, 75), 10);
                category = 4;
                emit ThreeZSymbols(target, spin.blockn);
            } else if (result < 8786) {
                profit = SafeMath.div(SafeMath.mul(spin.tokenValue, 75), 10);
                category = 5;
                emit ThreeTSymbols(target, spin.blockn);
            } else if (result < 11615) {
                profit = SafeMath.div(SafeMath.mul(spin.tokenValue, 75), 10);
                category = 6;
                emit ThreeHSymbols(target, spin.blockn);
            } else if (result < 14444) {
                profit = SafeMath.mul(spin.tokenValue, 15);
                category = 7;
                emit ThreeEtherIcons(target, spin.blockn);
            } else if (result < 17273) {
                profit = SafeMath.mul(spin.tokenValue, 10);
                category = 8;
                emit ThreePurplePyramids(target, spin.blockn);
            } else if (result < 20102) {
                profit = SafeMath.mul(spin.tokenValue, 10);
                category = 9;
                emit ThreeGoldPyramids(target, spin.blockn);
            } else if (result < 22930) {
                profit = SafeMath.mul(spin.tokenValue, 12);
                category = 10;
                emit ThreeRockets(target, spin.blockn);
            } else if (result < 52333) {
                profit = SafeMath.div(SafeMath.mul(spin.tokenValue, 25),10);
                category = 11;
                emit OneMoonPrize(target, spin.blockn);
            } else if (result < 120226) {
                profit = SafeMath.div(SafeMath.mul(spin.tokenValue, 15),10);
                category = 12;
                emit OneOfEachPyramidPrize(target, spin.blockn);
            } else if (result < 171147) {
                profit = spin.tokenValue;
                category = 13;
                 emit TwoZSymbols(target, spin.blockn);
            } else if (result < 222068) {
                profit = spin.tokenValue;
                category = 14;
                emit TwoTSymbols(target, spin.blockn);
            } else if (result < 272989) {
                profit = spin.tokenValue;
                category = 15;
                emit TwoHSymbols(target, spin.blockn);
            } else if (result < 323910) {
                profit = SafeMath.mul(spin.tokenValue, 2);
                category = 16;
                emit TwoEtherIcons(target, spin.blockn);
            } else if (result < 374831) {
                profit = SafeMath.div(SafeMath.mul(spin.tokenValue, 133),100);
                category = 17;
                emit TwoPurplePyramids(target, spin.blockn);
            } else if (result < 425752) {
                profit = SafeMath.div(SafeMath.mul(spin.tokenValue, 133),100);
                category = 18;
                emit TwoGoldPyramids(target, spin.blockn);
            } else {
                profit = SafeMath.mul(spin.tokenValue, 2);
                category = 19;
                emit TwoRockets(target, spin.blockn);
            }
            emit LogResult(target, result, profit, spin.tokenValue, category, true);
            tier = spin.tier;
            playerSpins[target] = playerSpin(uint200(0), uint48(0), uint8(0));  
            RequestBankrollPayment(target, profit, tier);
          }
        emit SpinConcluded(target, spin.blockn);
        return result;
    }   
    function maxRandom(uint blockn, address entropy) private view returns (uint256 randomNumber) {
    return uint256(keccak256(
        abi.encodePacked(
        blockhash(blockn),
        entropy)
      ));
    }
    function random(uint256 upper, uint256 blockn, address entropy) internal view returns (uint256 randomNumber) {
      return maxRandom(blockn, entropy) % upper;
    }
    function setMaxProfit(uint divRate) internal {
      maxProfit[divRate] = (contractBalance[divRate] * maxProfitAsPercentOfHouse) / maxProfitDivisor; 
    } 
    function getMaxProfit(uint divRate) public view returns (uint) {
      return (contractBalance[divRate] * maxProfitAsPercentOfHouse) / maxProfitDivisor;
    }
    function subContractBalance(uint divRate, uint sub) internal {
      contractBalance[divRate] = contractBalance[divRate].sub(sub);
    }
    function addContractBalance(uint divRate, uint add) internal {
      contractBalance[divRate] = contractBalance[divRate].add(add);
    }
    function bankrollExternalUpdateTokens(uint divRate, uint newBalance) 
      public 
      fromBankroll 
    {
      contractBalance[divRate] = newBalance;
      setMaxProfit(divRate);
    }
    function ownerSetMaxProfitAsPercentOfHouse(uint newMaxProfitAsPercent) public
    onlyOwner
    {
      require(newMaxProfitAsPercent <= 200000);
      maxProfitAsPercentOfHouse = newMaxProfitAsPercent;
      setMaxProfit(2);
      setMaxProfit(5);
      setMaxProfit(10);
      setMaxProfit(15); 
      setMaxProfit(20);
      setMaxProfit(25);
      setMaxProfit(33);
    }
    function ownerSetMinBet(uint newMinimumBet) public
    onlyOwner
    {
      minBet = newMinimumBet;
    }
    function ownerSetZlotsAddress(address zlotsAddress) public
    onlyOwner
    {
        zlotsJackpot = zlotsAddress;
    }
    function pauseGame() public onlyOwnerOrBankroll {
        gameActive = false;
    }
    function resumeGame() public onlyOwnerOrBankroll {
        gameActive = true;
    }
    function changeOwner(address _newOwner) public onlyOwnerOrBankroll {
        owner = _newOwner;
    }
    function changeBankroll(address _newBankroll) public onlyOwnerOrBankroll {
        bankroll = _newBankroll;
    }
    function _zthToken(address _tokenContract) private view returns (bool) {
       return _tokenContract == ZTHTKNADDR;
    }
}
