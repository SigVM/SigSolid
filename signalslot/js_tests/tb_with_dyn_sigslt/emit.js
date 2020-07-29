/* eslint-disable */

const { Conflux, util } = require('js-conflux-sdk');

const PRIVATE_KEY_A = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

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

  const accountA = cfx.Account(PRIVATE_KEY_A); // create account instance
  // const accountContractB = cfx.Account("8cc811f57df445efecf5afa2bb3252f56b77b200");

  // const txHash = await cfx.sendTransaction({
  //     from: accountA,
  //     gasPrice: cfx.defaultGasPrice,
  //     to: accountContractB,
  //     value: util.unit.fromCFXToDrip(0.125),
  //   });
  //   console.log(txHash);

  //   const tx = await cfx.getTransactionByHash(txHash);
  //   console.info(JSON.stringify(tx, null, 2));

  //   const receipt = await cfx.getTransactionReceipt(txHash);
  //   console.info(JSON.stringify(receipt, null, 2));


  // const estimate = await contractA.emitfunc([0x11,0x22,0x33]).estimateGasAndCollateral();
  // console.info(JSON.stringify(estimate));
  const receiptA = await contractA.emitfunc([0x11,0x22,0x33,0x11,0x22,0x33,0x11,0x22,0x33,0x11,0x22,0x33,0x11,0x22,0x33,0x11,0x22,0x33,0x11,0x22,0x33,0x11,0x22,0x33,0x11,0x22,0x33,0x11,0x22,0x33,0x11,0x22,0x33,0x11,0x22,0x33,0x11,0x22,0x33,0x11,0x22,0x33,0x11,0x22,0x33,0x11,0x22,0x33,0x44])
  .sendTransaction({ from: accountA,
                      gas: 10000000})
  .confirmed();
  console.log(receiptA);
}

main().catch(e => console.error(e));
