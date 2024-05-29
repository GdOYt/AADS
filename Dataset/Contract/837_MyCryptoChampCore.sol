contract MyCryptoChampCore{
    struct Champ {
        uint id;
        uint attackPower;
        uint defencePower;
        uint cooldownTime; 
        uint readyTime;
        uint winCount;
        uint lossCount;
        uint position; 
        uint price; 
        uint withdrawCooldown; 
        uint eq_sword; 
        uint eq_shield; 
        uint eq_helmet; 
        bool forSale; 
    }
    struct AddressInfo {
        uint withdrawal;
        uint champsCount;
        uint itemsCount;
        string name;
    }
    struct Item {
        uint id;
        uint8 itemType; 
        uint8 itemRarity; 
        uint attackPower;
        uint defencePower;
        uint cooldownReduction;
        uint price;
        uint onChampId; 
        bool onChamp; 
        bool forSale;
    }
    Champ[] public champs;
    Item[] public items;
    mapping (uint => uint) public leaderboard;
    mapping (address => AddressInfo) public addressInfo;
    mapping (bool => mapping(address => mapping (address => bool))) public tokenOperatorApprovals;
    mapping (bool => mapping(uint => address)) public tokenApprovals;
    mapping (bool => mapping(uint => address)) public tokenToOwner;
    mapping (uint => string) public champToName;
    mapping (bool => uint) public tokensForSaleCount;
    uint public pendingWithdrawal = 0;
    function addWithdrawal(address _address, uint _amount) public;
    function clearTokenApproval(address _from, uint _tokenId, bool _isTokenChamp) public;
    function setChampsName(uint _champId, string _name) public;
    function setLeaderboard(uint _x, uint _value) public;
    function setTokenApproval(uint _id, address _to, bool _isTokenChamp) public;
    function setTokenOperatorApprovals(address _from, address _to, bool _approved, bool _isTokenChamp) public;
    function setTokenToOwner(uint _id, address _owner, bool _isTokenChamp) public;
    function setTokensForSaleCount(uint _value, bool _isTokenChamp) public;
    function transferToken(address _from, address _to, uint _id, bool _isTokenChamp) public;
    function newChamp(uint _attackPower,uint _defencePower,uint _cooldownTime,uint _winCount,uint _lossCount,uint _position,uint _price,uint _eq_sword, uint _eq_shield, uint _eq_helmet, bool _forSale,address _owner) public returns (uint);
    function newItem(uint8 _itemType,uint8 _itemRarity,uint _attackPower,uint _defencePower,uint _cooldownReduction,uint _price,uint _onChampId,bool _onChamp,bool _forSale,address _owner) public returns (uint);
    function updateAddressInfo(address _address, uint _withdrawal, bool _updatePendingWithdrawal, uint _champsCount, bool _updateChampsCount, uint _itemsCount, bool _updateItemsCount, string _name, bool _updateName) public;
    function updateChamp(uint _champId, uint _attackPower,uint _defencePower,uint _cooldownTime,uint _readyTime,uint _winCount,uint _lossCount,uint _position,uint _price,uint _withdrawCooldown,uint _eq_sword, uint _eq_shield, uint _eq_helmet, bool _forSale) public;
    function updateItem(uint _id,uint8 _itemType,uint8 _itemRarity,uint _attackPower,uint _defencePower,uint _cooldownReduction,uint _price,uint _onChampId,bool _onChamp,bool _forSale) public;
    function getChampStats(uint256 _champId) public view returns(uint256,uint256,uint256);
    function getChampsByOwner(address _owner) external view returns(uint256[]);
    function getTokensForSale(bool _isTokenChamp) view external returns(uint256[]);
    function getItemsByOwner(address _owner) external view returns(uint256[]);
    function getTokenCount(bool _isTokenChamp) external view returns(uint);
    function getTokenURIs(uint _tokenId, bool _isTokenChamp) public view returns(string);
    function onlyApprovedOrOwnerOfToken(uint _id, address _msgsender, bool _isTokenChamp) external view returns(bool);
}
