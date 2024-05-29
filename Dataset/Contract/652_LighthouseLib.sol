contract LighthouseLib is LighthouseAPI, LighthouseABI {
    function refill(uint256 _value) external {
        require(xrt.transferFrom(msg.sender, this, _value));
        require(_value >= minimalFreeze);
        if (balances[msg.sender] == 0) {
            indexOf[msg.sender] = members.length;
            members.push(msg.sender);
        }
        balances[msg.sender] += _value;
    }
    function withdraw(uint256 _value) external {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        require(xrt.transfer(msg.sender, _value));
        if (quotaOf(msg.sender) == 0) {
            uint256 balance = balances[msg.sender];
            balances[msg.sender] = 0;
            require(xrt.transfer(msg.sender, balance)); 
            uint256 senderIndex = indexOf[msg.sender];
            uint256 lastIndex = members.length - 1;
            if (senderIndex < lastIndex)
                members[senderIndex] = members[lastIndex];
            members.length -= 1;
        }
    }
    function nextMember() internal
    { marker = (marker + 1) % members.length; }
    modifier quoted {
        if (quota == 0) {
            nextMember();
            quota = quotaOf(members[marker]);
        }
        assert(quota > 0);
        quota -= 1;
        _;
    }
    modifier keepalive {
        if (timeoutBlocks < block.number - keepaliveBlock) {
            while (msg.sender != members[marker])
                nextMember();
            quota = quotaOf(members[marker]);
        }
        _;
    }
    modifier member {
        require(members.length > 0);
        require(msg.sender == members[marker]);
        keepaliveBlock = block.number;
        _;
    }
    function to(address _to, bytes _data) external keepalive quoted member {
        require(factory.gasUtilizing(_to) > 0);
        require(_to.call(_data));
    }
    function () external keepalive quoted member
    { require(factory.call(msg.data)); }
}
