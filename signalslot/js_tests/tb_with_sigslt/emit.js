/* eslint-disable */

const { Conflux, util } = require('js-conflux-sdk');

const PRIVATE_KEY_A = '0x72bc3a36d03b3b157c75915dc74bb5325ac7503f1b67bac80a0c1af86d4dacbe';

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
    address: '0x84c5c52d94890e93d9e3d07aa8cc83fd8235a26a',
  });
  // create contract instance
  const contractB = cfx.Contract({
    abi: require('./contract/B-abi.json'),
    // code is unnecessary
    address: '0x88f18f463796dedc9f47057dae7fa28a6d198ac8',
  });

  const accountA = cfx.Account(PRIVATE_KEY_A); // create account instance
  const accountContractB = cfx.Account("0x88f18f463796dedc9f47057dae7fa28a6d198ac8");

  const txHash = await cfx.sendTransaction({
      from: accountA,
      gasPrice: cfx.defaultGasPrice,
      to: accountContractB,
      value: util.unit.fromCFXToDrip(0.125),
    });
    console.log(txHash);

    const tx = await cfx.getTransactionByHash(txHash);
    console.info(JSON.stringify(tx, null, 2));

    const receipt = await cfx.getTransactionReceipt(txHash);
    console.info(JSON.stringify(receipt, null, 2));


  // const estimate = await contractA.emitfunc([0x11,0x22,0x33]).estimateGasAndCollateral();
  // console.info(JSON.stringify(estimate));
  const receiptB = await contractA.emitfunc([0x11,0x22,0x33])
  .sendTransaction({ from: accountA,
                      gas: 10000000})
  .confirmed();
  console.log(receiptB);
}

main().catch(e => console.error(e));
