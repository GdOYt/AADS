contract IERC20Token {
    function totalSupply() public constant returns (uint256 totalSupply);
    function balanceOf(address _owner) public  constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    function hasSDC(address _address,uint256 _quantity) public returns (bool success);
    function hasSDCC(address _address,uint256 _quantity) public returns (bool success);
    function eliminateSDCC(address _address,uint256 _quantity) public returns (bool success);
    function createSDCC(address _address,uint256 _quantity) public returns (bool success); 
    function createSDC(address _address,uint256 _init_quantity, uint256 _quantity) public returns (bool success);
    function stakeSDC(address _address, uint256 amount)  public returns(bool);
    function endStake(address _address, uint256 amount)  public returns(bool);
    function chipBalanceOf(address _address) public returns (uint256 _amount);
    function transferChips(address _from, address _to, uint256 _value) public returns (bool success);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
