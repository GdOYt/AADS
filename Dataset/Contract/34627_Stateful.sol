contract Stateful {
    enum State {
        Initial,
        PreSale,
        WaitingForSale,
        Sale,
        CrowdsaleCompleted,
        SaleFailed
    }
    State public state = State.Initial;
    event StateChanged(State oldState, State newState);
    function setState(State newState) internal {
        State oldState = state;
        state = newState;
        StateChanged(oldState, newState);
    }
}
