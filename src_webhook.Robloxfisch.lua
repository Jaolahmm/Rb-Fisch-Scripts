local HttpService = game:GetService("HttpService")
local config = _G.Setting or {}
local webhookURL = config['webhookURL'] or ""
local webhookEnabled = config['webhookEnabled'] or false
local request = (syn and syn.request) or (http and http.request) or request
if not request then
    warn("❌ Executor ไม่รองรับ HTTP Requests")
    return
end

local function getPlayerData()
    local player = game.Players.LocalPlayer
    local leaderstats = player:FindFirstChild("leaderstats")  
    local level = leaderstats and leaderstats:FindFirstChild("Level") and leaderstats.Level.Value or "❌ ไม่พบ Level"
    local moneyC = leaderstats and leaderstats:FindFirstChild("C$") and leaderstats["C$"].Value or "❌ ไม่พบ C$"
    local moneyE = leaderstats and leaderstats:FindFirstChild("E$") and leaderstats["E$"].Value or "❌ ไม่พบ E$"
    local character = player.Character
    local position = "❌ ไม่พบตำแหน่ง"

    if character and character.PrimaryPart then
        local pos = character.PrimaryPart.Position
        position = string.format("`X: %.1f, Y: %.1f, Z: %.1f`", pos.X, pos.Y, pos.Z)
    end

    local fishingRods = {}
    local equippedRod = character and character:FindFirstChildOfClass("Tool")
    if equippedRod and string.find(equippedRod.Name:lower(), "rod") then
        table.insert(fishingRods, "`" .. equippedRod.Name .. "` (🎣 กำลังใช้อยู่)")
    end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and string.find(item.Name:lower(), "rod") then
                table.insert(fishingRods, "`" .. item.Name .. "` (🎒 Backpack)")
            end
        end
    end

    local equipmentBag = player:FindFirstChild("EquipmentBag") 
    if equipmentBag then
        for _, item in ipairs(equipmentBag:GetChildren()) do
            if item:IsA("Tool") and string.find(item.Name:lower(), "rod") then
                table.insert(fishingRods, "`" .. item.Name .. "` (📦 Equipment Bag)")
            end
        end
    end

    local rodsText = #fishingRods > 0 and table.concat(fishingRods, ", ") or "❌ ไม่มีเบ็ดตกปลา"
    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png" 

    return {
        name = player.Name,
        level = level,
        moneyC = moneyC,
        moneyE = moneyE,
        position = position,
        rods = rodsText,
        avatar = avatarUrl
    }
end

local function sendWebhook()
    if webhookURL == "" then
        warn("❌ ไม่พบ Webhook URL! โปรดตั้งค่าให้ถูกต้อง")
        return
    end

    local data = getPlayerData()
    local message = {
        embeds = {{
            title = "🌊🎣 **ข้อมูลผู้เล่นจาก Fisch** 🎣🌊",
            color = 3447003,
            description = "ข้อมูลผู้เล่นล่าสุดที่ตกปลาอยู่ในเกม **Fisch**",
            fields = {
                { name = "👤 **ชื่อผู้เล่น**", value = "`" .. data.name .. "`", inline = true },
                { name = "📈 **เลเวล**", value = "`" .. tostring(data.level) .. "`", inline = true },
                { name = "💰 **เงิน C$ ที่มี**", value = "`" .. tostring(data.moneyC) .. " C$`", inline = true },
                { name = "💵 **เงิน E$ ที่มี**", value = "`" .. tostring(data.moneyE) .. " E$`", inline = true },
                { name = "📍 **ตำแหน่งที่ตกปลา**", value = data.position, inline = false },
                { name = "🎣 **เบ็ดตกปลาที่มี**", value = data.rods, inline = false },
            },
            thumbnail = { url = data.avatar },
            footer = { text = "📅 ข้อมูลอัปเดตเมื่อ: " .. os.date("%Y-%m-%d %X"), icon_url = "https://cdn-icons-png.flaticon.com/512/1804/1804945.png" }
        }},
        username = "🐟 Fisch Webhook Bot"
    }

    local response = request({
        Url = webhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = game:GetService("HttpService"):JSONEncode(message)
    })

    if response and response.Success then
        print("✅ ส่ง Webhook สำเร็จ!")
    else
        warn("❌ ส่ง Webhook ไม่สำเร็จ!")
    end
end

while true do
    sendWebhook()
    wait(math.random(15, 30)) -- ป้องกันการโดนแบนจาก Webhook
end
