if (localStorage.accountIndex === void 0)
{
    let idx = -1;
    do
        idx = parseInt(prompt("Please name the index of your account (between 0 and 9)"));
    while (!(idx >= 0 && idx < 10));
    localStorage.accountIndex = idx;
}