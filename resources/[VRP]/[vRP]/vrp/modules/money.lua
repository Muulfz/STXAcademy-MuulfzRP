local lang = vRP.lang

-- Money module, wallet/bank API
-- The money is managed with direct SQL requests to prevent most potential value corruptions
-- the wallet empty itself when respawning (after death)

vRP.prepare("vRP/money_init_user", "INSERT IGNORE INTO vrp_user_moneys(user_id,wallet,bank) VALUES(@user_id,@wallet,@bank)")
vRP.prepare("vRP/get_money", "SELECT wallet,bank FROM vrp_user_moneys WHERE user_id = @user_id")
vRP.prepare("vRP/set_money", "UPDATE vrp_user_moneys SET wallet = @wallet, bank = @bank WHERE user_id = @user_id")

vRP.prepare("vRP/get_bank_money", "SELECT bank FROM vrp_user_moneys WHERE user_id = @user_id")
vRP.prepare("vRP/set_bank_money", "UPDATE vrp_user_moneys SET bank = @value WHERE user_id = @user_id")

vRP.prepare("vRP/get_wallet_money", "SELECT wallet FROM vrp_user_moneys WHERE user_id = @user_id")
vRP.prepare("vRP/set_wallet_money", "UPDATE vrp_user_moneys SET wallet = @value WHERE user_id = @user_id")


-- load config
local cfg = module("cfg/money")

-- API

-- get money
-- cbreturn nil if error
function vRP.getMoney(user_id)
    local tmp = vRP.getUserTmpTable(user_id)
    if tmp then
        return tmp.wallet or 0
    else
        return getDBMoney("vRP/get_wallet_money", user_id)
    end
end

function getDBMoney(query, user_id)
    local rows = vRP.query("vRP/get_wallet_money", {user_id = user_id})
    if #rows > 0  then
        return rows[1].bank
    end
    return nil
end

-- set money
function vRP.setMoney(user_id, value)
    local tmp = vRP.getUserTmpTable(user_id)
    if tmp then
        tmp.wallet = value

        -- update client display
        local source = vRP.getUserSource(user_id)
        if source then
            vRPclient._setDivContent(source, "money", lang.money.display({ value }))
        end

    else
        dbSetWalletMoney(user_id, value)
    end
end

-- try a payment
-- return true or false (debited if true)
function vRP.tryPayment(user_id, amount)
    local money = vRP.getMoney(user_id)
    if amount >= 0 and money >= amount then
        vRP.setMoney(user_id, money - amount)
        return true
    else
        return false
    end
end

-- give money
function vRP.giveMoney(user_id, amount)
    if amount > 0 then
        local money = vRP.getMoney(user_id)
        vRP.setMoney(user_id, money + amount)
    end
end

-- get bank money
function vRP.getBankMoney(user_id)
    local tmp = vRP.getUserTmpTable(user_id)
    if tmp then
        return tmp.bank or 0
    else
       return getDBMoney("vRP/get_bank_money",user_id)
    end
end

-- set bank money
function vRP.setBankMoney(user_id, value)
    local tmp = vRP.getUserTmpTable(user_id)
    if tmp then
        tmp.bank = value
    else
        dbSetBankMoney(user_id, value)
    end
end
function dbSetBankMoney(user_id, value)
    local bankMoney = vRP.getBankMoney(user_id)
    if bankMoney then
        vRP.execute("vRP/set_bank_money", { user_id = user_id, value = value })
    end
end

function dbSetWalletMoney(user_id, value)
    local walletMoney = vRP.getMoney(user_id)
    if walletMoney then
        vRP.execute("vRP/set_wallet_money", { user_id = user_id, value = value })
    end
end

-- give bank money
function vRP.giveBankMoney(user_id, amount)
    if amount > 0 then
        local money = vRP.getBankMoney(user_id)
        vRP.setBankMoney(user_id, money + amount)
    end
end

-- try a withdraw
-- return true or false (withdrawn if true)
function vRP.tryWithdraw(user_id, amount)
    local money = vRP.getBankMoney(user_id)
    if amount >= 0 and money >= amount then
        vRP.setBankMoney(user_id, money - amount)
        vRP.giveMoney(user_id, amount)
        return true
    else
        return false
    end
end

-- try a deposit
-- return true or false (deposited if true)
function vRP.tryDeposit(user_id, amount)
    if amount >= 0 and vRP.tryPayment(user_id, amount) then
        vRP.giveBankMoney(user_id, amount)
        return true
    else
        return false
    end
end

-- try full payment (wallet + bank to complete payment)
-- return true or false (debited if true)
function vRP.tryFullPayment(user_id, amount)
    local money = vRP.getMoney(user_id)
    if money >= amount then
        -- enough, simple payment
        return vRP.tryPayment(user_id, amount)
    else
        -- not enough, withdraw -> payment
        if vRP.tryWithdraw(user_id, amount - money) then
            -- withdraw to complete amount
            return vRP.tryPayment(user_id, amount)
        end
    end

    return false
end

-- Only works for online players TODO change OOTB method
function vRP.adminSetMoney(user_id, target_id, money_type, value)
    if vRP.hasPermission(user_id, permissions.player.setmoney) then
        if money_type == tostring(vRP.lang.money.types.bank) then
            vRP.setBankMoney(target_id, value)
        elseif money_type == tostring(vRP.lang.money.types.wallet) then
            vRP.setMoney(target_id, value)
        end
    end
end

-- events, init user account if doesn't exist at connection
AddEventHandler("vRP:playerJoin", function(user_id, source, name, last_login)
    vRP.execute("vRP/money_init_user", { user_id = user_id, wallet = cfg.open_wallet, bank = cfg.open_bank })
    -- load money (wallet,bank)
    local tmp = vRP.getUserTmpTable(user_id)
    if tmp then
        local rows = vRP.query("vRP/get_money", { user_id = user_id })
        if #rows > 0 then
            tmp.bank = rows[1].bank
            tmp.wallet = rows[1].wallet
        end
    end
end)

-- save money on leave
AddEventHandler("vRP:playerLeave", function(user_id, source)
    -- (wallet,bank)
    local tmp = vRP.getUserTmpTable(user_id)
    if tmp and tmp.wallet and tmp.bank then
        vRP.execute("vRP/set_money", { user_id = user_id, wallet = tmp.wallet, bank = tmp.bank })
    end
end)

-- save money (at same time that save datatables)
AddEventHandler("vRP:save", function()
    for k, v in pairs(vRP.user_tmp_tables) do
        if v.wallet and v.bank then
            vRP.execute("vRP/set_money", { user_id = k, wallet = v.wallet, bank = v.bank })
        end
    end
end)

-- money hud
AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        -- add money display
        vRPclient._setDiv(source, "money", cfg.display_css, lang.money.display({ vRP.getMoney(user_id) }))
    end
end)
