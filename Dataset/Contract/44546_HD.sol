contract HD is ERC20, ERC20Detailed {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;
    address public governance;
    address public pendingGov;
    mapping (address => bool) public minters;
    event NewPendingGov(address oldPendingGov, address newPendingGov);
    event NewGov(address oldGov, address newGov);
    modifier onlyGov() {
        require(msg.sender == governance, "HUB-Token: !governance");
        _;
    }
    constructor () public ERC20Detailed("HUB.finance", "HD", 18, 21000000 * 10 ** 18) {
        governance = tx.origin;
    }
    function mint(address _account, uint256 _amount) public {
        require(minters[msg.sender], "HUB-Token: !minter");
        _mint(_account, _amount);
    }
    function addMinter(address _minter) public onlyGov {
        minters[_minter] = true;
    }
    function removeMinter(address _minter) public onlyGov {
        minters[_minter] = false;
    }
    function setPendingGov(address _pendingGov)
        external
        onlyGov
    {
        address oldPendingGov = pendingGov;
        pendingGov = _pendingGov;
        emit NewPendingGov(oldPendingGov, _pendingGov);
    }
    function acceptGov()
        external {
        require(msg.sender == pendingGov, "HUB-Token: !pending");
        address oldGov = governance;
        governance = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldGov, governance);
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        super._beforeTokenTransfer(from, to, amount);
        if (from == address(0)) {  
            require(totalSupply().add(amount) <= cap(), "HUB-Token: Cap exceeded");
        }
    }
}
