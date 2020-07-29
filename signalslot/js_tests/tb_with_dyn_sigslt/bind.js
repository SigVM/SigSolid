/* eslint-disable */

const { Conflux, util } = require('js-conflux-sdk');

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
  const contractA = cfx.Contract({
    abi: require('./contract/A-abi.json'),
    // code is unnecessary
    address: '0x8516e20e657569560504bbf72ae7282f9211fab8',
  });
  // create contract instance
  const contractB = cfx.Contract({
    abi: require('./contract/B-abi.json'),
    // code is unnecessary
    address: '0x895941dc203d5a4421178ce5c349abe251507d81',
  });

  const accountB = cfx.Account(PRIVATE_KEY_B); // create account instance
  await contractB.bindfunc(contractA.address)
  .sendTransaction({ from: accountB })
  .confirmed();

  // const accountA = cfx.Account(PRIVATE_KEY_A); // create account instance
  // const estimate = await contractA.emitfunc([0x11,0x22,0x33]).estimateGasAndCollateral();
  // console.info(JSON.stringify(estimate));
  // await contractA.emitfunc([0x11,0x22,0x33])
  // .sendTransaction({ from: accountA,
  //                    gas: 5000000})
  // .confirmed();
}

main().catch(e => console.error(e));
