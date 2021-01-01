--[[ Group_Lua v1.0 alpha 20210102 ]]

local groupRaw = {}
local groupNameList = {}
local groupColorList = {}
local groupOriginalName = {}
local groupMenuColor = {}
local groupMeterType = {}

local default = {
    GroupColor = nil,
    MenuColor = nil,
    MeterType = 'DDR',
}

-- このファイルの相対パス
local relativePath = string.gsub(string.sub(debug.getinfo(1).source, 2), '(.+/)[^/]+', '%1')

-- Group.ini処理用
-- 同じディレクトリにgroup_ini.luaがある場合のみ読みこみ
local groupIniFile = 'group_ini.lua'
local groupIni
if FILEMAN:DoesFileExist(relativePath..groupIniFile) then
    groupIni = LoadActor(groupIniFile)
end

-- カラーとして変換
local function ConvertColor(input)
    -- 文字列
    if type(input) == 'string' then
        return color(input)
    end
    -- カラー型
    if type(input) == 'table' and #input == 4
        and type(input[1]) == 'number'
        and type(input[2]) == 'number'
        and type(input[3]) == 'number'
        and type(input[4]) == 'number' then
        return {
            math.max(math.min(input[1], 1.0), 0.0),
            math.max(math.min(input[2], 1.0), 0.0),
            math.max(math.min(input[3], 1.0), 0.0),
            math.max(math.min(input[4], 1.0), 0.0),
        }
    end
    -- カラーとして変換できない
    return nil
end

-- グループ名と曲フォルダ名からパスを小文字で取得
local function GetSongLowerDir(groupName, dir)
    return string.lower('/Songs/'..groupName..'/'..dir..'/')
end

-- Group.iniを読み込む
local function LoadGroupIni(filePath)
    if groupIni then
        return groupIni:Load(filePath)
    else
        return {}
    end
end

-- NAMEを設定
local function SetGroupName(groupName, data)
    groupNameList[groupName] = data
end

-- グループカラーを設定
local function SetGroupColor(groupName, data)
    local groupColor = ConvertColor(data)
    if groupColor then
        groupColorList[groupName] = groupColor
    else
        groupColorList[groupName] = SONGMAN:GetSongGroupColor(groupName)
    end
end

-- ORIGINALNAMEを設定
local function ScanOriginalName(groupName, data)
    -- 文字列
    if type(data) == 'string' then
        groupOriginalName[groupName] = data
        return
    end
    -- 定義
    local originalList = {Default = groupName}
    for k,v in pairs(data[1] or {}) do
        originalList[k] = v
    end
    -- グループデフォルトName
    groupOriginalName[groupName] = originalList.Default
    -- 定義されてるデータ分ループ
    for k,v in pairs(originalList) do
        if k ~= 'Default' then  -- デフォルトは無視
            for s=1, #(data[k] or {}) do
                groupOriginalName[GetSongLowerDir(groupName, data[k][s])] = v
            end
        end
    end
end

-- METERTYPEを設定
local function ScanMeterType(groupName, data)
    -- 文字列
    if type(data) == 'string' then
        groupMeterType[groupName] = data
        return
    end
    -- 定義
    local meterList = {Default = 'DDR'}
    for k,v in pairs(data[1] or {}) do
        meterList[k] = string.upper(v)
    end
    -- グループデフォルトMeterType
    groupMeterType[groupName] = meterList.Default
    -- 定義されてるデータ分ループ
    for k,v in pairs(meterList) do
        if k ~= 'Default' then  -- デフォルトは無視
            for s=1, #(data[k] or {}) do
                groupMeterType[GetSongLowerDir(groupName, data[k][s])] = v
            end
        end
    end
end

-- MENUCOLORを設定
local function ScanMenuColor(groupName, data)
    -- グループデフォルトカラー
    groupMenuColor[groupName] = ConvertColor(data)
    if groupMenuColor[groupName] then
        return
    else
        groupMenuColor[groupName] = nil
    end
    -- 定義
    local colorList = {Default = groupMenuColor[groupName]}
    for k,v in pairs(data[1] or {}) do
        local cnvColor = ConvertColor(v)
        colorList[k] = cnvColor or groupMenuColor[groupName]
    end
    groupMenuColor[groupName] = colorList.Default
    -- 定義されてるデータ分ループ
    for k,v in pairs(colorList) do
        if k ~= 'Default' then  -- デフォルトは無視
            for s=1, #(data[k] or {}) do
                groupMenuColor[GetSongLowerDir(groupName, data[k][s])] = {v[1], v[2], v[3], v[4]}
            end
        end
    end
