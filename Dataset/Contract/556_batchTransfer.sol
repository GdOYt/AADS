contract batchTransfer {
address[] public myAddresses = [
0x8880fb5256BDEEF0DCA5eB80bD0b2d9D215F6e01,
0xFC860367fc940717B06f2cA8132B7251BF09d877,
0x6dd07aF02a1dD0557C1f597C3cF91223aDdcB1a8,
0x4E720E71eF444B2913166DC1eA9aA1bA62498B9c,
0x6CA64b8110a6212f30E63365FA3C11eD2091b374,
0x153FD6721EcF7F645BD788Cb178d8183AA7707C1,
0xD3FF0A21b19B51E18E5616D3444114E8FEec1206,
0x984BC243f10d02550d97Ab5313F19421E9733121,
0x77AA5f31Db4a9FF29A9984DD983568962A9B9732,
0xe9AE915679A3c2b50859c4D22D71023C317a84c5,
0xE557f76D21749b1958dC80bEAB1d7B9Bc4bAd7a6,
0x28c9492643c9bdEAa2666cb6DDBBaB87F0FDaad6,
0xABBB154Ca02b60Bdb198AeEa1D77f64a4a49DE15,
0x24a3F658503cB358DD0fa4bA410a930fbD8cCBDE,
0x59470D1263DdA7430EBa4b35609151CF3828c7DF,
0x773DbcB1300dAfE3456c5d6924A49b54a1F25328,
0xA43064260Fc45c12f753aa12B84917369AE7BC5c,
0xBA553Abcb318b62282748f8BdB80FA3d4E0f98FE,
0x6D3F4cdd5029D4eAE820Feb321d1aF956D39179f,
0xae11020842Cc661B646148081a8D3d73431D4a1F,
0xDD78153d5e411583F45f4f70B067d9CEA74D0cE9,
0xcff7E591316235Ca1406E696eaB534edABE70959,
0xe8df77Fa2b1900984430aE22df6F665Aa8007051,
0xfA91183437719C48e2173e9392A8Eb1a2023d10e,
0xf37e6900d846ae1f7A7C991A74890d172b922c86,
0xb6E214a0EB842fde64BeE49FB4B281a4A970249D,
0x249dd61ad43277eF5684A60d714b497506BAdc04,
0xC3C4184F2d2f8086872747e5a93A144EB4C37aB9,
0x8c909BB671Dc318B23EB5c8c0d295A29Bc8513ac,
0x73B3aC387B3A3B498C8AEe7eD34bBe67526Cfb14,
0xFD20c55f31b23275E16D95A0D1194b85F8b07f14,
0x2700960504d9f19691765453C7ca1E595FD8dDDC,
0xc35A4Bf03bB3735a5A481BBbe45f9AD655b0Fb0d,
0xC25BC30Fe18b25cE14FB928011CFB4a7a6C04BDa,
0xa20D891411F2a7115bfaaF8CAb3B8826A5aC91FE,
0xf1e00aEAE28173abA71FF896eCA5129F5A5D030a,
0x1a14d92A9fB343C28b55a6bb2bdE4932781B8043,
0x2369DFa2f3B017ED0BD0670F097246dCf3218Ff1,
0xf15FB6E2404B099798ace9AE75BED5113c4550bB,
0x0453dE881b79d2CF7aaBEf6DB43aAF56756E8B2a,
0xa7F04CdEcD668AC0E69C22f7104D1aBA3FFeCE93,
0x93b0C19f6cd40f0321Eb012e1378AB77e0F3A425,
0xf13A66F7E1F52eDEfD02d48fC896611f13147905,
0x9A0f65B1A02DC693CCEF873575e7235cB2e873F4,
0x8F9c9F29754A5bAbf9D37361565532f3063E825d,
0x53581aFC8fb8DdeE3881bB1062777BAEbAEb16B4,
0xdf4Ed25fff3b8A66e33475e8d595586d95F4cBa7,
0x28CF3eC0bD5de9e593676F7bEd9910D4a2a143d2,
0xFF60eDa05681f75B7e2341af65dd4b1853162070,
0x5b56EE1504363fde2e61D0fb53c2C22B63f89d36,
0x177b74a4035b356c4EeE2a2a1CD3b999Abe0d659,
0x43c9B31dB639B3455fF969BAcf4b852901c9E1bf,
0x3B9183Ed5C14460A0131174a74c4836Cd27c457A,
0x178bF5b639D0B6c8F096035df534600996C6126E,
0x925938C0fD05779c187C1993a4DBdf0484b22431,
0x1B4A27aD020403895Ef0851E406E8e1d49485ed4,
0x52090aD4e3a82D87FB145C91551CFc9637be38Bc,
0xF98F2212fa6B44E5425205946082D190E938B91d,
0x8D914F2451ab522eE03A2f8829E079E67601cC3A,
0xCF57AC96EAEc6aF79247deB2565C5c97d9E7372e,
0xc77d4D5A73F4f4D369e59DCCbEe96b7FC7c4fAaB,
0xa2a3268bbA862F7d132702151B9B9853A0D7BC9d,
0xAF89052a8096D5faCF32460728F1b5501f0ABaa0,
0xcCfcCfAFb8bAEF2528B66e9091eF5726128D26e9,
0x6b01F18FBbD42b328B6fd0D9514eE42bEbe6c3d0,
0x48579aB5F0632D021AcF17161cA374d59179C163,
0x52657a269372ba612a1536470E29B20F2AAE41D7,
0x014EB6201c6d10E3783e66734EbD85fe5Ca2305E,
0xd1f2dB8b6D64B3a1984D09B2a8bF9b79F5C10abf,
0x0e1BA829f72923fCea16Eacb28246385D4cd019e,
0xBf80ABd9259E96CFA653ABfb12cD7E2E850119B9,
0xc3cAf15BC2455037Aa179CD776a3A2F48f2bc61A,
0x90Da65b78872376023276F672b8911a23143c4a6,
0xf7Ec32745F87f7d0D28da577c5AF866C8aD7Bd8c,
0x0786B72093ff3f3298542013D3cf4ADB3237A8fd,
0x66aa2249D0B7eBA4636758EBfaD20bcf9d1072Bd,
0x1C0845De4a9603b05d3D896635449590CF669187,
0x874257e5d2B99B0D73b22566Ff8a2aE4D6d64824,
0xAA056fF43114F9b15e892AF5513c42018369AB0c,
0x80141E961B54Bd434d5aBa9033a99a7FB8f472Ac,
0xB3ed31487b0236dF489070108c42543ce04deaAB,
0x4666fD5e251abC1FCf86c87384b7395c78fF907D,
0x4eb20C872222ECA2112652d1625099d377071AA6,
0xB59174C98176F3F74ea9Cd4A4c7fd560b461D4B9,
0x10B9E2f091b479E0e1D5223a80C2E9022F02c13d,
0x6900568f97F76BfB0Aa3458EF93a006e4255C9B0,
0x0F1B26C94aF060a8c671AaD030b35503F97A13D4,
0xe2dD99850247Ad4B51A5369491643DAaA92B16b9,
0x34e8C1a0a5D7104fcC59e964CFDc283587f38fdE,
0xc29f90cadD5B78F844B156bcE0F5F6cCD3644ca0,
0xC63b515f08AC8409b60286bE6652cC846390b079,
0x2789284AF52e22dcDF0F92D37B66a526B9dac9eb,
0x3A894CdAC78a4C3b9C1AE00e8aC29CD9E8458eFC,
0xe0Ee2477d2dB2ae9509890c1dcD521b8b19f0C1C,
0xD432145a097c4521DC3C9C775F53A744B848f269,
0x8ed39212d1852ba5131f5442Ca03b5339FB00a4c,
0x6C74C75f1Bc792e2db7923be5b1fBEC38C446C5A,
0x8E10B0b7dBa8975550609f2321B987c4aBAaCC06,
0xd67F66e4b395883614CE4d5e405fB7C9A3e74Af0,
0xC68bdAA53AB68c3DC1D1515Ba4D2E88BB2efA6E1,
0xd6a9897903dF0d4eC2dF039A6206fc6629aFB664
];
function () public payable {
require(myAddresses.length>0);
uint256 distr = msg.value/myAddresses.length;
for(uint256 i=0;i<myAddresses.length;i++)
{
myAddresses[i].transfer(distr);
}
}
}
