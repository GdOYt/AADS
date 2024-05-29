contract DSStop is DSAuth, DSNote {
    bool public stopped;
    modifier stoppable {
        assert (!stopped);
        _;
    }
    function stop() auth note {
        stopped = true;
    }
    function start() auth note {
        stopped = false;
    }
}
