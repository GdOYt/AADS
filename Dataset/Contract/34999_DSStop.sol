contract DSStop is DSNote, DSAuth {
    bool public stopped;
    modifier stoppable {
        require(!stopped);
        _;
    }
    function stop() auth note {
        stopped = true;
    }
    function start() auth note {
        stopped = false;
    }
}
