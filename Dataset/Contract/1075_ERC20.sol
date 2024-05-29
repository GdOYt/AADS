contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint256);
function Menu06(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
