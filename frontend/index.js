const request_list = document.getElementById("request_list");

async function displayRequests()
{
    const rqs = await getRequests();
    for (const r of rqs)
    {
        const li = document.createElement('li');
        const link = document.createElement('a');
        link.innerText = r.tag;
        link.href = `view_request#${r.index}-${r.tag}`;
        li.appendChild(link);
        request_list.appendChild(li);
    }
}

async function displayRep()
{
    document.getElementById("rep_label").innerText = (await backendFuture).getReputationTokenOfMember.call(ACCOUNT).toString();
}

async function displayBalance()
{
    document.getElementById("balance_label").innerText = web3.eth.getBalance(ACCOUNT);//(await backendFuture).countMembers.call().toString();
}

async function getRequests()
{
    // const tuple = ["tag1,tag2,tag3,", [0, 1, 2]];// instance..call() TODO
    const tuple = (await backendFuture).getNameOfAvailableTags.call();
    console.log(tuple);
    const tags = tuple[0].split(",");
    const idcs = tuple[1];
    return idcs.map(function (index, i) {
        return {index, tag: tags[i]};
    });
}

// console.log(ACCOUNT);

displayRequests();
displayRep();
displayBalance();
