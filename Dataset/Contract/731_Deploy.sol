contract Deploy is GobernanceFunctions{
    constructor() public {
        owner = msg.sender;
        forTesting();
    }
    function forTesting() internal{
        addBank(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c,1);
        addBank(0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db,1);
        addTokensToBank(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c,20000);
        addTokensToBank(0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db,40000);
        addClient(0x583031d1113ad414f02576bd6afabfb302140225, 1);
        addClient(0xdd870fa1b7c4700f2bd7f44238821c26f7392148, 1);     
        changeClientCategory(0x583031d1113ad414f02576bd6afabfb302140225, 5);
        changeClientCategory(0xdd870fa1b7c4700f2bd7f44238821c26f7392148, 5);
    }
}
