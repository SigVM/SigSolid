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
    address: '0x8a2baa98a405b918f78fd3a5841ba0c399ee24a1',
  });
  console.log(contractB.address);
  await cfx.getCode(contractB.address);
  await contractB.bindfunc();

  // create contract instance
  const contractA = cfx.Contract({
    abi: require('./contract/A-abi.json'),
    // code is unnecessary
    address: '0x8e0fcf274aa9ccbdca00bb54bf8f545a64e16f10',
  });
  console.log(contractA.address);
  await cfx.getCode(contractA.address);
  await contractA.emitfunc([0x11,0x22,0x33]);
}

main().catch(e => console.error(e));
