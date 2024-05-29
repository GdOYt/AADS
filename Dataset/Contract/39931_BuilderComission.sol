contract BuilderComission is Builder {
    function create(address _ledger, bytes32 _taxman, uint _taxPerc,
                    address _client) payable returns (address) {
        if (buildingCostWei > 0 && beneficiary != 0) {
            if (msg.value < buildingCostWei) throw;
            if (!beneficiary.send(buildingCostWei)) throw;
            if (msg.value > buildingCostWei) {
                if (!msg.sender.send(msg.value - buildingCostWei)) throw;
            }
        } else {
            if (msg.value > 0) {
                if (!msg.sender.send(msg.value)) throw;
            }
        }
        if (_client == 0)
            _client = msg.sender;
        var inst = CreatorComission.create(_ledger, _taxman, _taxPerc);
        inst.delegate(_client);
        Builded(_client, inst);
        getContractsOf[_client].push(inst);
        return inst;
    }
}
