const Mint4TheMetaverse = artifacts.require('Mint4TheMetaverse')

module.exports = async function(deployer) {
  deployer.deploy(Mint4TheMetaverse)
};