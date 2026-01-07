--// Bitchnose.xyz UI Library
--// Version: 1.0.0

local Bitchnose = {}
Bitchnose.Version = "1.0.0"

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer

--// Theme
local Theme = {
    Background = Color3.fromRGB(18,18,22),
    Dark = Color3.fromRGB(25,25,30),
    Accent = Color3.fromRGB(150,90,255),
    Text = Color3.fromRGB(235,235,235),
    Font = Enum.Font.Gotham
}

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BitchnoseUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--// WATERMARK
do
    local WM = Instance.new("TextLabel", ScreenGui)
    WM.Position = UDim2.new(0,10,0,10)
    WM.Size = UDim2.new(0,500,0,22)
    WM.BackgroundTransparency = 1
    WM.Font = Enum.Font.GothamBold
    WM.TextSize = 13
    WM.TextXAlignment = Left
    WM.TextColor3 = Theme.Accent

    local fps,last = 0,tick()
    local gameName = "Unknown"

    pcall(function()
        gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)

    RunService.RenderStepped:Connect(function()
        fps = math.floor(1/(tick()-last))
        last = tick()
        WM.Text = string.format(
            "Bitchnose.xyz | v%s | %s | %d FPS",
            Bitchnose.Version,
            gameName,
            fps
        )
    end)
end

--// NOTIFICATIONS
local Notify
do
    local Holder = Instance.new("Frame", ScreenGui)
    Holder.Position = UDim2.new(1,-320,1,-20)
    Holder.Size = UDim2.new(0,300,1,0)
    Holder.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout", Holder)
    Layout.Padding = UDim.new(0,6)
    Layout.VerticalAlignment = Bottom

    function Notify(title, text, time)
        local N = Instance.new("Frame", Holder)
        N.Size = UDim2.new(1,0,0,60)
        N.BackgroundColor3 = Theme.Dark
        N.BorderSizePixel = 0
        Instance.new("UICorner", N)

        local T = Instance.new("TextLabel", N)
        T.Text = title.."  |  "..text
        T.Font = Enum.Font.GothamBold
        T.TextSize = 14
        T.TextColor3 = Theme.Text
        T.BackgroundTransparency = 1
        T.Size = UDim2.new(1,-12,1,0)
        T.Position = UDim2.new(0,12,0,0)
        T.TextXAlignment = Left

        TweenService:Create(N,TweenInfo.new(.3),{Transparency=0}):Play()
        task.delay(time or 3,function()
            TweenService:Create(N,TweenInfo.new(.3),{Transparency=1}):Play()
            task.wait(.3)
            N:Destroy()
        end)
    end
end

--// CONFIG
local Config = {}
function Config:Save(name, data)
    writefile("bitchnose_"..name..".json", HttpService:JSONEncode(data))
end
function Config:Load(name)
    if isfile("bitchnose_"..name..".json") then
        return HttpService:JSONDecode(readfile("bitchnose_"..name..".json"))
    end
end

--// WINDOW
function Bitchnose:CreateWindow(info)
    local Window = {}
    Theme.Accent = info.Accent or Theme.Accent

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0,520,0,420)
    Main.Position = UDim2.new(.5,-260,.5,-210)
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1,0,0,40)
    Title.Text = info.Title or "Bitchnose.xyz"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Theme.Text
    Title.BackgroundTransparency = 1

    local TabsHolder = Instance.new("Frame", Main)
    TabsHolder.Position = UDim2.new(0,10,0,50)
    TabsHolder.Size = UDim2.new(1,-20,1,-60)
    TabsHolder.BackgroundTransparency = 1

    local UIList = Instance.new("UIListLayout", TabsHolder)
    UIList.Padding = UDim.new(0,8)

    function Window:CreateTab(name)
        local Tab = {}
        Tab.Container = Instance.new("Frame", TabsHolder)
        Tab.Container.Size = UDim2.new(1,0,0,0)
        Tab.Container.AutomaticSize = Y
        Tab.Container.BackgroundTransparency = 1

        function Tab:Button(opts)
            local B = Instance.new("TextButton", Tab.Container)
            B.Size = UDim2.new(1,0,0,32)
            B.Text = opts.Name
            B.Font = Theme.Font
            B.TextSize = 14
            B.TextColor3 = Theme.Text
            B.BackgroundColor3 = Theme.Dark
            B.BorderSizePixel = 0
            Instance.new("UICorner", B)

            B.MouseButton1Click:Connect(function()
                Notify("Button", opts.Name, 2)
                pcall(opts.Callback)
            end)
        end

        function Tab:Toggle(opts)
            local State = opts.Default or false
            local F = Instance.new("TextButton", Tab.Container)
            F.Size = UDim2.new(1,0,0,32)
            F.Text = opts.Name
            F.Font = Theme.Font
            F.TextSize = 14
            F.TextColor3 = Theme.Text
            F.BackgroundColor3 = State and Theme.Accent or Theme.Dark
            F.BorderSizePixel = 0
            Instance.new("UICorner", F)

            F.MouseButton1Click:Connect(function()
                State = not State
                F.BackgroundColor3 = State and Theme.Accent or Theme.Dark
                opts.Callback(State)
            end)
        end

        function Tab:Slider(opts)
            local V = opts.Default or opts.Min
            local F = Instance.new("Frame", Tab.Container)
            F.Size = UDim2.new(1,0,0,36)
            F.BackgroundColor3 = Theme.Dark
            Instance.new("UICorner", F)

            local Fill = Instance.new("Frame", F)
            Fill.Size = UDim2.new((V-opts.Min)/(opts.Max-opts.Min),0,1,0)
            Fill.BackgroundColor3 = Theme.Accent
            Instance.new("UICorner", Fill)

            F.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    local pct = math.clamp((i.Position.X-F.AbsolutePosition.X)/F.AbsoluteSize.X,0,1)
                    V = math.floor(opts.Min+(opts.Max-opts.Min)*pct)
                    Fill.Size = UDim2.new(pct,0,1,0)
                    opts.Callback(V)
                end
            end)
        end

        return Tab
    end

    function Window:Notify(...)
        Notify(...)
    end

    return Window
end

return Bitchnose
