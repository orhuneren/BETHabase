window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));
window.ACCOUNT = web3.eth.accounts[localStorage.accountIndex | 0];

window.backendFuture = connectBackend();

async function connectBackend()
{
    const abi = await (await fetch("/abi.json")).json();
    // console.log("abi", abi);
    const contractDefinition = web3.eth.contract(abi);
    const address = await ((await fetch("/address.txt")).text());
    console.log("address", address);
    return backend = contractDefinition.at(address);
    
    // backend.NextStage(function (error, result) {
    //     console.log("NextStage", arguments);
    //     console.log("NextStage data: ", result.args);
    // });
    // backend.LogEvent(function (error, result) {
    //     console.log("LogEvent", arguments);
    //     console.log("LogEvent data: ", result.args);
    // });
    // console.log(backend.hash.call(web3.fromAscii("hi there")));
    // console.log(CommitmentTest.log(web3.fromAscii("hi there"), {from: ACCOUNT}));
}