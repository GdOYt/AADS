contract Registrar {
	string public constant symbol = "ART";
	string public constant name = "Patron - Ethart Network Token";
	uint8 public constant decimals = 18;
	uint256 _totalPatronSupply;
	event Transfer(address indexed _from, address _to, uint256 _value);
	event Approval(address indexed _owner, address _spender, uint256 _value);
	event Burn(address indexed _owner, uint256 _amount);
	mapping(address => uint256) public balances;						 
	event NewArtwork(address _contract, bytes32 _SHA256Hash, uint256 _editionSize, string _title, string _fileLink, uint256 _ownerCommission, address _artist, bool _indexed, bool _ouroboros);
 	mapping(address => mapping (address => uint256)) allowed;			 
    function totalSupply() constant returns (uint256 totalPatronSupply) {
		totalPatronSupply = _totalPatronSupply;
		}
	function balanceOf(address _owner) constant returns (uint256 balance) {
 		return balances[_owner];
		}
	function transfer(address _to, uint256 _amount) returns (bool success) {
		if (balances[msg.sender] >= _amount 
			&& _amount > 0
 		   	&& balances[_to] + _amount > balances[_to]
			&& _to != 0x0)										 
			{
			balances[msg.sender] -= _amount;
			balances[_to] += _amount;
			Transfer(msg.sender, _to, _amount);
 		   	return true;
			}
			else { return false;}
 		 }
 	function transferFrom( address _from, address _to, uint256 _amount) returns (bool success)
		{
			if (balances[_from] >= _amount
				&& allowed[_from][msg.sender] >= _amount
				&& _amount > 0
				&& balances[_to] + _amount > balances[_to]
				&& _to != 0x0)										 
					{
					balances[_from] -= _amount;
					allowed[_from][msg.sender] -= _amount;
					balances[_to] += _amount;
					Transfer(_from, _to, _amount);
					return true;
					} else {return false;}
		}
	function approve(address _spender, uint256 _amount) returns (bool success) {
		allowed[msg.sender][_spender] = _amount;
		Approval(msg.sender, _spender, _amount);
		return true;
		}
	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
		return allowed[_owner][_spender];
		}
	function burn(uint256 _amount) returns (bool success) {
			if (balances[msg.sender] >= _amount) {
				balances[msg.sender] -= _amount;
				_totalPatronSupply -= _amount;
				Burn(msg.sender, _amount);
				return true;
			}
			else {throw;}
		}
	function burnFrom(address _from, uint256 _value) returns (bool success) {
		if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
			balances[_from] -= _value;
			allowed[_from][msg.sender] -= _value;
			_totalPatronSupply -= _value;
			Burn(_from, _value);
			return true;
		}
		else {throw;}
	}
    mapping (bytes32 => address) public SHA256HashRegister;		 
	mapping (address => bool) public approvedFactories;			 
	mapping (address => bool) public approvedContracts;			 
	mapping (address => address) public referred;				 
	mapping (address => bool) public cantSetReferrer;			 
	struct artwork {
		bytes32 SHA256Hash;
		uint256 editionSize;
		string title;
		string fileLink;
		uint256 ownerCommission;
		address artist;
		address factory;
		bool isIndexed;
		bool isOuroboros;}
	mapping (address => artwork) public artworkRegister;		 
	mapping(address => mapping (uint256 => address)) public artistsArtworks;	 
	mapping(address => uint256) public artistsArtworkCount;						 
	mapping(address => address) public artworksFactory;							 
	uint256 artworkCount;										 
	mapping (uint256 => address) public artworkIndex;			 
	address public owner;										 
	uint256 public donationMultiplier;
    modifier onlyBy (address _account)
    {
        require(msg.sender == _account);
        _;
    }
    modifier registerdFactoriesOnly ()
    {
        require(approvedFactories[msg.sender]);
        _;
    }
	modifier approvedContractsOnly ()
	{
		require(approvedContracts[msg.sender]);
		_;
	}
	function setReferrer (address _referrer)
		{
			if (referred[msg.sender] == 0x0 && !cantSetReferrer[msg.sender])
			{
				referred[msg.sender] = _referrer;
			}
		}
	function Registrar () {
		owner = msg.sender;
		donationMultiplier = 100;
	}
	function changeOwner (address newOwner) onlyBy (owner) 
		{
			owner = newOwner;
		}
	function issuePatrons (address _to, uint256 _amount) approvedContractsOnly
		{
			balances[_to] += _amount;
			_totalPatronSupply += _amount;
		}
	function setDonationReward (uint256 _multiplier) onlyBy (owner)
		{
			donationMultiplier = _multiplier;
		}
	function donate () payable
		{
			balances[msg.sender] += msg.value * donationMultiplier;
			_totalPatronSupply += msg.value * donationMultiplier;
		}
	function registerArtwork (address _contract, bytes32 _SHA256Hash, uint256 _editionSize, string _title, string _fileLink, uint256 _ownerCommission, address _artist, bool _indexed, bool _ouroboros) registerdFactoriesOnly
		{
		if (SHA256HashRegister[_SHA256Hash] == 0x0) {
		   	SHA256HashRegister[_SHA256Hash] = _contract;
			approvedContracts[_contract] = true;
			cantSetReferrer[_artist] = true;
			artworkRegister[_contract].SHA256Hash = _SHA256Hash;
			artworkRegister[_contract].editionSize = _editionSize;
			artworkRegister[_contract].title = _title;
			artworkRegister[_contract].fileLink = _fileLink;
			artworkRegister[_contract].ownerCommission = _ownerCommission;
			artworkRegister[_contract].artist = _artist;
			artworkRegister[_contract].factory = msg.sender;
			artworkRegister[_contract].isIndexed = _indexed;
			artworkRegister[_contract].isOuroboros = _ouroboros;
			artworkIndex[artworkCount] = _contract;
			artistsArtworks[_artist][artistsArtworkCount[_artist]] = _contract;
			artistsArtworkCount[_artist]++;
			artworksFactory[_contract] = msg.sender;
			NewArtwork (_contract, _SHA256Hash, _editionSize, _title, _fileLink, _ownerCommission, _artist, _indexed, _ouroboros);
			artworkCount++;
			}
			else {throw;}
		}
	function isSHA256HashRegistered (bytes32 _SHA256Hash) returns (bool _registered)
		{
		if (SHA256HashRegister[_SHA256Hash] == 0x0)
			{return false;}
		else {return true;}
		}
	function approveFactoryContract (address _factoryContractAddress, bool _approved) onlyBy (owner)
		{
			approvedFactories[_factoryContractAddress] = _approved;
		}
	function isFactoryApproved (address _factory) returns (bool _approved)
		{
			if (approvedFactories[_factory])
			{
				return true;
			}
			else {return false;}
		}
	function withdrawFunds (uint256 _ETHAmount, address _to) onlyBy (owner)
		{
			if (this.balance >= _ETHAmount)
			{
				_to.transfer(_ETHAmount);
			}
			else {throw;}
		}
	function transferByAddress (address _contract, uint256 _amount, address _to) onlyBy (owner) 
		{
			Interface c = Interface(_contract);
			c.transfer(_to, _amount);
		}
	function transferIndexedByAddress (address _contract, uint256 _index, address _to) onlyBy (owner)
		{
			Interface c = Interface(_contract);
			c.transferIndexed(_to, _index);
		}
	function approveByAddress (address _contract, address _spender, uint256 _amount) onlyBy (owner)
		{
			Interface c = Interface(_contract);
			c.approve(_spender, _amount);
		}	
	function approveIndexedByAddress (address _contract, address _spender, uint256 _index) onlyBy (owner)
		{
			Interface c = Interface(_contract);
			c.approveIndexed(_spender, _index);
		}
	function burnByAddress (address _contract, uint256 _amount) onlyBy (owner)
		{
			Interface c = Interface(_contract);
			c.burn(_amount);
		}
	function burnFromByAddress (address _contract, uint256 _amount, address _from) onlyBy (owner)
		{
			Interface c = Interface(_contract);
			c.burnFrom (_from, _amount);
		}
	function burnIndexedByAddress (address _contract, uint256 _index) onlyBy (owner)
		{
			Interface c = Interface(_contract);
			c.burnIndexed(_index);
		}
	function burnIndexedFromByAddress (address _contract, address _from, uint256 _index) onlyBy (owner)
		{
			Interface c = Interface(_contract);
			c.burnIndexedFrom(_from, _index);
		}
	function offerPieceForSaleByAddress (address _contract, uint256 _price) onlyBy (owner)
		{
			Interface c = Interface(_contract);
			c.offerPieceForSale(_price);
		}
	function fillBidByAddress (address _contract) onlyBy (owner)							 
		{
			Interface c = Interface(_contract);
			c.fillBid();
		}
	function cancelSaleByAddress (address _contract) onlyBy (owner)							 
		{
			Interface c = Interface(_contract);
			c.cancelSale();
		}
	function offerIndexedPieceForSaleByAddress (address _contract, uint256 _index, uint256 _price) onlyBy (owner)			 
		{
			Interface c = Interface(_contract);
			c.offerIndexedPieceForSale(_index, _price);
		}
	function fillIndexedBidByAddress (address _contract, uint256 _index) onlyBy (owner)					 
		{
			Interface c = Interface(_contract);
			c.fillIndexedBid(_index);
		}
	function cancelIndexedSaleByAddress (address _contract) onlyBy (owner)								 
		{
			Interface c = Interface(_contract);
			c.cancelIndexedSale();
		}
	function() payable
		{
			if (!approvedContracts[msg.sender]) {throw;}						 
		}
	function callContractFunctionByAddress(address _contract, string functionNameAndTypes, address _address1, address _address2, uint256 _value1, uint256 _value2, bool _bool, string _string, bytes32 _bytes32) onlyBy (owner)
	{
		if(!_contract.call(bytes4(sha3(functionNameAndTypes)),_address1, _address2, _value1, _value2, _bool, _string, _bytes32)) {throw;}
	}
}
