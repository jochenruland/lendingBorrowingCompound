
const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider('http://localhost:7545');
const web3 = new Web3(provider);

const compJSON = require('../build/contracts/Comp.json');
const deploymentKey = Object.keys(compJSON.networks)[0];


const daiAbi = require('../scripts/daiAbi.json');
const daiAddress = '0x6B175474E89094C44Da98b954EedeAC495271d0F';
const daiInstance = new web3.eth.Contract(daiAbi, daiAddress);

//const { expectRevert, time } = require('@openzeppelin/test-helpers');
const assert = require('assert');

let accounts;
let contractInstance;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();
  contractInstance = new web3.eth.Contract(compJSON.abi, compJSON.networks[deploymentKey].address);
})

describe('Testing Comp on mainfork', () => {
  it('Contract available on mainfork', () => {
    console.log(contractInstance.options.address);
    console.log(accounts);


    assert.ok(contractInstance.options.address);
  });

  it('Invests dai and recieves iterest on the investment', async () => {

    await daiInstance.methods.transferFrom(accounts[0], contractInstance.options.address, web3.utils.toWei('50', 'ether')).send({from:accounts[0], gasPrice: web3.utils.toHex(0)});

    let daiOnContract;
    daiOnContract = await daiInstance.methods.balanceOf(contractInstance.options.address).call();
    console.log('Dai now available on this contract', daiOnContract / 1e18);

    const daiToSupply = 10 * 1e18;

    await contractInstance.methods.investDai(web3.utils.toBN(daiToSupply)).send({from:accounts[0], gas: 1500000, gasPrice: '10000000'});

    daiOnContract = await daiInstance.methods.balanceOf(contractInstance.options.address).call();
    console.log('Dai now available on this contract', daiOnContract / 1e18);

  })
});
