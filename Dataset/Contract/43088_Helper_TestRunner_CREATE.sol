contract Helper_TestRunner_CREATE is Helper_TestRunner {
    constructor(
        bytes memory _bytecode,
        TestStep[] memory _steps
    )
    {
        if (_steps.length > 0) {
            runMultipleTestSteps(_steps);
        } else {
            assembly {
                return(add(_bytecode, 0x20), mload(_bytecode))
            }
        }
    }
}
