local HttpService = game:GetService("HttpService")

-- ✅ ใช้ค่าจาก _G.Setting ที่กำหนดไว้ก่อนโหลดสคริปต์
local config = _G.Setting or {}

-- ✅ ดึงค่า Webhook
local webhookURL = config['webhookURL'] or ""
local webhookEnabled = config['webhookEnabled'] or false

local function getPlayerData()
    local player = game.Players.LocalPlayer
    local leaderstats = player:FindFirstChild("leaderstats")

    local data = {}

    if config['name'] then
        data['name'] = player.Name
    end

    if config['level'] and leaderstats and leaderstats:FindFirstChild("Level") then
        data['level'] = leaderstats.Level.Value
    end

    if config['money'] and leaderstats and leaderstats:FindFirstChild("C$") then
        data['money'] = leaderstats["C$"].Value
    end

    return data
end

local function sendWebhook()
    if not webhookEnabled or webhookURL == "" then
        warn("❌ Webhook ถูกปิด หรือไม่ได้กำหนด URL")
        return
    end

    local data = getPlayerData()

    local message = {
        embeds = {{
            title = "🌊🎣 **ข้อมูลผู้เล่นจาก Fisch** 🎣🌊",
            color = 3447003,
            description = "ข้อมูลล่าสุดจาก Fisch",
            fields = {},
            footer = {text = "📅 ข้อมูลอัปเดต: " .. os.date("%Y-%m-%d %X")}
        }},
        username = "🐟 Fisch Webhook Bot"
    }

    for key, value in pairs(data) do
        table.insert(message.embeds[1].fields, {name = key, value = "`" .. tostring(value) .. "`", inline = true})
    end

    local response = syn.request({
        Url = webhookURL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(message)
    })

    if response and response.Success then
        print("✅ ส่ง Webhook สำเร็จ!")
    else
        warn("❌ ส่ง Webhook ไม่สำเร็จ!")
    end
end

while true do
    sendWebhook()
    wait(10)
end
