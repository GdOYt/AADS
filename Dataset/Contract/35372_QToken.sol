contract QToken is HumanStandardToken {
    mapping (address => bool) authorisers;
    address creator;
    bool canPay = true;
    function QToken() HumanStandardToken(0, "Q", 18, "QTQ") public{
        creator = msg.sender;
    }
    modifier ifCreator(){
        if(creator != msg.sender){
            revert();
        }
        _;
    }
    modifier ifAuthorised(){
        if(authorisers[msg.sender] || creator == msg.sender){
            _;
        }
        else{
            revert();
        }
    }
    modifier ifCanPay(){
        if(!canPay){
            revert();
        }
        _;
    }
    event Authorise(bytes16 _message, address indexed _actioner, address indexed _actionee);
    function authorise(address _address) public ifAuthorised{
        authorisers[_address] = true;
        Authorise('Added', msg.sender, _address);
    }
    function unauthorise(address _address) public ifAuthorised{
        delete authorisers[_address];
        Authorise('Removed', msg.sender, _address);
    }
    function replaceAuthorised(address _toReplace, address _new) public ifAuthorised{
        delete authorisers[_toReplace];
        Authorise('Removed', msg.sender, _toReplace);
        authorisers[_new] = true;
        Authorise('Added', msg.sender, _new);
    }
    function isAuthorised(address _address) public constant returns(bool){
        return authorisers[_address] || (creator == _address);
    }
    function pay(address _address, uint256 _value) public ifCanPay ifAuthorised{
        balances[_address] += _value;
        totalSupply += _value;
        Transfer(address(this), _address, _value);
    }
    function killPay() public ifCreator{
        canPay = false;
    }
}
