contract DEXified is ERC20 {
    using SafeMath for uint;
    struct Sales {
        address[] items;
        mapping(address => uint) lookup;
    }
    struct Offer {
        uint256 tokens;
        uint256 price;
    }
    mapping(address => Offer) exchange;
    uint256 public market = 0;
    Sales internal sales;
    function sellers(uint index) public view returns (address) {
        return sales.items[index];
    }
    function getOffer(address _owner) public view returns (uint256[2]) {
        Offer storage offer = exchange[_owner];
        return ([offer.price , offer.tokens]);
    }
    function addSeller(address item) private {
        if (sales.lookup[item] > 0) {
            return;
        }
        sales.lookup[item] = sales.items.push(item);
    }
    function removeSeller(address item) private {
        uint index = sales.lookup[item];
        if (index == 0) {
            return;
        }
        if (index < sales.items.length) {
            address lastItem = sales.items[sales.items.length - 1];
            sales.items[index - 1] = lastItem;
            sales.lookup[lastItem] = index;
        }
        sales.items.length -= 1;
        delete sales.lookup[item];
    }
    function setOffer(address _owner, uint256 _price, uint256 _value) internal {
        exchange[_owner].price = _price;
        market =  market.sub(exchange[_owner].tokens);
        exchange[_owner].tokens = _value;
        market =  market.add(_value);
        if (_value == 0) {
            removeSeller(_owner);
        }
        else {
            addSeller(_owner);
        }
    }
    function offerToSell(uint256 _price, uint256 _value) public {
        require(!locked);
        setOffer(msg.sender, _price, _value);
    }
    function executeOffer(address _owner) public payable {
        require(!locked);
        Offer storage offer = exchange[_owner];
        require(offer.tokens > 0);
        require(msg.value == offer.price);
        _owner.transfer(msg.value);
        Contributor storage owner_c  = contributors[_owner];
        Contributor storage sender_c = contributors[msg.sender];
        require(owner_c.balance >= offer.tokens);
        owner_c.balance = owner_c.balance.sub(offer.tokens);
        sender_c.balance =  sender_c.balance.add(offer.tokens);
        emit Transfer(_owner, msg.sender, offer.tokens);
        setOffer(_owner, 0, 0);
    }
}
