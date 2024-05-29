contract FrostByte is FBT {
    event tokenBought(uint256 totalTokensBought, uint256 Price);
    event etherSent(uint256 total);
    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = '0.4';
    function FrostByte() {
        name = "FrostByte";
        decimals = 4;
        symbol = "FBT";
        pieceprice = 1 ether / 256;
        datestart = now;
    }
    function () payable {
        bytes1 addrLevel = getAddressLevel();
        uint256 generateprice = getPrice(addrLevel);
        if (msg.value<generateprice) revert();
        uint256 seventy = msg.value / 100 * 30;
        uint256 dev = seventy / 2;
        dev1.transfer(dev);
        dev2.transfer(dev);
        totalaccumulated += seventy;
        uint256 generateamount = msg.value * 10000 / generateprice;
        totalSupply += generateamount;
        balances[msg.sender]=generateamount;
        feebank[msg.sender]+=msg.value-seventy;
        refundFees();
        tokenBought(generateamount, msg.value);
    }
    function sendEther(address x) payable {
        x.transfer(msg.value);
        refundFees();
        etherSent(msg.value);
    }
    function feeBank(address x) constant returns (uint256) {
        return feebank[x];
    }
    function getPrice(bytes1 addrLevel) constant returns (uint256) {
        return pieceprice * uint256(addrLevel);
    }
    function getAddressLevel() returns (bytes1 res) {
        if (addresslevels[msg.sender]>0) return addresslevels[msg.sender];
        bytes1 highest = 0;
        for (uint256 i=0;i<20;i++) {
            bytes1 c = bytes1(uint8(uint(msg.sender) / (2**(8*(19 - i)))));
            if (bytes1(c)>highest) highest=c;
        }
        addresslevels[msg.sender]=highest;
        return highest;
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }
}
