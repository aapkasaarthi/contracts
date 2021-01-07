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

    let saarthi;
    let owner;
    let addr1;
    let addr2;
    let addrs;

    beforeEach(async function () {
        const Saarthi = await ethers.getContractFactory("Saarthi");
        saarthi = await Saarthi.deploy();
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
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

    describe("Reports", accounts => {

        it("should create a report", async() =>{

            await saarthi.fileReport(
                ethers.utils.formatBytes32String('37.4221 N, 122.0841 W'),
                getBytes32FromIpfsHash('QmR3VgpgJcGJZX4iazxBcvn2G7jHktLCdozaWF6Hp8DLLH'),
                'An Anonymous Report filed at GooglePlex.'
            );
            expect(await saarthi.reportCnt()).to.equal(1);
        })

    });



      /*


    it("should register user", async() =>{
        await instance.addUser({from: owner})
        let uc = await instance.UserCnt({from: owner})
        assert.equal(uc.toString(), '1')
    })

    it("should create a Campaign", async() =>{
        await instance.addUser({from: owner})
        await instance.createCampaign('New campaign', {from: owner})
        let ud = await instance.Users(owner, {from: owner})
        assert.equal(ud.hasCampaign, true)
    })

    it("should donate to a campaign", async() =>{
        await instance.addUser({from: owner})
        await instance.createCampaign('New campaign', {from: owner})
        await instance.donateToUser(owner, {from: owner, value:web3.utils.toWei('1', 'ether')})
        let ud = await instance.Users(owner, {from: owner})
        assert.equal(ud.donationCnt.toString(), '1')
    })

    it("should stop campaign", async() =>{
        await instance.addUser({from: owner})
        await instance.createCampaign('New campaign', {from: owner})
        await instance.stopCampaign({from: owner})
        let ud = await instance.Users(owner, {from: owner})
        assert.equal(ud.hasCampaign, false)
    })

    it("should create a report", async() =>{
        await instance.addUser({from: owner})
        await instance.fileReport(
            'Anonymous',
            'Location',
            'Qm2m2',
            'Anonym Report',
        {from: owner})
        let rc = await instance.reportCnt({from: owner})
        assert.equal(rc.toString(), '1')
    })

    it("should store a file", async() =>{
        await instance.addUser({from: owner})
        await instance.addRecord('Qm2m2',{from: owner})
        let ud = await instance.Users(owner, {from: owner})
        assert.equal(ud.recordHistoryCnt.toString(), '1')
    })

    */
});