end

-- グループ情報のテーブルを取得
-- p1:グループ名
-- p2:取得するキー（nil）
local function GetRaw(self, groupName, ...)
    local key = ...
    if key then
        if groupRaw[groupName] then
            return groupRaw[groupName][key]
                    or groupRaw[groupName][string.upper(key)]
                    or groupRaw[groupName][string.lower(key)]
                    or nil
        end
        return nil
    end
    return groupRaw[groupName] or {}
end

-- フォルダをスキャン
-- p1:グループ名 (false)
-- p2:グループ名 (nil)
local function Scan(self, ...)
    local forceReload, groupName = ...
    forceReload = (forceReload ~= nil) and forceReload or false
    -- グループ名の指定がない場合は全グループを検索
    if not groupName then
        for i, group in pairs(SONGMAN:GetSongGroupNames()) do
            Scan(self, group, forceReload)
        end
        return
    end
    
    local groupPath = '/Songs/'..groupName
    local groupData = {}
    
    local hasGroupLua = FILEMAN:DoesFileExist(groupPath..'/group.lua')

    -- Group.iniの強制再読み込み（Group.luaは毎回読みこむ）
    if forceReload then
        groupRaw[groupName] = nil
    end
    -- 強制再読み込みが無効で、すでに読み込み済みの場合は処理を行わない（Group.iniのみ）
    if not hasGroupLua and groupRaw[groupName] then
        return
    end
    
    if hasGroupLua then
        -- Group.luaを読み込み、エラーがあれば処理を行わない
        local result, returnVal = pcall(LoadActor, groupPath..'/group.lua')
        if not result and returnVal then
            error('Group.lua ERROR : '..groupName..'\n'..returnVal, 0)
            return
        end
        groupRaw[groupName] = returnVal
    else
        -- Group.iniも存在しない場合は処理を行わない
        if not FILEMAN:DoesFileExist(groupPath..'/group.ini') then
            return
        end
        -- Group.luaが存在しない場合はiniを変換する
        groupRaw[groupName] = LoadGroupIni(groupPath..'/group.ini')
    end
    
    -- キーの大文字小文字を無視するための処理
    local rawKeys = {}
    for k,v in pairs(groupRaw[groupName]) do
        rawKeys[string.lower(k)] = k
    end
    
    -- Name設定
    SetGroupName(groupName, GetRaw(self, groupName, 'Name') or nil)

    -- OriginalName解析
    ScanOriginalName(groupName, GetRaw(self, groupName, 'OriginalName') or {})
    
    -- MenuColor解析
    ScanMenuColor(groupName, GetRaw(self, groupName, 'MenuColor') or {})
    
    -- MeterType解析
    ScanMeterType(groupName, GetRaw(self, groupName, 'MeterType') or {})
end

-- グループ名を取得
-- p1:グループ名
local function GetGroupName(self, groupName)
    return groupNameList[groupName] or SONGMAN:ShortenGroupName(groupName)
end

-- グループカラーを取得
-- p1:グループ名
local function GetGroupColor(self, groupName)
    return groupColorList[groupName] or default.GroupColor or SONGMAN:GetSongGroupColor(groupName)
end

-- song型からORIGINALNAMEを取得
-- p1:Song
local function GetOriginalName(self, song)
    return groupOriginalName[string.lower(song:GetSongDir())] 
        or groupOriginalName[song:GetGroupName()]
        or song:GetGroupName()
end

-- song型からMETERTYPEを取得
-- p1:Song
local function GetMeterType(self, song)
    return groupMeterType[string.lower(song:GetSongDir())] 
        or groupMeterType[song:GetGroupName()]
        or default.MeterType
end

