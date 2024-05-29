contract NokuCustomERC20Service is NokuCustomService {
    event LogNokuCustomERC20ServiceCreated(address caller, address indexed pricingPlan);
    uint256 public constant CREATE_AMOUNT = 1 * 10**18;
    uint8 public constant DECIMALS = 18;
    bytes32 public constant CUSTOM_ERC20_CREATE_SERVICE_NAME = "NokuCustomERC20.create";
    constructor(address _pricingPlan) NokuCustomService(_pricingPlan) public {
        emit LogNokuCustomERC20ServiceCreated(msg.sender, _pricingPlan);
    }
    function createCustomToken(string _name, string _symbol, uint8  ) public returns(NokuCustomERC20 customToken) {
        customToken = new NokuCustomERC20(
            _name,
            _symbol,
            DECIMALS,
            block.number,
            block.number,
            pricingPlan,
            owner
        );
        customToken.transferOwnership(msg.sender);
        require(pricingPlan.payFee(CUSTOM_ERC20_CREATE_SERVICE_NAME, CREATE_AMOUNT, msg.sender), "fee payment failed");
    }
    function createCustomToken(
        string _name,
        string _symbol,
        uint8  ,
        uint256 transferableFromBlock,
        uint256 lockEndBlock
    )
    public returns(NokuCustomERC20 customToken)
    {
        customToken = new NokuCustomERC20(
            _name,
            _symbol,
            DECIMALS,
            transferableFromBlock,
            lockEndBlock,
            pricingPlan,
            owner
        );
        customToken.transferOwnership(msg.sender);
        require(pricingPlan.payFee(CUSTOM_ERC20_CREATE_SERVICE_NAME, CREATE_AMOUNT, msg.sender), "fee payment failed");
    }
}
