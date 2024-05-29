contract Crowdsale is Pausable, Withdrawable, ERC223Receiving {
    using SafeMath for uint;
    struct Step {
        uint priceTokenWei;
        uint tokensForSale;
        uint minInvestEth;
        uint tokensSold;
        uint collectedWei;
        bool transferBalance;
        bool sale;
    }
    Token public token;
    address public beneficiary = 0x4ae7bdf9530cdB666FC14DF79C169e14504c621A;
    Step[] public steps;
    uint8 public currentStep = 0;
    bool public crowdsaleClosed = false;
    mapping(address => uint256) public canSell;
    event Purchase(address indexed holder, uint256 tokenAmount, uint256 etherAmount);
    event Sell(address indexed holder, uint256 tokenAmount, uint256 etherAmount);
    event NewRate(uint256 rate);
    event NextStep(uint8 step);
    event CrowdsaleClose();
    function Crowdsale() public {
        token = new Token();
        steps.push(Step(1 ether / 1000, 1000000 * 1 ether, 0.01 ether, 0, 0, true, false));
        steps.push(Step(1 ether / 1000, 1500000 * 1 ether, 0.01 ether, 0, 0, true, false));
        steps.push(Step(1 ether / 1000, 3000000 * 1 ether, 0.01 ether, 0, 0, true, false));
        steps.push(Step(1 ether / 1000, 9000000 * 1 ether, 0.01 ether, 0, 0, true, false));
        steps.push(Step(1 ether / 1000, 35000000 * 1 ether, 0.01 ether, 0, 0, true, false));
        steps.push(Step(1 ether / 1000, 20500000 * 1 ether, 0.01 ether, 0, 0, true, true));
    }
    function() payable public {
        purchase();
    }
    function tokenFallback(address _from, uint256 _value, bytes _data) external {
        sell(_value);
    }
    function setTokenRate(uint _value) onlyOwner public {
        require(!crowdsaleClosed);
        steps[currentStep].priceTokenWei = 1 ether / _value;
        NewRate(steps[currentStep].priceTokenWei);
    }
    function purchase() whenNotPaused payable public {
        require(!crowdsaleClosed);
        Step memory step = steps[currentStep];
        require(msg.value >= step.minInvestEth);
        require(step.tokensSold < step.tokensForSale);
        uint sum = msg.value;
        uint amount = sum.mul(1 ether).div(step.priceTokenWei);
        uint retSum = 0;
        if(step.tokensSold.add(amount) > step.tokensForSale) {
            uint retAmount = step.tokensSold.add(amount).sub(step.tokensForSale);
            retSum = retAmount.mul(step.priceTokenWei).div(1 ether);
            amount = amount.sub(retAmount);
            sum = sum.sub(retSum);
        }
        steps[currentStep].tokensSold = step.tokensSold.add(amount);
        steps[currentStep].collectedWei = step.collectedWei.add(sum);
        if(currentStep == 0) {
            canSell[msg.sender] = canSell[msg.sender].add(amount);
        }
        if(step.transferBalance) {
            uint p1 = sum.div(200);
            (0xD8C7f2215f90463c158E91b92D81f0A1E3187C1B).transfer(p1.mul(3));
            (0x8C8d80effb2c5C1E4D857e286822E0E641cA3836).transfer(p1.mul(3));
            beneficiary.transfer(sum.sub(p1.mul(6)));
        }
        token.mint(msg.sender, amount);
        if(retSum > 0) {
            msg.sender.transfer(retSum);
        }
        Purchase(msg.sender, amount, sum);
    }
    function sell(uint256 _value) whenNotPaused public {
        require(!crowdsaleClosed);
        require(canSell[msg.sender] >= _value);
        require(token.balanceOf(msg.sender) >= _value);
        Step memory step = steps[currentStep];
        require(step.sale);
        canSell[msg.sender] = canSell[msg.sender].sub(_value);
        token.call('transfer', beneficiary, _value);
        uint sum = _value.mul(step.priceTokenWei).div(1 ether);
        msg.sender.transfer(sum);
        Sell(msg.sender, _value, sum);
    }
    function nextStep(uint _value) onlyOwner public {
        require(!crowdsaleClosed);
        require(steps.length - 1 > currentStep);
        currentStep += 1;
        setTokenRate(_value);
        NextStep(currentStep);
    }
    function closeCrowdsale() onlyOwner public {
        require(!crowdsaleClosed);
        beneficiary.transfer(this.balance);
        token.mint(beneficiary, token.cap().sub(token.totalSupply()));
        token.transferOwnership(beneficiary);
        crowdsaleClosed = true;
        CrowdsaleClose();
    }
}
