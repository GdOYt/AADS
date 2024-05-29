contract Advertisement {
    struct ValidationRules {
        bool vercode;
        bool ipValidation;
        bool country;
        uint constipDailyConversions;
        uint walletDailyConversions;
    }
    uint constant expectedPoALength = 12;
    ValidationRules public rules;
    bytes32[] bidIdList;
    AppCoins appc;
    AdvertisementStorage advertisementStorage;
    AdvertisementFinance advertisementFinance;
    address public owner;
    mapping (address => mapping (bytes32 => bool)) userAttributions;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    event PoARegistered(bytes32 bidId, string packageName,uint64[] timestampList,uint64[] nonceList,string walletName, bytes2 countryCode);
    event Error(string func, string message);
    event CampaignInformation
        (
            bytes32 bidId,
            address  owner,
            string ipValidator,
            string packageName,
            uint[3] countries,
            uint[] vercodes
    );
    function Advertisement (address _addrAppc, address _addrAdverStorage, address _addrAdverFinance) public {
        rules = ValidationRules(false, true, true, 2, 1);
        owner = msg.sender;
        appc = AppCoins(_addrAppc);
        advertisementStorage = AdvertisementStorage(_addrAdverStorage);
        advertisementFinance = AdvertisementFinance(_addrAdverFinance);
    }
    struct Map {
        mapping (address => uint256) balance;
        address[] devs;
    }
    function upgradeFinance (address addrAdverFinance) public onlyOwner {
        AdvertisementFinance newAdvFinance = AdvertisementFinance(addrAdverFinance);
        Map storage devBalance;    
        for(uint i = 0; i < bidIdList.length; i++) {
            address dev = advertisementStorage.getCampaignOwnerById(bidIdList[i]);
            if(devBalance.balance[dev] == 0){
                devBalance.devs.push(dev);
            }
            devBalance.balance[dev] += advertisementStorage.getCampaignBudgetById(bidIdList[i]);
        }        
        for(i = 0; i < devBalance.devs.length; i++) {
            advertisementFinance.pay(devBalance.devs[i],address(newAdvFinance),devBalance.balance[devBalance.devs[i]]);
            newAdvFinance.increaseBalance(devBalance.devs[i],devBalance.balance[devBalance.devs[i]]);
        }
        uint256 oldBalance = appc.balances(address(advertisementFinance));
        require(oldBalance == 0);
        advertisementFinance = newAdvFinance;
    }
    function upgradeStorage (address addrAdverStorage) public onlyOwner {
        for(uint i = 0; i < bidIdList.length; i++) {
            cancelCampaign(bidIdList[i]);
        }
        delete bidIdList;
        advertisementFinance.reset();
        advertisementFinance.setAdsStorageAddress(addrAdverStorage);
        advertisementStorage = AdvertisementStorage(addrAdverStorage);
    }
    function getAdvertisementStorageAddress() public view returns(address _contract) {
        require (msg.sender == address(advertisementFinance));
        return address(advertisementStorage);
    }
    function createCampaign (
        string packageName,
        uint[3] countries,
        uint[] vercodes,
        uint price,
        uint budget,
        uint startDate,
        uint endDate)
        external {
        require(budget >= price);
        require(endDate >= startDate);
        CampaignLibrary.Campaign memory newCampaign;
        newCampaign.price = price;
        newCampaign.startDate = startDate;
        newCampaign.endDate = endDate;
        if(appc.allowance(msg.sender, address(this)) < budget){
            emit Error("createCampaign","Not enough allowance");
            return;
        }
        appc.transferFrom(msg.sender, address(advertisementFinance), budget);
        advertisementFinance.increaseBalance(msg.sender,budget);
        newCampaign.budget = budget;
        newCampaign.owner = msg.sender;
        newCampaign.valid = true;
        newCampaign.bidId = uintToBytes(bidIdList.length);
        addCampaign(newCampaign);
        emit CampaignInformation(
            newCampaign.bidId,
            newCampaign.owner,
            "",  
            packageName,
            countries,
            vercodes);
    }
    function addCampaign(CampaignLibrary.Campaign campaign) internal {
        bidIdList.push(campaign.bidId);
        advertisementStorage.setCampaign(
            campaign.bidId,
            campaign.price,
            campaign.budget,
            campaign.startDate,
            campaign.endDate,
            campaign.valid,
            campaign.owner
        );
    }
    function registerPoA (
        string packageName, bytes32 bidId,
        uint64[] timestampList, uint64[] nonces,
        address appstore, address oem,
        string walletName, bytes2 countryCode) external {
        if(!isCampaignValid(bidId)){
            emit Error(
                "registerPoA","Registering a Proof of attention to a invalid campaign");
            return;
        }
        if(timestampList.length != expectedPoALength){
            emit Error("registerPoA","Proof-of-attention should have exactly 12 proofs");
            return;
        }
        if(timestampList.length != nonces.length){
            emit Error(
                "registerPoA","Nounce list and timestamp list must have same length");
            return;
        }
        for (uint i = 0; i < timestampList.length - 1; i++) {
            uint timestampDiff = (timestampList[i+1]-timestampList[i]);
            if((timestampDiff / 1000) != 10){
                emit Error(
                    "registerPoA","Timestamps should be spaced exactly 10 secounds");
                return;
            }
        }
        if(userAttributions[msg.sender][bidId]){
            emit Error(
                "registerPoA","User already registered a proof of attention for this campaign");
            return;
        }
        userAttributions[msg.sender][bidId] = true;
        payFromCampaign(bidId, appstore, oem);
        emit PoARegistered(bidId, packageName, timestampList, nonces, walletName, countryCode);
    }
    function cancelCampaign (bytes32 bidId) public {
        address campaignOwner = getOwnerOfCampaign(bidId);
        require(owner == msg.sender || campaignOwner == msg.sender);
        uint budget = getBudgetOfCampaign(bidId);
        advertisementFinance.withdraw(campaignOwner, budget);
        advertisementStorage.setCampaignBudgetById(bidId, 0);
        advertisementStorage.setCampaignValidById(bidId, false);
    }
    function getCampaignValidity(bytes32 bidId) public view returns(bool){
        return advertisementStorage.getCampaignValidById(bidId);
    }
    function getPriceOfCampaign (bytes32 bidId) public view returns(uint) {
        return advertisementStorage.getCampaignPriceById(bidId);
    }
    function getStartDateOfCampaign (bytes32 bidId) public view returns(uint) {
        return advertisementStorage.getCampaignStartDateById(bidId);
    }
    function getEndDateOfCampaign (bytes32 bidId) public view returns(uint) {
        return advertisementStorage.getCampaignEndDateById(bidId);
    }
    function getBudgetOfCampaign (bytes32 bidId) public view returns(uint) {
        return advertisementStorage.getCampaignBudgetById(bidId);
    }
    function getOwnerOfCampaign (bytes32 bidId) public view returns(address) {
        return advertisementStorage.getCampaignOwnerById(bidId);
    }
    function getBidIdList() public view returns(bytes32[]) {
        return bidIdList;
    }
    function isCampaignValid(bytes32 bidId) public view returns(bool) {
        uint startDate = advertisementStorage.getCampaignStartDateById(bidId);
        uint endDate = advertisementStorage.getCampaignEndDateById(bidId);
        bool valid = advertisementStorage.getCampaignValidById(bidId);
        uint nowInMilliseconds = now * 1000;
        return valid && startDate < nowInMilliseconds && endDate > nowInMilliseconds;
    }
    function payFromCampaign (bytes32 bidId, address appstore, address oem) internal {
        uint devShare = 85;
        uint appstoreShare = 10;
        uint oemShare = 5;
        uint price = advertisementStorage.getCampaignPriceById(bidId);
        uint budget = advertisementStorage.getCampaignBudgetById(bidId);
        address campaignOwner = advertisementStorage.getCampaignOwnerById(bidId);
        require(budget > 0);
        require(budget >= price);
        advertisementFinance.pay(campaignOwner,msg.sender,division(price * devShare, 100));
        advertisementFinance.pay(campaignOwner,appstore,division(price * appstoreShare, 100));
        advertisementFinance.pay(campaignOwner,oem,division(price * oemShare, 100));
        uint newBudget = budget - price;
        advertisementStorage.setCampaignBudgetById(bidId, newBudget);
        if (newBudget < price) {
            advertisementStorage.setCampaignValidById(bidId, false);
        }
    }
    function areNoncesValid (bytes packageName,uint64[] timestampList, uint64[] nonces) internal returns(bool) {
        for(uint i = 0; i < nonces.length; i++){
            bytes8 timestamp = bytes8(timestampList[i]);
            bytes8 nonce = bytes8(nonces[i]);
            bytes memory byteList = new bytes(packageName.length + timestamp.length);
            for(uint j = 0; j < packageName.length;j++){
                byteList[j] = packageName[j];
            }
            for(j = 0; j < timestamp.length; j++ ){
                byteList[j + packageName.length] = timestamp[j];
            }
            bytes32 result = sha256(byteList);
            bytes memory noncePlusHash = new bytes(result.length + nonce.length);
            for(j = 0; j < nonce.length; j++){
                noncePlusHash[j] = nonce[j];
            }
            for(j = 0; j < result.length; j++){
                noncePlusHash[j + nonce.length] = result[j];
            }
            result = sha256(noncePlusHash);
            bytes2[1] memory leadingBytes = [bytes2(0)];
            bytes2 comp = 0x0000;
            assembly{
            	mstore(leadingBytes,result)
            }
            if(comp != leadingBytes[0]){
                return false;
            }
        }
        return true;
    }
    function division(uint numerator, uint denominator) public view returns (uint) {
        uint _quotient = numerator / denominator;
        return _quotient;
    }
    function uintToBytes (uint256 i) public view returns(bytes32 b) {
        b = bytes32(i);
    }
}
