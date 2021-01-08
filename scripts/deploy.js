// const hre = require("hardhat");

async function main() {

    const [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    console.log("Deploying contracts with the account:",owner.address);
    console.log("Account Balance:", ethers.utils.formatEther(await owner.getBalance()).toString());

    const Registry = await ethers.getContractFactory("Registry");
    const registry = await Registry.deploy();

    const Saarthi = await ethers.getContractFactory("Saarthi");
    const logic = await Saarthi.deploy();

    await registry.setLogicContract(logic.address);

    const saarthi = Saarthi.attach(registry.address);
    await saarthi.initialize();

    console.log("Proxy deployed to:", registry.address);
    console.log("Saarthi Logic deployed to:", logic.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
