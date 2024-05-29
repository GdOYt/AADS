contract SVIndexBackend is IxBackendIface {
    uint constant VERSION = 2;
    struct Democ {
        address erc20;
        address owner;
        bool communityBallotsDisabled;
        bool erc20OwnerClaimDisabled;
        uint editorEpoch;
        mapping (uint => mapping (address => bool)) editors;
        uint256[] allBallots;
        uint256[] includedBasicBallots;   
    }
    struct BallotRef {
        bytes32 democHash;
        uint ballotId;
    }
    struct Category {
        bool deprecated;
        bytes32 name;
        bool hasParent;
        uint parent;
    }
    struct CategoriesIx {
        uint nCategories;
        mapping(uint => Category) categories;
    }
    mapping (bytes32 => Democ) democs;
    mapping (bytes32 => CategoriesIx) democCategories;
    mapping (bytes13 => bytes32) democPrefixToHash;
    mapping (address => bytes32[]) erc20ToDemocs;
    bytes32[] democList;
    mapping (bytes32 => mapping (bytes32 => bytes)) arbitraryData;
    constructor() payoutAllC(msg.sender) public {
    }
    function _getPayTo() internal view returns (address) {
        return owner;
    }
    function getVersion() external pure returns (uint) {
        return VERSION;
    }
    function getGDemocsN() external view returns (uint) {
        return democList.length;
    }
    function getGDemoc(uint id) external view returns (bytes32) {
        return democList[id];
    }
    function getGErc20ToDemocs(address erc20) external view returns (bytes32[] democHashes) {
        return erc20ToDemocs[erc20];
    }
    function _addDemoc(bytes32 democHash, address erc20, address initOwner, bool disableErc20OwnerClaim) internal {
        democList.push(democHash);
        Democ storage d = democs[democHash];
        d.erc20 = erc20;
        if (disableErc20OwnerClaim) {
            d.erc20OwnerClaimDisabled = true;
        }
        assert(democPrefixToHash[bytes13(democHash)] == bytes32(0));
        democPrefixToHash[bytes13(democHash)] = democHash;
        erc20ToDemocs[erc20].push(democHash);
        _setDOwner(democHash, initOwner);
        emit NewDemoc(democHash);
    }
    function dAdd(bytes32 democHash, address erc20, bool disableErc20OwnerClaim) only_owner() external {
        _addDemoc(democHash, erc20, msg.sender, disableErc20OwnerClaim);
        emit ManuallyAddedDemoc(democHash, erc20);
    }
    function emergencySetDOwner(bytes32 democHash, address newOwner) only_owner() external {
        _setDOwner(democHash, newOwner);
        emit EmergencyDemocOwner(democHash, newOwner);
    }
    function dInit(address defaultErc20, address initOwner, bool disableErc20OwnerClaim) only_editors() external returns (bytes32 democHash) {
        democHash = keccak256(abi.encodePacked(democList.length, blockhash(block.number-1), defaultErc20, now));
        _addDemoc(democHash, defaultErc20, initOwner, disableErc20OwnerClaim);
    }
    function _setDOwner(bytes32 democHash, address newOwner) internal {
        Democ storage d = democs[democHash];
        uint epoch = d.editorEpoch;
        d.owner = newOwner;
        d.editors[epoch][d.owner] = false;
        d.editors[epoch][newOwner] = true;
        emit DemocOwnerSet(democHash, newOwner);
    }
    function setDOwner(bytes32 democHash, address newOwner) only_editors() external {
        _setDOwner(democHash, newOwner);
    }
    function setDOwnerFromClaim(bytes32 democHash, address newOwner) only_editors() external {
        Democ storage d = democs[democHash];
        require(d.erc20OwnerClaimDisabled == false, "!erc20-claim");
        d.owner = newOwner;
        d.editors[d.editorEpoch][newOwner] = true;
        d.erc20OwnerClaimDisabled = true;
        emit DemocOwnerSet(democHash, newOwner);
        emit DemocClaimed(democHash);
    }
    function setDEditor(bytes32 democHash, address editor, bool canEdit) only_editors() external {
        Democ storage d = democs[democHash];
        d.editors[d.editorEpoch][editor] = canEdit;
        emit DemocEditorSet(democHash, editor, canEdit);
    }
    function setDNoEditors(bytes32 democHash) only_editors() external {
        democs[democHash].editorEpoch += 1;
        emit DemocEditorsWiped(democHash);
    }
    function setDErc20(bytes32 democHash, address newErc20) only_editors() external {
        democs[democHash].erc20 = newErc20;
        erc20ToDemocs[newErc20].push(democHash);
        emit DemocErc20Set(democHash, newErc20);
    }
    function dSetArbitraryData(bytes32 democHash, bytes key, bytes value) only_editors() external {
        bytes32 k = keccak256(key);
        arbitraryData[democHash][k] = value;
        emit DemocDataSet(democHash, k);
    }
    function dSetEditorArbitraryData(bytes32 democHash, bytes key, bytes value) only_editors() external {
        bytes32 k = keccak256(_calcEditorKey(key));
        arbitraryData[democHash][k] = value;
        emit DemocDataSet(democHash, k);
    }
    function dAddCategory(bytes32 democHash, bytes32 name, bool hasParent, uint parent) only_editors() external {
        uint catId = democCategories[democHash].nCategories;
        democCategories[democHash].categories[catId].name = name;
        if (hasParent) {
            democCategories[democHash].categories[catId].hasParent = true;
            democCategories[democHash].categories[catId].parent = parent;
        }
        democCategories[democHash].nCategories += 1;
        emit DemocCatAdded(democHash, catId);
    }
    function dDeprecateCategory(bytes32 democHash, uint catId) only_editors() external {
        democCategories[democHash].categories[catId].deprecated = true;
        emit DemocCatDeprecated(democHash, catId);
    }
    function dSetCommunityBallotsEnabled(bytes32 democHash, bool enabled) only_editors() external {
        democs[democHash].communityBallotsDisabled = !enabled;
        emit DemocCommunityBallotsEnabled(democHash, enabled);
    }
    function dDisableErc20OwnerClaim(bytes32 democHash) only_editors() external {
        democs[democHash].erc20OwnerClaimDisabled = true;
        emit DemocErc20OwnerClaimDisabled(democHash);
    }
    function _commitBallot(bytes32 democHash, uint ballotId, uint256 packed, bool countTowardsLimit) internal {
        uint16 subBits;
        subBits = BPackedUtils.packedToSubmissionBits(packed);
        uint localBallotId = democs[democHash].allBallots.length;
        democs[democHash].allBallots.push(ballotId);
        if (countTowardsLimit) {
            democs[democHash].includedBasicBallots.push(ballotId);
        }
        emit NewBallot(democHash, localBallotId);
    }
    function dAddBallot(bytes32 democHash, uint ballotId, uint256 packed, bool countTowardsLimit) only_editors() external {
        _commitBallot(democHash, ballotId, packed, countTowardsLimit);
    }
    function getDOwner(bytes32 democHash) external view returns (address) {
        return democs[democHash].owner;
    }
    function isDEditor(bytes32 democHash, address editor) external view returns (bool) {
        Democ storage d = democs[democHash];
        return d.editors[d.editorEpoch][editor] || editor == d.owner;
    }
    function getDHash(bytes13 prefix) external view returns (bytes32) {
        return democPrefixToHash[prefix];
    }
    function getDInfo(bytes32 democHash) external view returns (address erc20, address owner, uint256 nBallots) {
        return (democs[democHash].erc20, democs[democHash].owner, democs[democHash].allBallots.length);
    }
    function getDErc20(bytes32 democHash) external view returns (address) {
        return democs[democHash].erc20;
    }
    function getDArbitraryData(bytes32 democHash, bytes key) external view returns (bytes) {
        return arbitraryData[democHash][keccak256(key)];
    }
    function getDEditorArbitraryData(bytes32 democHash, bytes key) external view returns (bytes) {
        return arbitraryData[democHash][keccak256(_calcEditorKey(key))];
    }
    function getDBallotsN(bytes32 democHash) external view returns (uint256) {
        return democs[democHash].allBallots.length;
    }
    function getDBallotID(bytes32 democHash, uint256 n) external view returns (uint ballotId) {
        return democs[democHash].allBallots[n];
    }
    function getDCountedBasicBallotsN(bytes32 democHash) external view returns (uint256) {
        return democs[democHash].includedBasicBallots.length;
    }
    function getDCountedBasicBallotID(bytes32 democHash, uint256 n) external view returns (uint256) {
        return democs[democHash].includedBasicBallots[n];
    }
    function getDCategoriesN(bytes32 democHash) external view returns (uint) {
        return democCategories[democHash].nCategories;
    }
    function getDCategory(bytes32 democHash, uint catId) external view returns (bool deprecated, bytes32 name, bool hasParent, uint256 parent) {
        deprecated = democCategories[democHash].categories[catId].deprecated;
        name = democCategories[democHash].categories[catId].name;
        hasParent = democCategories[democHash].categories[catId].hasParent;
        parent = democCategories[democHash].categories[catId].parent;
    }
    function getDCommBallotsEnabled(bytes32 democHash) external view returns (bool) {
        return !democs[democHash].communityBallotsDisabled;
    }
    function getDErc20OwnerClaimEnabled(bytes32 democHash) external view returns (bool) {
        return !democs[democHash].erc20OwnerClaimDisabled;
    }
    function _calcEditorKey(bytes key) internal pure returns (bytes) {
        return abi.encodePacked("editor.", key);
    }
}
