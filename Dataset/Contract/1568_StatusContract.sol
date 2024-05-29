contract StatusContract is Ownable {
    mapping(uint => mapping(string => uint[])) internal statusRewardsMap;
    mapping(address => uint) internal statuses;
    event StatusChanged(address participant, uint newStatus);
    function StatusContract() public {
        statusRewardsMap[1]['deposit'] = [3, 2, 1];
        statusRewardsMap[1]['refReward'] = [3, 1, 1];
        statusRewardsMap[2]['deposit'] = [7, 3, 1];
        statusRewardsMap[2]['refReward'] = [5, 3, 1];
        statusRewardsMap[3]['deposit'] = [10, 3, 1, 1, 1];
        statusRewardsMap[3]['refReward'] = [7, 3, 3, 1, 1];
        statusRewardsMap[4]['deposit'] = [10, 5, 3, 3, 1];
        statusRewardsMap[4]['refReward'] = [10, 5, 3, 3, 3];
        statusRewardsMap[5]['deposit'] = [12, 5, 3, 3, 3];
        statusRewardsMap[5]['refReward'] = [10, 7, 5, 3, 3];
    }
    function getStatusOf(address participant) public view returns (uint) {
        return statuses[participant];
    }
    function setStatus(address participant, uint8 status) public onlyOwner returns (bool) {
        return setStatusInternal(participant, status);
    }
    function setStatusInternal(address participant, uint8 status) internal returns (bool) {
        require(statuses[participant] != status && status > 0 && status <= 5);
        statuses[participant] = status;
        StatusChanged(participant, status);
        return true;
    }
}
