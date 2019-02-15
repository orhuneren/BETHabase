const request_text = document.getElementById("request_text");

async function submitRequest()
{
    const imageCount = document.getElementById("image_count").value | 0;
    // console.log("img count",imageCount);
    // console.log("text",request_text.value);
    //backend..(..., {from:ACCOUNT});
    (await backendFuture).createNewDatabaseRequest(request_text.value, imageCount, {
        from: ACCOUNT,
        gas: 300000,
        value: imageCount * 10 ** 15
    }, function (err, res) {
        console.log(arguments);
        if (err)
            alert("Error!");
        else
        {
            alert("Success!");
            // TODO clear form
            // document.getElementById("hash_text").value = "";
        }
    });
    // backend.createNewDatabaseRequest("house",1,{from:ACCOUNT, gas: 300000, value: 10**15}, function(err, res){console.log(arguments)});
    
}