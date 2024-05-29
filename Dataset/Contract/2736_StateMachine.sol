contract StateMachine {
    struct State { 
        bytes32 nextStateId;
        mapping(bytes4 => bool) allowedFunctions;
        function() internal[] transitionCallbacks;
        function(bytes32) internal returns(bool)[] startConditions;
    }
    mapping(bytes32 => State) states;
    bytes32 private currentStateId;
    event Transition(bytes32 stateId, uint256 blockNumber);
    modifier checkAllowed {
        conditionalTransitions();
        require(states[currentStateId].allowedFunctions[msg.sig]);
        _;
    }
    function conditionalTransitions() public {
        bool checkNextState; 
        do {
            checkNextState = false;
            bytes32 next = states[currentStateId].nextStateId;
            for (uint256 i = 0; i < states[next].startConditions.length; i++) {
                if (states[next].startConditions[i](next)) {
                    goToNextState();
                    checkNextState = true;
                    break;
                }
            } 
        } while (checkNextState);
    }
    function getCurrentStateId() view public returns(bytes32) {
        return currentStateId;
    }
    function setStates(bytes32[] _stateIds) internal {
        require(_stateIds.length > 0);
        require(currentStateId == 0);
        require(_stateIds[0] != 0);
        currentStateId = _stateIds[0];
        for (uint256 i = 1; i < _stateIds.length; i++) {
            require(_stateIds[i] != 0);
            states[_stateIds[i - 1]].nextStateId = _stateIds[i];
            require(states[_stateIds[i]].nextStateId == 0);
        }
    }
    function allowFunction(bytes32 _stateId, bytes4 _functionSelector) 
        internal 
    {
        states[_stateId].allowedFunctions[_functionSelector] = true;
    }
    function goToNextState() internal {
        bytes32 next = states[currentStateId].nextStateId;
        require(next != 0);
        currentStateId = next;
        for (uint256 i = 0; i < states[next].transitionCallbacks.length; i++) {
            states[next].transitionCallbacks[i]();
        }
        emit Transition(next, block.number);
    }
    function addStartCondition(
        bytes32 _stateId,
        function(bytes32) internal returns(bool) _condition
    ) 
        internal 
    {
        states[_stateId].startConditions.push(_condition);
    }
    function addCallback(bytes32 _stateId, function() internal _callback)
        internal 
    {
        states[_stateId].transitionCallbacks.push(_callback);
    }
}
