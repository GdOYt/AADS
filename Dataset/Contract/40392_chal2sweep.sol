contract chal2sweep {
    address chal = 0x08d698358b31ca6926e329879db9525504802abf;
    address noel = 0x1488e30b386903964b2797c97c9a3a678cf28eca;
    modifier only_noel { if (msg.sender == noel) _ }
    modifier msg_value_not(uint _amount) {
        if (msg.value != _amount) _
    }
    function withdraw(uint _amount) only_noel {
        if (!noel.send(_amount)) throw;
    }
    function kill() only_noel {
        suicide(noel);
    }
    function () msg_value_not(10000000000000000000) {
        if (!chal.call("withdrawEtherOrThrow", 10000000000000000000))
            throw;
    }
}
