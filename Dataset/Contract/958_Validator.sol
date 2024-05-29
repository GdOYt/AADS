contract Validator {
    address public validator;
    event NewValidatorSet(address indexed previousOwner, address indexed newValidator);
    constructor() public {
        validator = msg.sender;
    }
    modifier onlyValidator() {
        require(msg.sender == validator);
        _;
    }
    function setNewValidator(address newValidator) public onlyValidator {
        require(newValidator != address(0));
        emit NewValidatorSet(validator, newValidator);
        validator = newValidator;
    }
}
