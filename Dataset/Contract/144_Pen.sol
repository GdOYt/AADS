contract Pen is StandardToken, Ownable {
    string public constant symbol = "PEN";
    string public constant name = "Pen";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 1250000000 * (10 ** uint256(decimals));
    uint256 public constant TOKEN_OFFERING_ALLOWANCE = 937500000 * (10 ** uint256(decimals));
    uint256 public constant ADMIN_ALLOWANCE = INITIAL_SUPPLY - TOKEN_OFFERING_ALLOWANCE;
    address public adminAddr;
	  address public tokenOfferingAddr;
    bool public transferEnabled = false;
    modifier onlyWhenTransferAllowed() {
        require(transferEnabled || msg.sender == adminAddr || msg.sender == tokenOfferingAddr);
        _;
    }
    modifier onlyTokenOfferingAddrNotSet() {
        require(tokenOfferingAddr == address(0x0));
        _;
    }
    modifier validDestination(address to) {
        require(to != address(0x0));
        require(to != address(this));
        require(to != owner);
        require(to != address(adminAddr));
        require(to != address(tokenOfferingAddr));
        _;
    }
    function Pen(address admin) public {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = totalSupply;
        Transfer(address(0x0), msg.sender, totalSupply);
        adminAddr = admin;
        approve(adminAddr, ADMIN_ALLOWANCE);
    }
    function setTokenOffering(address offeringAddr, uint256 amountForSale) external onlyOwner onlyTokenOfferingAddrNotSet {
        require(!transferEnabled);
        uint256 amount = (amountForSale == 0) ? TOKEN_OFFERING_ALLOWANCE : amountForSale;
        require(amount <= TOKEN_OFFERING_ALLOWANCE);
        approve(offeringAddr, amount);
        tokenOfferingAddr = offeringAddr;
    }
    function enableTransfer() external onlyOwner {
        transferEnabled = true;
        approve(tokenOfferingAddr, 0);
    }
    function transfer(address to, uint256 value) public onlyWhenTransferAllowed validDestination(to) returns (bool) {
        return super.transfer(to, value);
    }
    function transferFrom(address from, address to, uint256 value) public onlyWhenTransferAllowed validDestination(to) returns (bool) {
        return super.transferFrom(from, to, value);
    }
}
