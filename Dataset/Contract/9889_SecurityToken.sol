contract SecurityToken is Ownable{
    using SafeMath for uint256;
    ISecurityController public controller;
    string public name;
    string public symbol;
    uint8 public decimals;
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    constructor(string _name, string  _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
    function setController(address _c) public onlyOwner {
        controller = ISecurityController(_c);
    }
    function sendReceivedTokens(address token, address sender, uint amount) public onlyOwner {
        ERC20Basic t = ERC20Basic(token);
        require(t.transfer(sender, amount));
    }
    function balanceOf(address a) public view returns (uint) {
        return controller.balanceOf(a);
    }
    function totalSupply() public view returns (uint) {
        return controller.totalSupply();
    }
    function allowance(address _owner, address _spender) public view returns (uint) {
        return controller.allowance(_owner, _spender);
    }
    function burn(uint _amount) public {
        controller.burn(msg.sender, _amount);
        emit Transfer(msg.sender, 0x0, _amount);
    }
    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length >= numwords.mul(32).add(4));
        _;
    }
    function isTransferAuthorized(address _from, address _to) public onlyPayloadSize(2) view returns (bool) {
        return controller.isTransferAuthorized(_from, _to);
    }
    function transfer(address _to, uint _value) public onlyPayloadSize(2) returns (bool success) {
        if (controller.transfer(msg.sender, _to, _value)) {
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }
    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3) returns (bool success) {
        if (controller.transferFrom(msg.sender, _from, _to, _value)) {
            emit Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }
    function approve(address _spender, uint _value) onlyPayloadSize(2) public returns (bool success) {
        if (controller.approve(msg.sender, _spender, _value)) {
            emit Approval(msg.sender, _spender, _value);
            return true;
        }
        return false;
    }
    function increaseApproval (address _spender, uint _addedValue) public onlyPayloadSize(2) returns (bool success) {
        if (controller.increaseApproval(msg.sender, _spender, _addedValue)) {
            uint newval = controller.allowance(msg.sender, _spender);
            emit Approval(msg.sender, _spender, newval);
            return true;
        }
        return false;
    }
    function decreaseApproval (address _spender, uint _subtractedValue) public onlyPayloadSize(2) returns (bool success) {
        if (controller.decreaseApproval(msg.sender, _spender, _subtractedValue)) {
            uint newval = controller.allowance(msg.sender, _spender);
            emit Approval(msg.sender, _spender, newval);
            return true;
        }
        return false;
    }
    modifier onlyController() {
        assert(msg.sender == address(controller));
        _;
    }
    function controllerTransfer(address _from, address _to, uint _value) public onlyController {
        emit Transfer(_from, _to, _value);
    }
    function controllerApprove(address _owner, address _spender, uint _value) public onlyController {
        emit Approval(_owner, _spender, _value);
    }
}
