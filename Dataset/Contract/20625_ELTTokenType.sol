contract ELTTokenType {
    uint public decimals;
    uint public totalSupply;
    mapping(address => uint) balances;
    mapping(address => uint) timevault;
    mapping(address => mapping(address => uint)) allowed;
    bool public released;
    uint public releaseFinalizationDate;
}