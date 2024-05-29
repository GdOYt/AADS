contract Stateful {
  enum State {
  Init,
  PreIco,
  PreIcoPaused,
  preIcoFinished,
  ICO,
  salePaused,
  CrowdsaleFinished,
  companySold
  }
  State public state = State.Init;
  event StateChanged(State oldState, State newState);
  function setState(State newState) internal {
    State oldState = state;
    state = newState;
    StateChanged(oldState, newState);
  }
}
