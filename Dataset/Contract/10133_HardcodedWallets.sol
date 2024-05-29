contract HardcodedWallets {
	address public walletFounder1;  
	address public walletFounder2;  
	address public walletFounder3;  
	address public walletCommunityReserve;	 
	address public walletCompanyReserve;	 
	address public walletTeamAdvisors;		 
	address public walletBountyProgram;		 
	constructor() public {
		walletFounder1             = 0x5E69332F57Ac45F5fCA43B6b007E8A7b138c2938;  
		walletFounder2             = 0x852f9a94a29d68CB95Bf39065BED6121ABf87607;  
		walletFounder3             = 0x0a339965e52dF2c6253989F5E9173f1F11842D83;  
		walletCommunityReserve = 0xB79116a062939534042d932fe5DF035E68576547;
		walletCompanyReserve = 0xA6845689FE819f2f73a6b9C6B0D30aD6b4a006d8;
		walletTeamAdvisors = 0x0227038b2560dF1abf3F8C906016Af0040bc894a;
		walletBountyProgram = 0xdd401Df9a049F6788cA78b944c64D21760757D73;
	}
}
