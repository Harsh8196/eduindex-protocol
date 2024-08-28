import web3 from './web3_'
import ERC20 from '../abi/ERC20.json'


const instance = new web3.eth.Contract(ERC20.abi,process.env.REACT_APP_WEDU_ADDRESS)  
// console.log(instance)

export default instance