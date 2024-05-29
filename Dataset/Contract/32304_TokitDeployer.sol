contract TokitDeployer is Ownable {
    TokitRegistry public registry;
    mapping (uint8 => AbstractPaymentEscrow) public paymentContracts;
    event DeployedToken(address indexed _customer, uint indexed _projectId, address _token, address _fund);
    event DeployedCampaign(address indexed _customer, uint indexed _projectId, address _campaign);
    function TokitDeployer(address _owner, address _registry) {
        transferOwnership(_owner);
        registry = TokitRegistry(_registry);
    }
    function deployToken(
        address _customer, uint _projectId, uint8 _payedWith, uint _amountNeeded,
        address _wallet, string _name, string _symbol, uint _totalSupply
    )
        onlyOwner()
    {
        require(AbstractPaymentEscrow(paymentContracts[_payedWith]).getDeposit(_projectId) >= _amountNeeded);
        var (t,,) = registry.lookup(_customer, _projectId);
        require(t == address(0));
        SingularDTVFund fund = new SingularDTVFund();
        SingularDTVToken token = new SingularDTVToken(fund, _wallet, _name, _symbol, _totalSupply);
        fund.setup(token);
        registry.register(_customer, _projectId, token, fund);
        DeployedToken(_customer, _projectId, token, fund);
    }
    function deployCampaign(
        address _customer, uint _projectId,
        address _workshop, uint _total, uint _unitPrice, uint _duration, uint _threshold, uint _networkFee
    )
        onlyOwner()
    {
        var (t,f,c) = registry.lookup(_customer, _projectId);
        require(c == address(0));
        require(t != address(0) && f != address(0));
        SingularDTVLaunch campaign = new SingularDTVLaunch(t, _workshop, _customer, _total, _unitPrice, _duration, _threshold, _networkFee);
        registry.register(_customer, _projectId, campaign);
        DeployedCampaign(_customer, _projectId, campaign);
    }
    function setRegistryContract(address _registry)
        onlyOwner()
    {
        registry = TokitRegistry(_registry);
    }
    function setPaymentContract(uint8 _paymentType, address _paymentContract)
        onlyOwner()
    {
        paymentContracts[_paymentType] = AbstractPaymentEscrow(_paymentContract);
    }
    function deletePaymentContract(uint8 _paymentType)
        onlyOwner()
    {
        delete paymentContracts[_paymentType];
    }
}