-- song型からMENUCOLORを取得
-- p1:Song
local function GetMenuColor(self, song)
    return groupMenuColor[string.lower(song:GetSongDir())] 
        or groupMenuColor[song:GetGroupName()]
        or default.MenuColor
        or SONGMAN:GetSongColor(song)
end

-- デフォルト値を設定
-- p1:キー
-- p2:値
-- 例えばMenuColorのデフォルトを白にしたい場合、xx:Default('MenuColor', Color('White'))
local function SetDefaultValue(self, key, value)
    default[key] = value
    return value
end

-- ソートファイルを作成
-- p1:ソートファイル名（Group）
local function CreateSortText(self, ...)
    local sortName = ...
    sortName = sortName or 'Group'
    local f = RageFileUtil.CreateRageFile()
    if not f:Open(THEME:GetCurrentThemeDirectory()..'Other/SongManager '..sortName..'.txt', 2) then
        f:destroy()
        return data
    end
    local groupList = {}
    for g, groupName in pairs(SONGMAN:GetSongGroupNames()) do
        groupList[#groupList+1] = {
            Original = groupName,
            -- 1文字目が「'"-+*/_()」のいずれかの場合、ソートで後ろに行くように先頭に「ﾟ」をつける
            Sort     = string.lower(string.gsub(GetGroupName(self, groupName), '^([%\'%"%-%+%*%/_()].*)', 'ﾟ%1')),
        }
    end
    table.sort(groupList, function(a, b)
                return a.Sort < b.Sort
            end)
    for g = 1, #groupList do
        local groupName = groupList[g].Original
        local sortData = GetRaw(self, groupName, 'SortList') or {}
        local sortList = {
            Default = 0,
            Front   = -1,
            Rear    = 1,
            Hidden  = 0,
        }
        local sortOrder = {}
        -- ソート優先度を定義しているか取得
        for k,v in pairs(sortData[1] or {}) do
            sortList[k] = tonumber(v)
        end
        -- ソート順序を設定
        for k,v in pairs(sortList) do
            if k ~= 'Default' then  -- デフォルトは無視
                for i, dir in pairs(sortData[k] or {}) do
                    sortOrder[string.lower(dir)] = (k ~= 'Hidden') and i + 100000 * sortList[k] or 0
                end
            end
        end
        -- ソート用のテーブル作成
        local dirList = {}
        for i, song in pairs(SONGMAN:GetSongsInGroup(groupName)) do
            local dir = song:GetSongDir()
            local splitDir = split('/', dir)
            -- 1文字目が「-+*/_()」のいずれかの場合、ソートで後ろに行くように先頭に「ﾟ」をつける
            local key = string.lower(string.gsub(dir, '/Songs/.*/([^/]+)/', '%1'))
            if sortOrder[key] ~= 0 then    -- 0 = Hidden（※Default = nil）
                dirList[#dirList+1] = {
                    Dir  = string.gsub(dir, '/Songs/(.+)', '%1'),
                    Sort = sortOrder[key] or 0,
                    -- [AAA]より[AAA -AAA-]が後ろに行くようにメインタイトルの後ろにスペースを2つ入れる
                    Name = string.lower(string.gsub(song:GetTranslitMainTitle()..'  '..song:GetTranslitSubTitle(), '^([%-%+%*%/_()].*)', 'ﾟ%1')),
                }
            end
        end
        table.sort(dirList, function(a, b)
                                if a.Sort ~= b.Sort then
                                    return a.Sort < b.Sort
                                else
                                    return a.Name < b.Name
                                end
                            end)
        f:PutLine("---"..groupName)
        for i,dir in pairs(dirList) do
            f:PutLine(dir.Dir)
        end
    end
    f:Close()
    f:destroy()
    SONGMAN:SetPreferredSongs(sortName)
end

return {
    Scan         = Scan,
    Raw          = GetRaw,
    Name         = GetGroupName,
    GroupColor   = GetGroupColor,
    OriginalName = GetOriginalName,
    MenuColor    = GetMenuColor,
    MeterType    = GetMeterType,
    Sort         = CreateSortText,
    Default      = SetDefaultValue,
}


--[[
Group_lua.lua

Copyright (c) 2021 A.C

This software is released under the MIT License.
https://github.com/waiei/Group.ini-lua/blob/main/LICENSE
--]]