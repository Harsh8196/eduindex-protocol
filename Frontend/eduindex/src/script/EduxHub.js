import web3 from './web3_'
import EduxHubAbi from '../abi/EduxHub.json'


const instance = new web3.eth.Contract(EduxHubAbi.abi,process.env.REACT_APP_CONTRACT_ADDRESS)  
// console.log(instance)

export default instance