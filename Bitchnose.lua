--// Bitchnose.xyz UI Library
--// Version 1.0.0

local Bitchnose = {}
Bitchnose.Version = "1.1.0"

--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local Player = Players.LocalPlayer

--// THEME
local Theme = {
    Background = Color3.fromRGB(16,16,20),
    Dark = Color3.fromRGB(22,22,28),
    Light = Color3.fromRGB(30,30,36),
    Accent = Color3.fromRGB(155,95,255),
    Text = Color3.fromRGB(235,235,235),
    Muted = Color3.fromRGB(160,160,160),
    Font = Enum.Font.Gotham
}

--// SCREEN GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "BitchnoseUI"
GUI.ResetOnSpawn = false
GUI.Parent = Player:WaitForChild("PlayerGui")

--// WATERMARK
do
    local WM = Instance.new("TextLabel", GUI)
    WM.Position = UDim2.new(0,10,0,10)
    WM.Size = UDim2.new(0,600,0,22)
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

--// UTIL
local function Tween(obj,tbl,time)
    TweenService:Create(obj,TweenInfo.new(time or .2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),tbl):Play()
end

--// NOTIFICATIONS (dxhook + Iris hybrid)
local Notify
do
    local Holder = Instance.new("Frame",GUI)
    Holder.Position = UDim2.new(1,-320,1,-20)
    Holder.Size = UDim2.new(0,300,1,0)
    Holder.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout",Holder)
    Layout.Padding = UDim.new(0,6)
    Layout.VerticalAlignment = Bottom

    function Notify(title,text,duration)
        local N = Instance.new("Frame",Holder)
        N.Size = UDim2.new(1,0,0,56)
        N.BackgroundColor3 = Theme.Dark
        N.BorderSizePixel = 0
        Instance.new("UICorner",N)

        local T = Instance.new("TextLabel",N)
        T.Text = title.."  |  "..text
        T.Font = Enum.Font.GothamBold
        T.TextSize = 14
        T.TextColor3 = Theme.Text
        T.BackgroundTransparency = 1
        T.Size = UDim2.new(1,-12,1,0)
        T.Position = UDim2.new(0,12,0,0)
        T.TextXAlignment = Left

        N.Position = UDim2.new(1,40,0,0)
        Tween(N,{Position=UDim2.new(0,0,0,0)},.25)

        task.delay(duration or 3,function()
            Tween(N,{Transparency=1},.25)
            task.wait(.25)
            N:Destroy()
        end)
    end
end

--// CONFIG
local Config = {}
function Config:Save(name,data)
    writefile("bitchnose_"..name..".json",HttpService:JSONEncode(data))
end
function Config:Load(name)
    if isfile("bitchnose_"..name..".json") then
        return HttpService:JSONDecode(readfile("bitchnose_"..name..".json"))
    end
end

