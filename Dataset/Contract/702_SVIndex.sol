contract SVIndex is IxIface {
    uint256 constant VERSION = 2;
    bytes4 constant OWNER_SIG = 0x8da5cb5b;
    bytes4 constant CONTROLLER_SIG = 0xf77c4791;
    IxBackendIface backend;
    IxPaymentsIface payments;
    EnsOwnerProxy public ensOwnerPx;
    BBFarmIface[] bbFarms;
    CommAuctionIface commAuction;
    mapping (bytes4 => uint8) bbFarmIdLookup;
    mapping (uint8 => bool) deprecatedBBFarms;
    modifier onlyDemocOwner(bytes32 democHash) {
        require(msg.sender == backend.getDOwner(democHash), "!d-owner");
        _;
    }
    modifier onlyDemocEditor(bytes32 democHash) {
        require(backend.isDEditor(democHash, msg.sender), "!d-editor");
        _;
    }
    constructor( IxBackendIface _b
               , IxPaymentsIface _pay
               , EnsOwnerProxy _ensOwnerPx
               , BBFarmIface _bbFarm0
               , CommAuctionIface _commAuction
               ) payoutAllC(msg.sender) public {
        backend = _b;
        payments = _pay;
        ensOwnerPx = _ensOwnerPx;
        _addBBFarm(0x0, _bbFarm0);
        commAuction = _commAuction;
    }
    function _getPayTo() internal view returns (address) {
        return payments.getPayTo();
    }
    function doUpgrade(address nextSC) only_owner() not_upgraded() external {
        doUpgradeInternal(nextSC);
        backend.upgradeMe(nextSC);
        payments.upgradeMe(nextSC);
        ensOwnerPx.setAddr(nextSC);
        ensOwnerPx.upgradeMeAdmin(nextSC);
        commAuction.upgradeMe(nextSC);
        for (uint i = 0; i < bbFarms.length; i++) {
            bbFarms[i].upgradeMe(nextSC);
        }
    }
    function _addBBFarm(bytes4 bbNamespace, BBFarmIface _bbFarm) internal returns (uint8 bbFarmId) {
        uint256 bbFarmIdLong = bbFarms.length;
        require(bbFarmIdLong < 2**8, "too-many-farms");
        bbFarmId = uint8(bbFarmIdLong);
        bbFarms.push(_bbFarm);
        bbFarmIdLookup[bbNamespace] = bbFarmId;
        emit AddedBBFarm(bbFarmId);
    }
    function addBBFarm(BBFarmIface bbFarm) only_owner() external returns (uint8 bbFarmId) {
        bytes4 bbNamespace = bbFarm.getNamespace();
        require(bbNamespace != bytes4(0), "bb-farm-namespace");
        require(bbFarmIdLookup[bbNamespace] == 0 && bbNamespace != bbFarms[0].getNamespace(), "bb-namespace-used");
        bbFarmId = _addBBFarm(bbNamespace, bbFarm);
    }
    function setABackend(bytes32 toSet, address newSC) only_owner() external {
        emit SetBackend(toSet, newSC);
        if (toSet == bytes32("payments")) {
            payments = IxPaymentsIface(newSC);
        } else if (toSet == bytes32("backend")) {
            backend = IxBackendIface(newSC);
        } else if (toSet == bytes32("commAuction")) {
            commAuction = CommAuctionIface(newSC);
        } else {
            revert("404");
        }
    }
    function deprecateBBFarm(uint8 bbFarmId, BBFarmIface _bbFarm) only_owner() external {
        require(address(_bbFarm) != address(0));
        require(bbFarms[bbFarmId] == _bbFarm);
        deprecatedBBFarms[bbFarmId] = true;
        emit DeprecatedBBFarm(bbFarmId);
    }
    function getPayments() external view returns (IxPaymentsIface) {
        return payments;
    }
    function getBackend() external view returns (IxBackendIface) {
        return backend;
    }
    function getBBFarm(uint8 bbFarmId) external view returns (BBFarmIface) {
        return bbFarms[bbFarmId];
    }
    function getBBFarmID(bytes4 bbNamespace) external view returns (uint8 bbFarmId) {
        return bbFarmIdLookup[bbNamespace];
    }
    function getCommAuction() external view returns (CommAuctionIface) {
        return commAuction;
    }
    function getVersion() external pure returns (uint256) {
        return VERSION;
    }
    function dInit(address defaultErc20, bool disableErc20OwnerClaim) not_upgraded() external payable returns (bytes32) {
        require(msg.value >= payments.getMinWeiForDInit());
        bytes32 democHash = backend.dInit(defaultErc20, msg.sender, disableErc20OwnerClaim);
        payments.payForDemocracy.value(msg.value)(democHash);
        return democHash;
    }
    function setDEditor(bytes32 democHash, address editor, bool canEdit) onlyDemocOwner(democHash) external {
        backend.setDEditor(democHash, editor, canEdit);
    }
    function setDNoEditors(bytes32 democHash) onlyDemocOwner(democHash) external {
        backend.setDNoEditors(democHash);
    }
    function setDOwner(bytes32 democHash, address newOwner) onlyDemocOwner(democHash) external {
        backend.setDOwner(democHash, newOwner);
    }
    function dOwnerErc20Claim(bytes32 democHash) external {
        address erc20 = backend.getDErc20(democHash);
        if (erc20.call.gas(3000)(OWNER_SIG)) {
            require(msg.sender == owned(erc20).owner.gas(3000)(), "!erc20-owner");
        } else if (erc20.call.gas(3000)(CONTROLLER_SIG)) {
            require(msg.sender == controlledIface(erc20).controller.gas(3000)(), "!erc20-controller");
        } else {
            revert();
        }
        backend.setDOwnerFromClaim(democHash, msg.sender);
    }
    function setDErc20(bytes32 democHash, address newErc20) onlyDemocOwner(democHash) external {
        backend.setDErc20(democHash, newErc20);
    }
    function dAddCategory(bytes32 democHash, bytes32 catName, bool hasParent, uint parent) onlyDemocEditor(democHash) external {
        backend.dAddCategory(democHash, catName, hasParent, parent);
    }
    function dDeprecateCategory(bytes32 democHash, uint catId) onlyDemocEditor(democHash) external {
        backend.dDeprecateCategory(democHash, catId);
    }
    function dUpgradeToPremium(bytes32 democHash) onlyDemocOwner(democHash) external {
        payments.upgradeToPremium(democHash);
    }
    function dDowngradeToBasic(bytes32 democHash) onlyDemocOwner(democHash) external {
        payments.downgradeToBasic(democHash);
    }
    function dSetArbitraryData(bytes32 democHash, bytes key, bytes value) external {
        if (msg.sender == backend.getDOwner(democHash)) {
            backend.dSetArbitraryData(democHash, key, value);
        } else if (backend.isDEditor(democHash, msg.sender)) {
            backend.dSetEditorArbitraryData(democHash, key, value);
        } else {
            revert();
        }
    }
    function dSetCommunityBallotsEnabled(bytes32 democHash, bool enabled) onlyDemocOwner(democHash) external {
        backend.dSetCommunityBallotsEnabled(democHash, enabled);
    }
    function dDisableErc20OwnerClaim(bytes32 democHash) onlyDemocOwner(democHash) external {
        backend.dDisableErc20OwnerClaim(democHash);
    }
    function dAddBallot(bytes32 democHash, uint ballotId, uint256 packed)
                      only_owner()
                      external {
        _addBallot(democHash, ballotId, packed, false);
        emit ManuallyAddedBallot(democHash, ballotId, packed);
    }
    function _deployBallot(bytes32 democHash, bytes32 specHash, bytes32 extraData, uint packed, bool checkLimit, bool alreadySentTx) internal returns (uint ballotId) {
        require(BBLibV7.isTesting(BPackedUtils.packedToSubmissionBits(packed)) == false, "b-testing");
        uint8 bbFarmId = uint8(extraData[0]);
        require(deprecatedBBFarms[bbFarmId] == false, "bb-dep");
        BBFarmIface _bbFarm = bbFarms[bbFarmId];
        bool countTowardsLimit = checkLimit;
        bool performedSend;
        if (checkLimit) {
            uint64 endTime = BPackedUtils.packedToEndTime(packed);
            (countTowardsLimit, performedSend) = _basicBallotLimitOperations(democHash, _bbFarm);
            _accountOkayChecks(democHash, endTime);
        }
        if (!performedSend && msg.value > 0 && alreadySentTx == false) {
            doSafeSend(msg.sender, msg.value);
        }
        ballotId = _bbFarm.initBallot(
            specHash,
            packed,
            this,
            msg.sender,
            bytes24(uint192(extraData)));
        _addBallot(democHash, ballotId, packed, countTowardsLimit);
    }
    function dDeployCommunityBallot(bytes32 democHash, bytes32 specHash, bytes32 extraData, uint128 packedTimes) external payable {
        uint price = commAuction.getNextPrice(democHash);
        require(msg.value >= price, "!cb-fee");
        doSafeSend(payments.getPayTo(), price);
        doSafeSend(msg.sender, msg.value - price);
        bool canProceed = backend.getDCommBallotsEnabled(democHash) || !payments.accountInGoodStanding(democHash);
        require(canProceed, "!cb-enabled");
        uint256 packed = BPackedUtils.setSB(uint256(packedTimes), (USE_ETH | USE_NO_ENC));
        uint ballotId = _deployBallot(democHash, specHash, extraData, packed, false, true);
        commAuction.noteBallotDeployed(democHash);
        emit CommunityBallot(democHash, ballotId);
    }
    function dDeployBallot(bytes32 democHash, bytes32 specHash, bytes32 extraData, uint256 packed)
                          onlyDemocEditor(democHash)
                          external payable {
        _deployBallot(democHash, specHash, extraData, packed, true, false);
    }
    function _addBallot(bytes32 democHash, uint256 ballotId, uint256 packed, bool countTowardsLimit) internal {
        backend.dAddBallot(democHash, ballotId, packed, countTowardsLimit);
    }
    function _accountOkayChecks(bytes32 democHash, uint64 endTime) internal view {
        uint secsLeft = payments.getSecondsRemaining(democHash);
        uint256 secsToEndTime = endTime - now;
        require(secsLeft * 2 > secsToEndTime, "unpaid");
    }
    function _basicBallotLimitOperations(bytes32 democHash, BBFarmIface _bbFarm) internal returns (bool shouldCount, bool performedSend) {
        if (payments.getPremiumStatus(democHash) == false) {
            uint nBallotsAllowed = payments.getBasicBallotsPer30Days();
            uint nBallotsBasicCounted = backend.getDCountedBasicBallotsN(democHash);
            if (nBallotsAllowed > nBallotsBasicCounted) {
                return (true, false);
            }
            uint earlyBallotId = backend.getDCountedBasicBallotID(democHash, nBallotsBasicCounted - nBallotsAllowed);
            uint earlyBallotTs = _bbFarm.getCreationTs(earlyBallotId);
            if (earlyBallotTs < now - 30 days) {
                return (true, false);
            }
            uint extraBallotFee = payments.getBasicExtraBallotFeeWei();
            require(msg.value >= extraBallotFee, "!extra-b-fee");
            uint remainder = msg.value - extraBallotFee;
            doSafeSend(address(payments), extraBallotFee);
            doSafeSend(msg.sender, remainder);
            emit PaymentMade([extraBallotFee, remainder]);
            return (false, true);
        } else {   
            return (false, false);
        }
    }
}
