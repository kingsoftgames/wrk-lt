-- local JSON = (loadfile "/local/JSON.lua")()
package.path = '/local/?.lua;' .. package.path
local JSON = require("JSON")
local UID = require("UID")

local nPlayerId = os.time() + UID.generate()

local function getPlayerInfo()
    local tbPlayerAttribute = {}
    tbPlayerAttribute["room"] = 0

    local tbPlayerInfo = {}
    tbPlayerInfo["token"] = 0
    tbPlayerInfo["player_id"] = nPlayerId
    tbPlayerInfo["player_data"] = nPlayerId
    tbPlayerInfo["player_attributes"] = tbPlayerAttribute
    tbPlayerInfo["team_id"] = 0

    local tbPlayers = {}
    table.insert(tbPlayers, tbPlayerInfo)
    return tbPlayers
end

local function getMatchmakerType()
    local szType = wrk.thread:get("type")
    if szType == "random_all" then
        local tbMatchmaker = {"m100011-t1", "m100011-t2", "m100011-t4", "m100011-t1-noob", "m100011-t4-noob"}
        szType = tbMatchmaker[math.random(1, #tbMatchmaker)]
    end
    return szType
end

local function getMatchmakerInfo()
    nPlayerId = nPlayerId + 1;
    local szType = getMatchmakerType()
    local tbPlayers = getPlayerInfo()

    local tbMatchmakerInfo = {}
    tbMatchmakerInfo["matchmaker"] = szType
    tbMatchmakerInfo["webhook"] = wrk.thread:get("webhook")
    tbMatchmakerInfo["players"] = tbPlayers
    tbMatchmakerInfo["auto_team_formation"] = false
    return tbMatchmakerInfo
end

function setup(thread)
    thread:set("ticket", nil)
    thread:set("cancel", false)
    thread:set("path", "/StartMatchmaking")
end

function init(args)
    wrk.thread:set("cancel_percentage", args[1])
    wrk.thread:set("webhook", args[2])
    wrk.thread:set("type", args[3])
end

function request()
    local tbHeaders = {}
    tbHeaders["Content-Type"] = "application/json"
    local tbBody = {}
    if wrk.thread:get("cancel") then
        local szTicket = wrk.thread:get("ticket")
        -- Cancel matchmaking.
        if szTicket then
            tbBody["ticket"] = szTicket
        end
    else
        -- Start matchmaking.
        tbBody = getMatchmakerInfo()
    end
    print(JSON:encode(tbBody))
    return wrk.format("POST", wrk.thread:get("path"), tbHeaders, JSON:encode(tbBody))
end

function response(status, headers, body)
    if wrk.thread:get("cancel") then
        wrk.thread:set("ticket", nil)
        wrk.thread:set("cancel", false)
        wrk.thread:set("path", "/StartMatchmaking")
    else
        local nProbability = math.random(1, 100)
        if status ~= 200 then
            return
        end
        if nProbability <= tonumber(wrk.thread:get("cancel_percentage")) then
            wrk.thread:set("ticket", JSON:decode(body)["data"]["ticket"])
            wrk.thread:set("path", "/CancelMatchmaking")
            wrk.thread:set("cancel", true)
        end
    end
end

