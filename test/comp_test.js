
const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider('http://localhost:7545');
const web3 = new Web3(provider);


//const { expectRevert, time } = require('@openzeppelin/test-helpers');
const assert = require('assert');

let accounts;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();
})

describe('Testing Comp on mainfork', () => {
  it('Contract available on mainfork', () => {
    //console.log(contractInstance.options.address);
    console.log(accounts);

    //assert.ok(contractInstance.options.address);
  });
});
