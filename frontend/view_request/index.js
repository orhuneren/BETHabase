const request_text = document.getElementById("request_text");

async function upload()
{
    const ipfsHash = document.getElementById("hash_text").value;
    const id = getRequestIdAndTag().id;
    console.log("id",id);
    (await backendFuture).uploadImageProposal(ipfsHash, id, {
        from: ACCOUNT,
        gas: 300000
    }, function (err, res) {
        console.log(arguments);
        if (err)
            alert("Error!");
        else
        {
            alert("Success!");
            document.getElementById("hash_text").value = "";
        }
    });
}

async function displayRequest()
{
    const rq = getRequestIdAndTag();
    if (isNaN(rq.id))
        return alert("Error! Invalid request id: " + window.location.hash);
    document.getElementById("request_label").innerText = rq.tag;
}

function getRequestIdAndTag()
{
    const tuple = window.location.hash.substr(1).split("-");
    return {
        id: parseInt(tuple[0]),
        tag: tuple[1]
    };
}

displayRequest();