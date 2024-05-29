contract Crowdsale is owned {
    uint constant totalTokens    = 25000000;
    uint constant neurodaoTokens = 1250000;
    uint constant totalLimitUSD  = 500000;
    uint                         public totalSupply;
    mapping (address => uint256) public balanceOf;
    address                      public neurodao;
    uint                         public etherPrice;
    mapping (address => bool)    public holders;
    mapping (uint => address)    public holdersIter;
    uint                         public numberOfHolders;
    uint                         public collectedUSD;
    address                      public presaleOwner;
    uint                         public collectedNDAO;
    mapping (address => bool)    public gotBonus;
    enum State {Disabled, Presale, Bonuses, Enabled}
    State                        public state;
    modifier enabledState {
        require(state == State.Enabled);
        _;
    }
    event NewState(State _state);
    event Transfer(address indexed from, address indexed to, uint value);
    function Crowdsale(address _neurodao, uint _etherPrice) payable owned() {
        neurodao = _neurodao;
        etherPrice = _etherPrice;
        totalSupply = totalTokens;
        balanceOf[owner] = neurodaoTokens;
        balanceOf[this] = totalSupply - balanceOf[owner];
        Transfer(this, owner, balanceOf[owner]);
    }
    function setEtherPrice(uint _etherPrice) public {
        require(presaleOwner == msg.sender || owner == msg.sender);
        etherPrice = _etherPrice;
    }
    function startPresale(address _presaleOwner) public onlyOwner {
        require(state == State.Disabled);
        presaleOwner = _presaleOwner;
        state = State.Presale;
        NewState(state);
    }
    function startBonuses() public onlyOwner {
        require(state == State.Presale);
        state = State.Bonuses;
        NewState(state);
    }
    function finishCrowdsale() public onlyOwner {
        require(state == State.Bonuses);
        state = State.Enabled;
        NewState(state);
    }
    function () payable {
        uint tokens;
        address tokensSource;
        if (state == State.Presale) {
            require(balanceOf[this] > 0);
            require(collectedUSD < totalLimitUSD);
            uint valueWei = msg.value;
            uint valueUSD = valueWei * etherPrice / 1 ether;
            if (collectedUSD + valueUSD > totalLimitUSD) {
                valueUSD = totalLimitUSD - collectedUSD;
                valueWei = valueUSD * 1 ether / etherPrice;
                require(msg.sender.call.gas(3000000).value(msg.value - valueWei)());
                collectedUSD = totalLimitUSD;
            } else {
                collectedUSD += valueUSD;
            }
            uint centsForToken;
            if (now <= 1506815999) {         
                centsForToken = 50;
            } else if (now <= 1507247999) {  
                centsForToken = 50;
            } else if (now <= 1507766399) {  
                centsForToken = 65;
            } else {
                centsForToken = 70;
            }
            tokens = valueUSD * 100 / centsForToken;
            if (NeuroDAO(neurodao).balanceOf(msg.sender) >= 1000) {
                collectedNDAO += tokens;
            }
            tokensSource = this;
        } else if (state == State.Bonuses) {
            require(gotBonus[msg.sender] != true);
            gotBonus[msg.sender] = true;
            uint freezedBalance = NeuroDAO(neurodao).freezedBalanceOf(msg.sender);
            if (freezedBalance >= 1000) {
                tokens = (neurodaoTokens / 10) * freezedBalance / 21000000 + (9 * neurodaoTokens / 10) * balanceOf[msg.sender] / collectedNDAO;                
            }
            tokensSource = owner;
        }        
        require(tokens > 0);
        require(balanceOf[msg.sender] + tokens > balanceOf[msg.sender]);
        require(balanceOf[tokensSource] >= tokens);        
        if (holders[msg.sender] != true) {
            holders[msg.sender] = true;
            holdersIter[numberOfHolders++] = msg.sender;
        }
        balanceOf[msg.sender] += tokens;
        balanceOf[tokensSource] -= tokens;
        Transfer(tokensSource, msg.sender, tokens);
    }
}
