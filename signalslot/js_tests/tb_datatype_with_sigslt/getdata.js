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
  // ================================ Contract ================================
  // create contract instance
  const contractB = cfx.Contract({
    abi: require('./contract/B-abi.json'),
    // code is unnecessary
    address: '0x8030ec16f11377d522f9b766b892091145628da0',
  });
  // console.log(contractB.address);
  // await cfx.getCode(contractB.address);
  const accountB = cfx.Account(PRIVATE_KEY_B); // create account instance
  let ret = await contractB.getLocalPriceSum();
  // .sendTransaction({ from: accountB})
  // .confirmed();
}

main().catch(e => console.error(e));
