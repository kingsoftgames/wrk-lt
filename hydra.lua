local nPlayerId = os.time() * 1000
local szAud = "com.seasungames.rog2"

local tbPath = {}
tbPath["EGSDK"] = "/LoginWithEGSDK"
tbPath["account"] = "/LoginWithAccount"
tbPath["deviceId"] = "/LoginWithDeviceId"

local function getTbBody(szType)
    nPlayerId = nPlayerId + 1
    local tbBody = {}
    if szType == "EGSDK" then
        print("I can't test EGSDK! Good Bye!")
        wrk.thread:stop()
    elseif szType == "account" then
        tbBody = {
            "username=" .. nPlayerId,
            "password=" .. "foobar",
            "create=" .. "true",
            "aud=" .. szAud
        }
    elseif szType == "deviceId" then
        tbBody = {
            "device_id=" .. nPlayerId,
            "create=" .. "true",
            "aud=" .. szAud
        }
    else
        print("I can't test type: " .. szType .. "! Good Bye!")
        wrk.thread:stop()
    end
    return table.concat(tbBody, "&")
end

function init(args)
    wrk.thread:set("type", args[1])
end

function request()
    local tbHeaders = {}
    tbHeaders["Content-Type"] = "application/x-www-form-urlencoded"
    local szType = wrk.thread:get("type")
    local szBody = getTbBody(szType)
    local szPath = tbPath[szType]
    print(szBody)
    return wrk.format("POST", szPath, tbHeaders, szBody)
end
