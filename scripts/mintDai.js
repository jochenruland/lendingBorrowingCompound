const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider('http://localhost:7545');
const web3 = new Web3(provider);

const daiAbi = require('./daiAbi.json');
const daiAddress = '0x6B175474E89094C44Da98b954EedeAC495271d0F';
const daiInstance = new web3.eth.Contract(daiAbi, daiAddress);

// Address of Join (has auth) https://changelog.makerdao.com/ -> releases -> contract addresses -> MCD_JOIN_DAI
const daiOwner = '0x9759A6Ac90977b93B58547b4A71c78317f391A28';

const mintDai = async () => {
  let accounts;

  try{
    accounts = await web3.eth.getAccounts();

    const numDaiToMint = web3.utils.toWei('1000', 'ether');
    await daiInstance.methods.mint(accounts[0], numDaiToMint).send({from: daiOwner, gasPrice: web3.utils.toHex(0)});
    const daiOnAccount0 = await daiInstance.methods.balanceOf(accounts[0]).call();
    console.log(`Dai minted on acount ${accounts[0]}: `, daiOnAccount0 / 1e18);

  } catch(err) {
    console.error(err);
  }
}


const main = async () => {
  await mintDai();
}

main();