--// WINDOW
function Bitchnose:CreateWindow(info)
    local Window = {}
    local Values = {}

    if info.Accent then Theme.Accent = info.Accent end

    local Main = Instance.new("Frame",GUI)
    Main.Size = UDim2.new(0,560,0,460)
    Main.Position = UDim2.new(.5,-280,.5,-230)
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Instance.new("UICorner",Main)

    -- DRAG
    do
        local drag,mouse,offset
        Main.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                drag=true
                offset=i.Position-Main.Position
            end
        end)
        Main.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
                Main.Position=UDim2.fromOffset(i.Position.X-offset.X,i.Position.Y-offset.Y)
            end
        end)
    end

    local Title = Instance.new("TextLabel",Main)
    Title.Size = UDim2.new(1,0,0,42)
    Title.Text = info.Title or "Bitchnose.xyz"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Theme.Text
    Title.BackgroundTransparency = 1

    local Container = Instance.new("ScrollingFrame",Main)
    Container.Position = UDim2.new(0,10,0,52)
    Container.Size = UDim2.new(1,-20,1,-62)
    Container.CanvasSize = UDim2.new(0,0,0,0)
    Container.ScrollBarImageTransparency = 1

    local Layout = Instance.new("UIListLayout",Container)
    Layout.Padding = UDim.new(0,8)
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+10)
    end)

    -- TAB
    function Window:CreateTab(name)
        local Tab = {}

        local Holder = Instance.new("Frame",Container)
        Holder.Size = UDim2.new(1,0,0,0)
        Holder.AutomaticSize = Y
        Holder.BackgroundTransparency = 1

        local function Base(height)
            local F = Instance.new("Frame",Holder)
            F.Size = UDim2.new(1,0,0,height)
            F.BackgroundColor3 = Theme.Dark
            F.BorderSizePixel = 0
            Instance.new("UICorner",F)
            return F
        end

        function Tab:Button(o)
            local B = Base(34)
            local T = Instance.new("TextButton",B)
            T.Size = UDim2.new(1,0,1,0)
            T.Text = o.Name
            T.Font = Theme.Font
            T.TextSize = 14
            T.TextColor3 = Theme.Text
            T.BackgroundTransparency = 1
            T.MouseButton1Click:Connect(function()
                Notify("Button",o.Name,2)
                pcall(o.Callback)
            end)
        end

        function Tab:Toggle(o)
            local state=o.Default or false
            local B=Base(34)
            B.BackgroundColor3=state and Theme.Accent or Theme.Light
            B.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then
                    state=not state
                    Tween(B,{BackgroundColor3=state and Theme.Accent or Theme.Light})
                    o.Callback(state)
                end
            end)
            local L=Instance.new("TextLabel",B)
            L.Text=o.Name
            L.Font=Theme.Font
            L.TextSize=14
            L.TextColor3=Theme.Text
            L.BackgroundTransparency=1
            L.Size=UDim2.new(1,0,1,0)
        end

        function Tab:Dropdown(o)
            local open=false
            local selected={}
            local B=Base(34)
            local L=Instance.new("TextLabel",B)
            L.Text=o.Name
            L.Font=Theme.Font
            L.TextSize=14
            L.TextColor3=Theme.Text
            L.BackgroundTransparency=1
            L.Size=UDim2.new(1,0,1,0)

            local List=Instance.new("Frame",Holder)
            List.Size=UDim2.new(1,0,0,0)
            List.ClipsDescendants=true
            List.BackgroundTransparency=1

            local lay=Instance.new("UIListLayout",List)
            lay.Padding=UDim.new(0,4)

            B.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then
                    open=not open
                    Tween(List,{Size=open and UDim2.new(1,0,0,#o.Options*28) or UDim2.new(1,0,0,0)})
                end
            end)

            for _,v in ipairs(o.Options) do
                local O=Instance.new("TextButton",List)
                O.Size=UDim2.new(1,0,0,24)
                O.Text=v
                O.Font=Theme.Font
                O.TextSize=13
                O.TextColor3=Theme.Text
                O.BackgroundColor3=Theme.Light
                Instance.new("UICorner",O)
                O.MouseButton1Click:Connect(function()
                    if o.Multi then
                        selected[v]=not selected[v]
                    else
                        table.clear(selected)
                        selected[v]=true
                    end
                    o.Callback(selected)
                end)
            end
        end

        function Tab:ColorPicker(o)
            local color=o.Default or Color3.new(1,1,1)
            local B=Base(34)
            local P=Instance.new("Frame",B)
            P.Size=UDim2.new(0,20,0,20)
            P.Position=UDim2.new(1,-30,.5,-10)
            P.BackgroundColor3=color
            Instance.new("UICorner",P)

            local Palette=Instance.new("ImageLabel",Holder)
            Palette.Visible=false
            Palette.Size=UDim2.new(1,0,0,140)
            Palette.Image="rbxassetid://4155801252"
            Palette.BackgroundTransparency=1

            B.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then
                    Palette.Visible=not Palette.Visible
                end
            end)

            Palette.InputChanged:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseMovement then
                    local x=(i.Position.X-Palette.AbsolutePosition.X)/Palette.AbsoluteSize.X
                    local y=(i.Position.Y-Palette.AbsolutePosition.Y)/Palette.AbsoluteSize.Y
                    color=Color3.fromHSV(math.clamp(x,0,1),1-math.clamp(y,0,1),1)
                    P.BackgroundColor3=color
                    o.Callback(color)
                end
            end)
        end

        function Tab:Keybind(o)
            local key=o.Default
            local B=Base(34)
            local L=Instance.new("TextLabel",B)
            L.Text=o.Name.." ["..key.Name.."]"
            L.Font=Theme.Font
            L.TextSize=14
            L.TextColor3=Theme.Text
            L.BackgroundTransparency=1
            L.Size=UDim2.new(1,0,1,0)

            B.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then
                    L.Text="Press key..."
                    local c
                    c=UserInputService.InputBegan:Connect(function(k)
                        if k.KeyCode~=Enum.KeyCode.Unknown then
                            key=k.KeyCode
                            L.Text=o.Name.." ["..key.Name.."]"
                            c:Disconnect()
                        end
                    end)
                end
            end)

            UserInputService.InputBegan:Connect(function(k)
                if k.KeyCode==key then o.Callback() end
            end)
        end

        function Tab:ConfigUI()
            self:Button({
                Name="Save Config",
                Callback=function() Config:Save("default",Values) Notify("Config","Saved",2) end
            })
            self:Button({
                Name="Load Config",
                Callback=function() Values=Config:Load("default") or {} Notify("Config","Loaded",2) end
            })
        end

        function Tab:ThemeUI()
            self:ColorPicker({
                Name="Accent Color",
                Default=Theme.Accent,
                Callback=function(c) Theme.Accent=c end
            })
        end

        return Tab
    end

    function Window:Notify(...)
        Notify(...)
    end

    return Window
end

return Bitchnose
