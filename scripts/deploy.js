// const hre = require("hardhat");
const bs58 = require('bs58')

function getBytes32FromIpfsHash(ipfsListing) {
    return "0x" + bs58.decode(ipfsListing).slice(2).toString('hex')
}

function getIpfsHashFromBytes32(bytes32Hex) {
    const hashHex = "1220" + bytes32Hex.slice(2)
    const hashBytes = Buffer.from(hashHex, 'hex');
    const hashStr = bs58.encode(hashBytes)
    return hashStr
}


async function main() {

    const [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    console.log("Deploying contracts with the account:",owner.address);
    console.log("Owner Balance:", ethers.utils.formatEther(await owner.getBalance()).toString());
    console.log("Addr1 Balance:", ethers.utils.formatEther(await addr1.getBalance()).toString());
    console.log("Addr2 Balance:", ethers.utils.formatEther(await addr2.getBalance()).toString());

    const Proxy = await ethers.getContractFactory("Proxy");
    const proxy = await Proxy.deploy();

    const Saarthi = await ethers.getContractFactory("Saarthi");
    const logic = await Saarthi.deploy();

    await proxy.upgradeTo(logic.address);

    const saarthi = Saarthi.attach(proxy.address);
    await saarthi.initialize();

    // npx hardhat verify --network rinkeby 0x25d05E591dA0e7A7f755bcC538d07A6874ae983B
    console.log("Proxy deployed to:", proxy.address);
    console.log("Saarthi Logic deployed to:", logic.address);

    console.log('Decentralized Computation')
    await saarthi.createTask(
        getBytes32FromIpfsHash('QmR3VgpgJcGJZX4iazxBcvn2G7jHktLCdozaWF6Hp8DLLH'),
        3
    );
    await saarthi.updateModelForTask(1, getBytes32FromIpfsHash('QmR3VgpgJcGJZX4iazxBcvn2G7jHktLCdozaWF6Hp8DLLH'), addr1.getAddress());

    console.log('Hospitals')
    await saarthi.connect(owner).toggleHospital(addr1.getAddress())
    await saarthi.connect(addr1).billUser(
        addr2.getAddress(),
        '1000000000000000000'
    )

    console.log('CrowdFunding')
    await saarthi.createFund(
        ethers.utils.formatBytes32String('WHO'),
        ethers.utils.formatBytes32String('COVID-19 Solidarity Fund'),
        owner.getAddress()
    );
    await saarthi.createFund(
        ethers.utils.formatBytes32String('GlobalGiving'),
        ethers.utils.formatBytes32String('Coronavirus Relief Fund'),
        owner.getAddress()
    );
    await saarthi.createFund(
        ethers.utils.formatBytes32String('Binance Charity'),
        ethers.utils.formatBytes32String('Crypto Against COVID'),
        owner.getAddress()
    );
    await saarthi.connect(addr1).donateToFund(0, {value:ethers.utils.parseEther('0.005')});
    await saarthi.connect(addr2).donateToFund(0, {value:ethers.utils.parseEther('0.005')});

    console.log('Campaigns')
    await saarthi.connect(owner).startCampaign(
        getBytes32FromIpfsHash('QmR3VgpgJcGJZX4iazxBcvn2G7jHktLCdozaWF6Hp8DLLH')
    );
    await saarthi.connect(addr1).startCampaign(
        getBytes32FromIpfsHash('QmR3VgpgJcGJZX4iazxBcvn2G7jHktLCdozaWF6Hp8DLLH')
    );
    await saarthi.connect(owner).donateToCampaign(
        addr1.getAddress(),
        {value: ethers.utils.parseEther('0.05')}
    );

    console.log('Reports')
    await saarthi.connect(owner).fileReport(
        ethers.utils.formatBytes32String('37.4221 N, 122.0841 W'),
        getBytes32FromIpfsHash('QmR3VgpgJcGJZX4iazxBcvn2G7jHktLCdozaWF6Hp8DLLH'),
        'An Anonymous Report filed at GooglePlex.'
    );

    await saarthi.connect(addr1).updateReportStatus(
        0,
        'Update about the report'
    );

    console.log('Access handlers')
    await saarthi.connect(owner).approval(owner.getAddress(), addr1.getAddress())
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
