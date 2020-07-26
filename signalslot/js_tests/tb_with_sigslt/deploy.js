/* eslint-disable */

const { Conflux } = require('js-conflux-sdk');

const PRIVATE_KEY_A = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
const PRIVATE_KEY_B = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcde0';

async function main() {
  const cfx = new Conflux({
    url: 'http://localhost:12539',
    defaultGasPrice: 100,
    defaultGas: 1000000,
    logger: console,
  });

  console.log(cfx.defaultGasPrice); // 100
  console.log(cfx.defaultGas); // 1000000

  // ================================ Account =================================
  const accountA = cfx.Account(PRIVATE_KEY_A); // create account instance
  console.log(accountA.address);

  // ================================ Contract ================================
  // create contract instance
  const contractA = cfx.Contract({
    abi: require('./contract/A-abi.json'),
    bytecode: require('./contract/A-bytecode.json'),
  });

  // estimate deploy contract gas use
  // const estimateA = await contractA.constructor().estimateGasAndCollateral();
  // console.log(JSON.stringify(estimateA));

  // deploy the contract, and get `contractCreated`
  const receiptA = await contractA.constructor()
    .sendTransaction({ from: accountA })
    .confirmed();
  console.log(receiptA);


  // ================================ Account =================================
  const accountB = cfx.Account(PRIVATE_KEY_B); // create account instance
  console.log(accountB.address);

  // ================================ Contract ================================
  // create contract instance
  const contractB = cfx.Contract({
    abi: require('./contract/B-abi.json'),
    bytecode: require('./contract/B-bytecode.json'),
  });

  // estimate deploy contract gas use
  // const estimateB = await contractB.constructor().estimateGasAndCollateral();
  // console.log(JSON.stringify(estimateB));

  // deploy the contract, and get `contractCreated`
  const receiptB = await contractB.constructor()
    .sendTransaction({ from: accountB })
    .confirmed();
  console.log(receiptB);
}

main().catch(e => console.error(e));
