contract ERC20 is Issuer, ERC20Interface {
    using SafeMath for uint;
    bool public locked = true;
    string public constant name = "Ethnamed";
    string public constant symbol = "NAME";
    uint8 public constant decimals = 18;
    uint internal tokenPrice;
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    struct Contributor {
        mapping(address => uint) allowed;
        uint balance;
    }
    mapping(address => Contributor) contributors;
    function ERC20() public {
        tokenPrice = 10**uint(decimals);
        Contributor storage contributor = contributors[issuer];
        contributor.balance = totalSupply();
        emit Transfer(address(0), issuer, totalSupply());
    }
    function unlock() public {
        require(msg.sender == issuer);
        locked = false;
    }
    function totalSupply() public view returns (uint) {
        return 1000000 * tokenPrice;
    }
    function balanceOf(address _tokenOwner) public view returns (uint) {
        Contributor storage contributor = contributors[_tokenOwner];
        return contributor.balance;
    }
    function transfer(address _to, uint _tokens) public returns (bool) {
        require(!locked || msg.sender == issuer);
        Contributor storage sender = contributors[msg.sender];
        Contributor storage recepient = contributors[_to];
        sender.balance = sender.balance.sub(_tokens);
        recepient.balance = recepient.balance.add(_tokens);
        emit Transfer(msg.sender, _to, _tokens);
        return true;
    }
    function allowance(address _tokenOwner, address _spender) public view returns (uint) {
        Contributor storage owner = contributors[_tokenOwner];
        return owner.allowed[_spender];
    }
    function transferFrom(address _from, address _to, uint _tokens) public returns (bool) {
        Contributor storage owner = contributors[_from];
        require(owner.allowed[msg.sender] >= _tokens);
        Contributor storage receiver = contributors[_to];
        owner.balance = owner.balance.sub(_tokens);
        owner.allowed[msg.sender] = owner.allowed[msg.sender].sub(_tokens);
        receiver.balance = receiver.balance.add(_tokens);
        emit Transfer(_from, _to, _tokens);
        return true;
    }
    function approve(address _spender, uint _tokens) public returns (bool) {
        require(!locked);
        Contributor storage owner = contributors[msg.sender];
        owner.allowed[_spender] = _tokens;
        emit Approval(msg.sender, _spender, _tokens);
        return true;
    }
}
