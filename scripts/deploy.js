// const hre = require("hardhat");

async function main() {

    const [deployer] = await ethers.getSigners();

    console.log(
        "Deploying contracts with the account:",
        deployer.address
    );

    console.log("Account balance:", (await deployer.getBalance()).toString());

    const Saarthi = await ethers.getContractFactory("Saarthi");
    const saarthi = await Saarthi.deploy();

    await saarthi.deployed();

    console.log("Saarthi deployed to:", saarthi.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
