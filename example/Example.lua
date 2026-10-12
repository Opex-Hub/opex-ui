local OpexUI = require(game:GetService("ReplicatedStorage"):WaitForChild("OpexUI"))

local window = OpexUI.new({
    Name = "OpexUI",
    Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"),
    Size = UDim2.fromOffset(760, 430),
})

local home = window:AddTab("Home")
local shop = window:AddTab("Shop")
local profiles = window:AddTab("Profiles")

local welcome = Instance.new("TextLabel")
welcome.Size = UDim2.new(1, -24, 0, 30)
welcome.Position = UDim2.new(0, 12, 0, 12)
welcome.BackgroundTransparency = 1
welcome.Text = "Welcome to OpexUI"
welcome.Font = Enum.Font.GothamBold
welcome.TextSize = 18
welcome.TextColor3 = Color3.fromRGB(234, 240, 255)
welcome.Parent = home

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -24, 0, 24)
sub.Position = UDim2.new(0, 12, 0, 52)
sub.BackgroundTransparency = 1
sub.Text = "Shiny blue outline. Black tabs. Creator panel."
sub.Font = Enum.Font.Gotham
sub.TextSize = 14
sub.TextColor3 = Color3.fromRGB(185, 198, 220)
sub.Parent = home

local shopLabel = Instance.new("TextLabel")
shopLabel.Size = UDim2.new(1, -24, 0, 26)
shopLabel.Position = UDim2.new(0, 12, 0, 12)
shopLabel.BackgroundTransparency = 1
shopLabel.Text = "Shop tab"
shopLabel.Font = Enum.Font.GothamBold
shopLabel.TextSize = 18
shopLabel.TextColor3 = Color3.fromRGB(230, 235, 255)
shopLabel.Parent = shop

local profileLabel = Instance.new("TextLabel")
profileLabel.Size = UDim2.new(1, -24, 0, 26)
profileLabel.Position = UDim2.new(0, 12, 0, 12)
profileLabel.BackgroundTransparency = 1
profileLabel.Text = "Creator: tu_papi"
profileLabel.Font = Enum.Font.GothamBold
profileLabel.TextSize = 18
profileLabel.TextColor3 = Color3.fromRGB(230, 235, 255)
profileLabel.Parent = profiles

window:SetActiveTab("Home")
