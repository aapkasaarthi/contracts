// const hre = require("hardhat");

async function main() {

    const [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    console.log("Deploying contracts with the account:",owner.address);
    console.log("Account Balance:", ethers.utils.formatEther(await owner.getBalance()).toString());

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

}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
