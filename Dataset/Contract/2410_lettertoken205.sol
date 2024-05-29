contract lettertoken205 is ERC721Token {
  constructor() public ERC721Token("lettertoken205","lettertoken205") { }
  struct Token{
    uint8 data1;
    uint8 data2;
    uint64 data3;
    uint64 data4;
    uint64 startBlock;
  }
  Token[] private tokens;
  function create(uint8 data1, uint8 data2,uint64 data3, uint64 data4) public returns (uint256 _tokenId) {
    string memory tokenUri = createTokenUri(data1,data2,data3,data4);
    Token memory _newToken = Token({
        data1: data1,
        data2: data2,
        data3: data3,
        data4: data4,
        startBlock: uint64(block.number)
    });
    _tokenId = tokens.push(_newToken) - 1;
    _mint(msg.sender,_tokenId);
    _setTokenURI(_tokenId, tokenUri);
    tokenUri=strConcat(tokenUri,"-");
    string memory tokenIdb=uint2str(_tokenId);
    tokenUri=strConcat(tokenUri, tokenIdb);
    emit Create(_tokenId,msg.sender,data1,data2,data3,data4,_newToken.startBlock,tokenUri);
    return _tokenId;
  }
  event Create(
    uint _id,
    address indexed _owner,
    uint8 _data1,
    uint8 _data2,
    uint64 _data3,
    uint64 _data4,
    uint64 _startBlock,
    string _uri
  );
  function get(uint256 _id) public view returns (address owner,uint8 data1,uint8 data2,uint64 data3,uint64 data4,uint64 startBlock) {
    return (
      tokenOwner[_id],
      tokens[_id].data1,
      tokens[_id].data2,
      tokens[_id].data3,
      tokens[_id].data4,
      tokens[_id].startBlock
    );
  }
  function tokensOfOwner(address _owner) public view returns(uint256[]) {
    return ownedTokens[_owner];
  }
  function createTokenUri(uint8 data1,uint8 data2,uint64 data3,uint64 data4) internal pure returns (string){
    string memory uri = "https://www.millionetherwords.com/exchange/displaytoken/?s=";
    uri = appendUint8ToString(uri,data1);
    uri = strConcat(uri,"-");
    uri = appendUint8ToString(uri,data2);
    uri = strConcat(uri,"-");
    string memory data3b=uint2str(data3);
    uri = strConcat(uri,data3b);
    uri = strConcat(uri,"-");
    string memory data4b=uint2str(data4);
    uri = strConcat(uri,data4b);
    uri = strConcat(uri,".png");
    return uri;
  }
function uint2str(uint i) internal pure returns (string){
    if (i == 0) return "0";
    uint j = i;
    uint length;
    while (j != 0){
        length++;
        j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint k = length - 1;
    while (i != 0){
        bstr[k--] = byte(48 + i % 10);
        i /= 10;
    }
    return string(bstr);
}
  function appendUint8ToString(string inStr, uint8 v) internal pure returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory inStrb = bytes(inStr);
        bytes memory s = new bytes(inStrb.length + i);
        uint j;
        for (j = 0; j < inStrb.length; j++) {
            s[j] = inStrb[j];
        }
        for (j = 0; j < i; j++) {
            s[j + inStrb.length] = reversed[i - 1 - j];
        }
        str = string(s);
    }
    function strConcat(string _a, string _b) internal pure returns (string) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ab = new string(_ba.length + _bb.length);
        bytes memory bab = bytes(ab);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
        return string(bab);
    }
}
