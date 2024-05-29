contract TimedStateMachine is StateMachine {
    event StateStartTimeSet(bytes32 indexed _stateId, uint256 _startTime);
    mapping(bytes32 => uint256) private startTime;
    function getStateStartTime(bytes32 _stateId) public view returns(uint256) {
        return startTime[_stateId];
    }
    function setStateStartTime(bytes32 _stateId, uint256 _timestamp) internal {
        require(block.timestamp < _timestamp);
        if (startTime[_stateId] == 0) {
            addStartCondition(_stateId, hasStartTimePassed);
        }
        startTime[_stateId] = _timestamp;
        emit StateStartTimeSet(_stateId, _timestamp);
    }
    function hasStartTimePassed(bytes32 _stateId) internal returns(bool) {
        return startTime[_stateId] <= block.timestamp;
    }
}
