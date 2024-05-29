contract MerchantWallet is Pausable, SafeDestructible, Contactable, Restricted {
    string constant VERSION = "0.4";
    address public merchantAccount;
    bytes32 public merchantIdHash;
    mapping (string=>string) profileMap;
    mapping (string=>string) paymentSettingsMap;
    mapping (string=>uint32) compositeReputationMap;
    uint8 public constant REPUTATION_DECIMALS = 4;
    modifier onlyMerchant() {
        require(msg.sender == merchantAccount);
        _;
    }
    modifier onlyMerchantOrMonetha() {
        require(msg.sender == merchantAccount || isMonethaAddress[msg.sender]);
        _;
    }
    function MerchantWallet(address _merchantAccount, string _merchantId) public {
        require(_merchantAccount != 0x0);
        require(bytes(_merchantId).length > 0);
        merchantAccount = _merchantAccount;
        merchantIdHash = keccak256(_merchantId);
    }
    function () external payable {
    }
    function profile(string key) external constant returns (string) {
        return profileMap[key];
    }
    function paymentSettings(string key) external constant returns (string) {
        return paymentSettingsMap[key];
    }
    function compositeReputation(string key) external constant returns (uint32) {
        return compositeReputationMap[key];
    }
    function setProfile(
        string profileKey,
        string profileValue,
        string repKey,
        uint32 repValue
    ) external onlyOwner
    {
        profileMap[profileKey] = profileValue;
        if (bytes(repKey).length != 0) {
            compositeReputationMap[repKey] = repValue;
        }
    }
    function setPaymentSettings(string key, string value) external onlyOwner {
        paymentSettingsMap[key] = value;
    }
    function setCompositeReputation(string key, uint32 value) external onlyMonetha {
        compositeReputationMap[key] = value;
    }
    function doWithdrawal(address beneficiary, uint amount) private {
        require(beneficiary != 0x0);
        beneficiary.transfer(amount);
    }
    function withdrawTo(address beneficiary, uint amount) public onlyMerchant whenNotPaused {
        doWithdrawal(beneficiary, amount);
    }
    function withdraw(uint amount) external {
        withdrawTo(msg.sender, amount);
    }
    function withdrawToExchange(address depositAccount, uint amount) external onlyMerchantOrMonetha whenNotPaused {
        doWithdrawal(depositAccount, amount);
    }
    function withdrawAllToExchange(address depositAccount, uint min_amount) external onlyMerchantOrMonetha whenNotPaused {
        require (address(this).balance >= min_amount);
        doWithdrawal(depositAccount, address(this).balance);
    }
    function changeMerchantAccount(address newAccount) external onlyMerchant whenNotPaused {
        merchantAccount = newAccount;
    }
}
