contract ERC20Token {
    function totalSupply() public view returns (uint256);
    function balanceOf(address _targetAddress) public view returns (uint256);
    function transfer(address _targetAddress, uint256 _value) public returns (bool);
    event Transfer(address indexed _originAddress, address indexed _targetAddress, uint256 _value);
    function allowance(address _originAddress, address _targetAddress) public view returns (uint256);
    function approve(address _originAddress, uint256 _value) public returns (bool);
    function transferFrom(address _originAddress, address _targetAddress, uint256 _value) public returns (bool);
    event Approval(address indexed _originAddress, address indexed _targetAddress, uint256 _value);
}
