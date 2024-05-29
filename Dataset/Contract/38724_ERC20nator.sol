contract ERC20nator is StandardToken, Ownable {
    address public fundraiserAddress;
    bytes public fundraiserCallData;
    uint constant issueFeePercent = 2;  
    event requestedRedeem(address indexed requestor, uint amount);
    event redeemed(address redeemer, uint amount);
    function() payable {
        uint issuedTokens = msg.value * (100 - issueFeePercent) / 100;
        if(!owner.send(msg.value - issuedTokens))
            throw;
        if(!fundraiserAddress.call.value(issuedTokens)(fundraiserCallData))
            throw;
        totalSupply += issuedTokens;
        balances[msg.sender] += issuedTokens;
    }
    function setFundraiserAddress(address _fundraiserAddress) onlyOwner {
        fundraiserAddress = _fundraiserAddress;
    }
    function setFundraiserCallData(string _fundraiserCallData) onlyOwner {
        fundraiserCallData = hexStrToBytes(_fundraiserCallData);
    }
    function requestRedeem(uint _amount) {
        requestedRedeem(msg.sender, _amount);
    }
    function redeem(uint _amount) onlyOwner{
        redeemed(msg.sender, _amount);
    }
    function hexStrToBytes(string _hexString) constant returns (bytes) {
        if (bytes(_hexString)[0]!='0' ||
            bytes(_hexString)[1]!='x' ||
            bytes(_hexString).length%2!=0 ||
            bytes(_hexString).length<4) {
                throw;
            }
        bytes memory bytes_array = new bytes((bytes(_hexString).length-2)/2);
        uint len = bytes(_hexString).length;
        for (uint i=2; i<len; i+=2) {
            uint tetrad1=16;
            uint tetrad2=16;
            if (uint(bytes(_hexString)[i])>=48 &&uint(bytes(_hexString)[i])<=57)
                tetrad1=uint(bytes(_hexString)[i])-48;
            if (uint(bytes(_hexString)[i+1])>=48 &&uint(bytes(_hexString)[i+1])<=57)
                tetrad2=uint(bytes(_hexString)[i+1])-48;
            if (uint(bytes(_hexString)[i])>=65 &&uint(bytes(_hexString)[i])<=70)
                tetrad1=uint(bytes(_hexString)[i])-65+10;
            if (uint(bytes(_hexString)[i+1])>=65 &&uint(bytes(_hexString)[i+1])<=70)
                tetrad2=uint(bytes(_hexString)[i+1])-65+10;
            if (uint(bytes(_hexString)[i])>=97 &&uint(bytes(_hexString)[i])<=102)
                tetrad1=uint(bytes(_hexString)[i])-97+10;
            if (uint(bytes(_hexString)[i+1])>=97 &&uint(bytes(_hexString)[i+1])<=102)
                tetrad2=uint(bytes(_hexString)[i+1])-97+10;
            if (tetrad1==16 || tetrad2==16)
                throw;
            bytes_array[i/2-1]=byte(16*tetrad1 + tetrad2);
        }
        return bytes_array;
    }
}
