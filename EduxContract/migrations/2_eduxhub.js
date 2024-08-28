const EduxHub = artifacts.require("EduxHub");
const ModuleRegistry = artifacts.require("ModuleRegistry");
const ActionLib = artifacts.require("ActionLib");
const CollectLib = artifacts.require("CollectLib");
const GovernanceLib = artifacts.require("GovernanceLib");
const ProfileLib = artifacts.require("ProfileLib");
const PublicationLib = artifacts.require("PublicationLib");


module.exports = async function (deployer) {

  await deployer.deploy(ModuleRegistry)
  const _moduleRegistry = await ModuleRegistry.deployed()
  console.log('Module registry deployed successfully. Contract Address is ' + _moduleRegistry.address)

  // Deploy ActionLib
  await deployer.deploy(ActionLib);
  deployer.link(ActionLib, EduxHub);

  // Deploy CollectLib
  await deployer.deploy(CollectLib);
  deployer.link(CollectLib, EduxHub);

  // Deploy GovernanceLib
  await deployer.deploy(GovernanceLib);
  deployer.link(GovernanceLib, EduxHub);

  // Deploy ProfileLib
  await deployer.deploy(ProfileLib);
  deployer.link(ProfileLib, EduxHub);

  // Deploy PublicationLib
  await deployer.deploy(PublicationLib);
  deployer.link(PublicationLib, EduxHub);

  const _governance = '0x6E228101ac0DB8886E28faB84ac3B916036f417B'
  const _name = 'Edux-Profile'
  const _symbol = 'EDUXP'
  await deployer.deploy(EduxHub,_moduleRegistry.address,_governance,_name,_symbol);
  const _eduxHub = await EduxHub.deployed()
  console.log('EduxHub deployed successfully. Contract Address is ' + _eduxHub.address);
};
