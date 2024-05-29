contract Controller{
	function getChampReward(uint _position) public view returns(uint);
	function changeChampsName(uint _champId, string _name, address _msgsender) external;
	function withdrawChamp(uint _id, address _msgsender) external;
	function attack(uint _champId, uint _targetId, address _msgsender) external;
	function transferToken(address _from, address _to, uint _id, bool _isTokenChamp) external;
	function cancelTokenSale(uint _id, address _msgsender, bool _isTokenChamp) public;
	function giveToken(address _to, uint _id, address _msgsender, bool _isTokenChamp) external;
	function setTokenForSale(uint _id, uint _price, address _msgsender, bool _isTokenChamp) external;
	function getTokenURIs(uint _id, bool _isTokenChamp) public pure returns(string);
	function takeOffItem(uint _champId, uint8 _type, address _msgsender) public;
	function putOn(uint _champId, uint _itemId, address _msgsender) external;
	function forgeItems(uint _parentItemID, uint _childItemID, address _msgsender) external;
}
