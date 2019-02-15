const request_text = document.getElementById("request_text");

async function vote(correct)
{
    // const vote = document.getElementById("vote_text").value;
    (await backendFuture).voteForImage(correct|0,{from: ACCOUNT, gas: 300000}, function (err, res) {
        console.log(arguments);
        if (err)
            alert("Error!");
        else
        {
            alert("Success!");
        }
    });
    // backend.retrieveAnImageFromProposal({from: ACCOUNT, gas: 300000}, function (err, res) {
    //     console.log(arguments);
    //     if (err)
    //         alert("Error! Probably no images available.");
    //     else
    //     {
    //         alert("Success!");
    //         document.getElementById("vote_text").value = "";
    //     }
    // });
}

async function createIpfsLink()
{
    (await backendFuture).retrieveAnImageFromProposal({from: ACCOUNT, gas: 300000}, function (err, res) {
        console.log(arguments);
        if (err)
        {
            alert("Error! Probably no images available.");
            // todo go back?
        }
    });
    (await backendFuture).VoteData(function (err, res) {
        console.log(arguments);
        if(err)
            return alert("Error!");
        const ipfsHash = res.args.hashImage; // backend... TODO watch event
        const tag = res.args.tagName;
        console.log("ipfs: ", ipfsHash);
        document.getElementById("ipfs_link").href = "https://gateway.ipfs.io/" + ipfsHash;
        document.getElementById("hash_label").innerText = ipfsHash;
        // document.getElementById("tag_label").innerText = tag;
        document.getElementById("answer_button").value = tag;
    });
    
}

createIpfsLink();