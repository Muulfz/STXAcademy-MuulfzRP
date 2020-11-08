window.addEventListener('message', (event) => {
    let item = event.data;

    if (item.action == 'open') {
        $('#stxdealership').css("display", "block")
        $('#home-menu').css("display", "block")
    } else if (item.action = "loja"){
        $('#home-menu').css("display", "none")
        $('#vehicle-menu').css("display", "block")
    }
})