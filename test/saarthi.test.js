const bs58 = require('bs58')
const { expect } = require("chai");

function getBytes32FromIpfsHash(ipfsListing) {
  return "0x" + bs58.decode(ipfsListing).slice(2).toString('hex')
}

function getIpfsHashFromBytes32(bytes32Hex) {
  const hashHex = "1220" + bytes32Hex.slice(2)
  const hashBytes = Buffer.from(hashHex, 'hex');
  const hashStr = bs58.encode(hashBytes)
  return hashStr
}

describe("Saarthi", accounts => {

    let registry;
    let saarthi;
    let owner;
    let addr1;
    let addr2;
    let addrs;

    beforeEach(async function () {
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        const Registry = await ethers.getContractFactory("Registry");
        registry = await Registry.deploy();

        const Saarthi = await ethers.getContractFactory("Saarthi");
        const logic = await Saarthi.deploy();

        await registry.setLogicContract(logic.address);

        saarthi = Saarthi.attach(registry.address);

        await saarthi.initialize();
    });


    describe("Deployments", accounts => {

        it("Should deploy contract", async function () {
            expect(true).to.equal(true);
        });

        it("Should pause contract", async () => {
            await saarthi.togglePause();
            expect(await saarthi.paused()).to.equal(true);
        });

        it("Should unpause contract", async () => {
            await saarthi.togglePause();
            await saarthi.togglePause();
            expect(await saarthi.paused()).to.equal(false);
        });

    });

    describe("Decentralized Computation", accounts => {

        it("Should create a new Task", async() => {
            await saarthi.createTask(
                getBytes32FromIpfsHash('QmR3VgpgJcGJZX4iazxBcvn2G7jHktLCdozaWF6Hp8DLLH'),
                3
            );
            expect(await saarthi.nextTaskID()).to.equal(2);
        })

        it("Should update a Task", async() => {
            await saarthi.createTask(
                getBytes32FromIpfsHash('QmR3VgpgJcGJZX4iazxBcvn2G7jHktLCdozaWF6Hp8DLLH'),
                3
            );
            expect(await saarthi.nextTaskID()).to.equal(2);
            await saarthi.updateModelForTask(1, getBytes32FromIpfsHash('QmR3VgpgJcGJZX4iazxBcvn2G7jHktLCdozaWF6Hp8DLLH'), addr1.getAddress());
        })

    });

    describe("Hospitals", accounts => {

        it("Should enroll hospitals", async() => {

            await saarthi.toggleHospital(addr1.getAddress())
            expect(await saarthi.hospitals(addr1.getAddress())).to.equal(true);

        })

        it("Should enroll hospitals", async() => {

            await saarthi.toggleHospital(addr1.getAddress())
            expect(await saarthi.hospitals(addr1.getAddress())).to.equal(true);
            await saarthi.toggleHospital(addr1.getAddress())
            expect(await saarthi.hospitals(addr1.getAddress())).to.equal(false);

        })

        it("Should bill user", async() => {

            await saarthi.toggleHospital(addr1.getAddress())
            expect(await saarthi.hospitals(addr1.getAddress())).to.equal(true);
            await saarthi.connect(addr1).billUser(
                addr2.getAddress(),
                '1000000000000000000'
            )

            expect(
                await saarthi.billAmounts(addr2.getAddress())
            ).to.equal('1000000000000000000');

        })

    });

    describe("CrowdFunding", accounts => {

        it("Should create Fund1", async() =>{
            await saarthi.createFund(
                ethers.utils.formatBytes32String('WHO'),
                ethers.utils.formatBytes32String('COVID-19 Solidarity Fund'),
                owner.getAddress()
            );
            expect(await saarthi.fundCnt()).to.equal(1);
        })

        it("Should create Fund2", async() =>{
            await saarthi.createFund(
                ethers.utils.formatBytes32String('GlobalGiving'),
                ethers.utils.formatBytes32String('Coronavirus Relief Fund'),
                owner.getAddress()
            );
            expect(await saarthi.fundCnt()).to.equal(1);
        })

        it("Should create Fund2", async() =>{
            await saarthi.createFund(
                ethers.utils.formatBytes32String('Binance Charity'),
                ethers.utils.formatBytes32String('Crypto Against COVID'),
                owner.getAddress()
            );
            expect(await saarthi.fundCnt()).to.equal(1);
        })

        it("Should donate to Fund1", async() =>{
            await saarthi.createFund(
                ethers.utils.formatBytes32String('WHO'),
                ethers.utils.formatBytes32String('COVID-19 Solidarity Fund'),
                owner.getAddress()
            );
            expect(await saarthi.fundCnt()).to.equal(1);

            await saarthi.donateToFund(0, {value:ethers.utils.parseEther('1')})
            expect(await saarthi.totalDonationCnt()).to.equal(1);
            expect(await saarthi.totalDonationAmount()).to.equal(ethers.utils.parseEther('1'));
        })

    });

    describe("Campaigning", accounts => {

        it("Should create a campaign", async() => {
            await saarthi.connect(addr1).startCampaign(getBytes32FromIpfsHash('QmR3VgpgJcGJZX4iazxBcvn2G7jHktLCdozaWF6Hp8DLLH'));
            expect(await saarthi.campaignEnabled(
                addr1.getAddress()
            )).to.equal(true);
        })

        it("should donate to a campaign", async() =>{
            await saarthi.connect(addr1).startCampaign(getBytes32FromIpfsHash('QmR3VgpgJcGJZX4iazxBcvn2G7jHktLCdozaWF6Hp8DLLH'));
            expect(await saarthi.campaignEnabled(
                addr1.getAddress()
            )).to.equal(true);

            await saarthi.connect(owner).donateToCampaign(
                addr1.getAddress(),
                {value: ethers.utils.parseEther('1')}
            );

            expect(await saarthi.connect(addr1).campaignEnabled(
                addr1.getAddress()
            )).to.equal(true);
        })

        it("should stop campaign", async() =>{
            await saarthi.connect(addr1).startCampaign(getBytes32FromIpfsHash('QmR3VgpgJcGJZX4iazxBcvn2G7jHktLCdozaWF6Hp8DLLH'));
            expect(await saarthi.campaignEnabled(
                addr1.getAddress()
            )).to.equal(true);

            await saarthi.connect(addr1).stopCampaign();
            expect(await saarthi.campaignEnabled(
                addr1.getAddress()
            )).to.equal(false);
        })

    });

    describe("Anonymous Reporting", accounts => {

        it("Should create a report", async() =>{

            await saarthi.fileReport(
                ethers.utils.formatBytes32String('37.4221 N, 122.0841 W'),
                getBytes32FromIpfsHash('QmR3VgpgJcGJZX4iazxBcvn2G7jHktLCdozaWF6Hp8DLLH'),
                'An Anonymous Report filed at GooglePlex.'
            );
            expect(await saarthi.reportCnt()).to.equal(1);
        })

    });

    describe("Access Handlers", accounts => {

        it("Should allow research access", async() =>{
            expect(await saarthi.approval(owner.getAddress(), addr1.getAddress())).to.equal(false);
            await saarthi.toggleAccessToAddress(addr1.getAddress());
            expect(await saarthi.approval(owner.getAddress(), addr1.getAddress())).to.equal(true);
        })

        it("Should revoke research access", async() =>{
            await saarthi.toggleAccessToAddress(addr1.getAddress());
            expect(await saarthi.approval(owner.getAddress(), addr1.getAddress())).to.equal(true);

            await saarthi.toggleAccessToAddress(addr1.getAddress());
            expect(await saarthi.approval(owner.getAddress(), addr1.getAddress())).to.equal(false);
        })

        it("Should update Admin of contract", async() => {
            await saarthi.updateAdmin(owner.getAddress());
        })

    });

    describe("Upgradability", accounts => {

        it("Should Upgrade the contract saving state.", async() => {

            //Deploy new Logic
            const Saarthi = await ethers.getContractFactory("Saarthi");
            const logic = await Saarthi.deploy();

            // Connect new logic
            await registry.setLogicContract(logic.address);

            // check if version got updated
            expect(await saarthi.version()).to.equal(2);
        })

    });
});

