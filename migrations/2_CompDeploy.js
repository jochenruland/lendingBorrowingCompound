const Comp = artifacts.require("Comp");

// Mainnet addresses
const comptroller = '0x3d9819210a31b4961b30ef54be2aed79b9c9cd3b';
const cDai = '0x5d3a536e4d6dbd6114cc1ead35777bab948e3643';
const cBat = '0x6c8c6b02e7b2be14d4fa6022dfd6d75921d90e4e';
const cEth = '0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5';
const dai = '0x6B175474E89094C44Da98b954EedeAC495271d0F';
const bat = '0x0D8775F648430679A709E98d2b0Cb6250d2887EF';


module.exports = function (deployer) {
  deployer.deploy(Comp, dai, cDai, bat, cBat, comptroller);
};
