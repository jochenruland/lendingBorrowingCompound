const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider('http://localhost:7545');
const web3 = new Web3(provider);

const daiAbi = require('./daiAbi.json');
const daiAddress = '0x6B175474E89094C44Da98b954EedeAC495271d0F';
const daiInstance = new web3.eth.Contract(daiAbi, daiAddress);

const compJSON = require('../build/contracts/Comp.json');
const deploymentKey = Object.keys(compJSON.networks)[0];


const contractAddress = compJSON.networks[deploymentKey].address; //compJSON.networks[deploymentKey].address

const sentDai = async () => {
  let accounts;

  try{
    accounts = await web3.eth.getAccounts();

    await daiInstance.methods.transferFrom(accounts[0], contractAddress, web3.utils.toWei('50', 'ether')).send({from:accounts[0], gasPrice: web3.utils.toHex(0)});
    const daiOnAccount0 = await daiInstance.methods.balanceOf(contractAddress).call();
    console.log(`Dai sent to contract ${contractAddress}: `, daiOnAccount0 / 1e18);

  } catch(err) {
    console.error(err);
  }
}


const main = async () => {
  await sentDai();
}

main();
