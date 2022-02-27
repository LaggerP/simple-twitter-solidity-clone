const main = async () => {
  const waveContractFactory = await hre.ethers.getContractFactory("WavePortal");
  const waveContract = await waveContractFactory.deploy({
    value: hre.ethers.utils.parseEther("0.001"),
  });
  await waveContract.deployed();

  console.log("Contract deployed to:", waveContract.address);

  //list all waves
  let waveCount;
  waveCount = await waveContract.getTotalWaves();
  console.log(waveCount.toNumber());


  //get balance
  let contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
  console.log("Balance: ", hre.ethers.utils.formatEther(contractBalance));

  //send wave
  let waveTxn = await waveContract.wave("Wave 1");
  await waveTxn.wait();

  waveTxn = await waveContract.wave("Wave 2");
  await waveTxn.wait();

  //get balance after wave
  contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
  console.log("Balance after wave: ", hre.ethers.utils.formatEther(contractBalance));

  //send random wave
  const [_, randomPerson] = await hre.ethers.getSigners();
  waveTxn = await waveContract.connect(randomPerson).wave("Wave 3");
  await waveTxn.wait();

  //get all waves
  let allWaves = await waveContract.getAllWaves();
  console.log(allWaves)
};

const runMain = async () => {
  try {
    await main();
    process.exit(0); // exit Node process without error
  } catch (error) {
    console.log(error);
    process.exit(1); // exit Node process while indicating 'Uncaught Fatal Exception' error
  }
  // Read more about Node exit ('process.exit(num)') status codes here: https://stackoverflow.com/a/47163396/7974948
};

runMain();
