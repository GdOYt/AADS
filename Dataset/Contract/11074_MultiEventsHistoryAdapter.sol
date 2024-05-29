contract MultiEventsHistoryAdapter {
    function _self() constant internal returns (address) {
        return msg.sender;
    }
}
