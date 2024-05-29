contract NamiExchange {
    using SafeMath for uint;
    function NamiExchange(address _namiAddress) public {
        NamiAddr = _namiAddress;
    }
    event UpdateBid(address owner, uint price, uint balance);
    event UpdateAsk(address owner, uint price, uint volume);
    event BuyHistory(address indexed buyer, address indexed seller, uint price, uint volume, uint time);
    event SellHistory(address indexed seller, address indexed buyer, uint price, uint volume, uint time);
    mapping(address => OrderBid) public bid;
    mapping(address => OrderAsk) public ask;
    string public name = "NacExchange";
    address public NamiAddr;
    uint public price = 1;
    struct OrderBid {
        uint price;
        uint eth;
    }
    struct OrderAsk {
        uint price;
        uint volume;
    }
    function() payable public {
        require(msg.data.length != 0);
        require(msg.value == 0);
    }
    modifier onlyNami {
        require(msg.sender == NamiAddr);
        _;
    }
    function placeBuyOrder(uint _price) payable public {
        require(_price > 0 && msg.value > 0 && bid[msg.sender].eth == 0);
        if (msg.value > 0) {
            bid[msg.sender].eth = (bid[msg.sender].eth).add(msg.value);
            bid[msg.sender].price = _price;
            UpdateBid(msg.sender, _price, bid[msg.sender].eth);
        }
    }
    function sellNac(uint _value, address _buyer, uint _price) public returns (bool success) {
        require(_price == bid[_buyer].price && _buyer != msg.sender);
        NamiCrowdSale namiToken = NamiCrowdSale(NamiAddr);
        uint ethOfBuyer = bid[_buyer].eth;
        uint maxToken = ethOfBuyer.mul(bid[_buyer].price);
        require(namiToken.allowance(msg.sender, this) >= _value && _value > 0 && ethOfBuyer != 0 && _buyer != 0x0);
        if (_value > maxToken) {
            if (msg.sender.send(ethOfBuyer) && namiToken.transferFrom(msg.sender,_buyer,maxToken)) {
                bid[_buyer].eth = 0;
                UpdateBid(_buyer, bid[_buyer].price, bid[_buyer].eth);
                BuyHistory(_buyer, msg.sender, bid[_buyer].price, maxToken, now);
                return true;
            } else {
                revert();
            }
        } else {
            uint eth = _value.div(bid[_buyer].price);
            if (msg.sender.send(eth) && namiToken.transferFrom(msg.sender,_buyer,_value)) {
                bid[_buyer].eth = (bid[_buyer].eth).sub(eth);
                UpdateBid(_buyer, bid[_buyer].price, bid[_buyer].eth);
                BuyHistory(_buyer, msg.sender, bid[_buyer].price, _value, now);
                return true;
            } else {
                revert();
            }
        }
    }
    function closeBidOrder() public {
        require(bid[msg.sender].eth > 0 && bid[msg.sender].price > 0);
        msg.sender.transfer(bid[msg.sender].eth);
        bid[msg.sender].eth = 0;
        UpdateBid(msg.sender, bid[msg.sender].price, bid[msg.sender].eth);
    }
    function tokenFallbackExchange(address _from, uint _value, uint _price) onlyNami public returns (bool success) {
        require(_price > 0 && _value > 0 && ask[_from].volume == 0);
        if (_value > 0) {
            ask[_from].volume = (ask[_from].volume).add(_value);
            ask[_from].price = _price;
            UpdateAsk(_from, _price, ask[_from].volume);
        }
        return true;
    }
    function closeAskOrder() public {
        require(ask[msg.sender].volume > 0 && ask[msg.sender].price > 0);
        NamiCrowdSale namiToken = NamiCrowdSale(NamiAddr);
        uint previousBalances = namiToken.balanceOf(msg.sender);
        namiToken.transfer(msg.sender, ask[msg.sender].volume);
        ask[msg.sender].volume = 0;
        UpdateAsk(msg.sender, ask[msg.sender].price, 0);
        assert(previousBalances < namiToken.balanceOf(msg.sender));
    }
    function buyNac(address _seller, uint _price) payable public returns (bool success) {
        require(msg.value > 0 && ask[_seller].volume > 0 && ask[_seller].price > 0);
        require(_price == ask[_seller].price && _seller != msg.sender);
        NamiCrowdSale namiToken = NamiCrowdSale(NamiAddr);
        uint maxEth = (ask[_seller].volume).div(ask[_seller].price);
        uint previousBalances = namiToken.balanceOf(msg.sender);
        if (msg.value > maxEth) {
            if (_seller.send(maxEth) && msg.sender.send(msg.value.sub(maxEth))) {
                namiToken.transfer(msg.sender, ask[_seller].volume);
                SellHistory(_seller, msg.sender, ask[_seller].price, ask[_seller].volume, now);
                ask[_seller].volume = 0;
                UpdateAsk(_seller, ask[_seller].price, 0);
                assert(previousBalances < namiToken.balanceOf(msg.sender));
                return true;
            } else {
                revert();
            }
        } else {
            uint nac = (msg.value).mul(ask[_seller].price);
            if (_seller.send(msg.value)) {
                namiToken.transfer(msg.sender, nac);
                ask[_seller].volume = (ask[_seller].volume).sub(nac);
                UpdateAsk(_seller, ask[_seller].price, ask[_seller].volume);
                SellHistory(_seller, msg.sender, ask[_seller].price, nac, now);
                assert(previousBalances < namiToken.balanceOf(msg.sender));
                return true;
            } else {
                revert();
            }
        }
    }
}
