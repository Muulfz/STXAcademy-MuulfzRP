function vRP.sendChatMessage(source, author, color, text)
    TriggerClientEvent("chatMessage", source, author, color, text)
end

function vRP.broadcastChatMessage(author, color, text)
    vRP.sendChatMessage(-1, author, color, text)
end