--[[ Group_Lua v20211116]]

-- このファイルの相対パス
local relativePath = string.gsub(string.sub(debug.getinfo(1).source, 2), '(.+/)[^/]+', '%1')

-- グローバル関数にFindValueが存在するが、5.0と異なるので5.1のコードを利用
local function _FindValue_(tab, value)
	for key, name in pairs(tab) do
		if value == name then
			return key
		end
	end

	return nil
end

-- Rawデータ
local groupRaw = {}
-- 取得用データ(Rawを取得しやすい形に変える)
local groupData = {}
-- 値の型（number, string, color, table）
local keyType = {}
-- 未指定時の定義
local defaultDefine = {}

-- 検索対象の楽曲フォルダ
local songPathList = {
    '/Songs/',
    '/AdditionalSongs/',
}

-- Group.ini処理用
-- 同じディレクトリにgroup_ini.luaがある場合のみ読みこみ
local groupIniFile = 'group_ini.lua'
local groupIni
if FILEMAN:DoesFileExist(relativePath..groupIniFile) then
    groupIni = dofile(relativePath..groupIniFile)
end

-- ファイルを検索してパスを返却（大文字小文字を無視）
-- p1:グループ名
-- p2:ファイル名
local function SearchFile(groupName, fileName)
    for i=1, #songPathList do
        local dirList = FILEMAN:GetDirListing(songPathList[i]..groupName)
        for d=1, #dirList do
            if string.lower(dirList[d]) == string.lower(fileName) then
                return songPathList[i]..groupName..dirList[d]
            end
        end
    end
    return nil
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
    return {1.0, 1.0, 1.0, 1.0}
end

-- Songからパスを小文字で取得（グループフォルダ名/楽曲フォルダ名/ が返却される）
local function GetSongLowerDir(song)
    return string.lower(string.gsub(song:GetSongDir(), '/[^/]*Songs/(.+)', '%1'))
end

-- Group.iniを読み込む
local function LoadGroupIni(filePath)
    if filePath and groupIni then
        return groupIni:Load(filePath)
    else
        return {}
    end
end

-- 値をフォーマット
local function FormatValue(data, key)
    if keyType[key] then
        if keyType[key] == 'color' then
            return ConvertColor(data)
        elseif keyType[key] == 'string' and type(data) ~= 'string' then
            return ''
        elseif keyType[key] == 'number' and type(data) ~= 'number' then
            return 0
        elseif keyType[key] == 'table' and type(data) ~= 'table' then
            return {}
        elseif type(data) == 'function' and keyType[key] ~= 'function' then
            -- 種別がfunction以外で値がfunctionの場合実行する
            return data()
        end
        return data
    end
    return nil
end

-- Grouop.luaまたはGroup.iniを読み込んでRawデータとして保存
local function SetRaw(groupName, groupLuaPath, groupIniPath)
    groupRaw[groupName] = nil
    if groupLuaPath then
        -- Group.luaを読み込み、エラーがあれば処理を行わない
        local f = RageFileUtil.CreateRageFile()
        if not f:Open(groupLuaPath, 1) then
            f:destroy()
            return
        end
        -- BOMがあるとエラーになるので回避
        local luaData = string.gsub(f:Read(), '^'..string.char(0xef, 0xbb, 0xbf)..'(.?)', '%1')
        f:Close()
        f:destroy()
        local luaString, errMsg
        -- loadstringはLua5.2以降廃止
        -- assertでエラーをキャッチするとluaDataの中身が出力されるのでここではキャッチしない
        if _VERSION == 'Lua 5.1' then
            luaString, errMsg = loadstring(luaData)
        else
            luaString, errMsg = load(luaData)
        end
        -- エラー発生時に変数の中身が出力されてもメッセージが流れないようにクリア
        luaData = nil
        if not luaString and errMsg then
            error('Group.lua ERROR : '..groupName..'\n'..errMsg, 0)
            return
        end
        groupRaw[groupName] = luaString()
    else
        -- Group.luaが存在しない場合はiniを変換する
        groupRaw[groupName] = LoadGroupIni(groupIniPath)
    end
end

-- グループ情報のテーブルを取得
-- p1:グループ名
-- p2:取得するキー（nil）
local function GetRaw(self, groupName, ...)
    local key = ...
    -- キーを指定していない場合はグループの情報か空テーブルを返却
    if not key or type(key) ~= 'string' then
        return groupRaw[groupName] or {}
    end
    -- キーの指定がある場合
    -- グループの情報が無い場合はnil
    if not groupRaw[groupName] then
        return nil
    end
    -- キーが見つかった場合は返却
    if groupRaw[groupName][key] then
        return groupRaw[groupName][key]
    end
    -- キーの大文字小文字を無視して取得
    key = string.lower(key)
    for k,v in pairs(groupRaw[groupName]) do
        if key == string.lower(k) then
            return groupRaw[groupName][k]
        end
    end
    -- ヒットしない場合はnil
    return nil
end

-- パラメータを指定して一時変数に格納
-- groupData[key][グループフォルダ名] = デフォルト値
-- groupData[key][小文字（グループフォルダ名/楽曲フォルダ名/）] = {楽曲単位の値, 追加パラメータ}
local function SetData(groupName, key)
    if not groupData[key] then
        groupData[key] = {}
    end
    local data = GetRaw(nil, groupName, key)
    if data then
        local lGroupName = string.lower(groupName)
        -- デフォルトの定義を設定
        local define = {}
        -- =で代入するとdefineを加工した時に元の配列が書き換えられるのでひとつづつ入れ直す
        for k,v in pairs(defaultDefine[key] or {}) do
            define[k] = v
        end

        if type(data) ~= 'table' or (type(data) == 'table' and data[1] and type(data[1]) == 'number' and keyType[key] == 'color') then
            -- グループ単位で定義
            -- デフォルト値
            groupData[key][groupName] = FormatValue(data, key)
        else
            -- フォルダ単位で定義
            -- 定義部分を取得
            for k,v in pairs(data[1] or {}) do
                define[k] = v
            end
            -- デフォルト値
            groupData[key][groupName] = FormatValue(define.Default or nil, key)
            -- 各フォルダ
            for k,_ in pairs(define or {}) do
                if k ~= 'default' and data[k] and type(data[k]) == 'table' then
                    for _,v in pairs(data[k]) do
                        if type(v) == 'string' then
                            -- フォルダ名のみを定義
                            groupData[key][lGroupName..'/'..string.lower(v)..'/'] = {FormatValue(define[k], key), {}}
                        elseif type(v) == 'table' then
                            -- 楽曲単位でパラメータを定義
                            local folder = v[1] or nil
                            if folder then
                                groupData[key][lGroupName..'/'..string.lower(folder)..'/'] = {FormatValue(define[k], key), v[2] or {}}
                            end
                        end
                    end
                end
            end
        end
    end
end

-- 取得対象のキーを追加
local function AddTargetKey(self, key, typeString, ...)
    local define = ...
    keyType[key] = typeString
    if define and type(define) == 'table' then
        defaultDefine[key] = define
        if not define.Default then
            defaultDefine[key].Default = FormatValue(nil, key)
        end
    else
        defaultDefine[key] = {Default = FormatValue(define or nil, key)}
    end
end

-- フォルダをスキャン
-- p1:グループ名 (nil)
local function Scan(self, ...)
    local groupName = ...
    -- グループ名の指定がない場合は全グループを検索
    if not groupName then
        local groups = SONGMAN and SONGMAN:GetSongGroupNames() or {}    -- 5.0.7RC対策
        for i, group in pairs(groups) do
            Scan(self, group)
        end
        return
    end

    -- 読みこんでRawに保存
    local groupLuaPath = SearchFile(groupName..'/', 'group.lua')
    local groupIniPath = (not groupLuaPath) and SearchFile(groupName..'/', 'group.ini') or nil
    SetRaw(groupName, groupLuaPath, groupIniPath)

    -- 情報を取得
    groupData[groupName] = {}
    for key,_ in pairs(keyType) do
        SetData(groupName, key)
    end
end

local function GetFallback(key)
    if not defaultDefine[key] then
        return nil
    end
    return FormatValue(defaultDefine[key].Default or nil)
end

-- カスタムパラメータから指定キーの定義と値をテーブルで取得
-- p1:string/song groupOrSong グループフォルダ名の文字列またはsong型
-- p2:string key Group.ini/luaに定義したカスタムキー名
-- 定義値, 曲単位のパラメータ配列 を返却
local function GetCustomValue(self, groupOrSong, key)
    local song = (type(groupOrSong) ~= 'string') and groupOrSong or nil
    local groupName = song and song:GetGroupName() or groupOrSong
    if not groupName or groupName == '' then
        return nil, {}
    end
    if not groupData[key] then
        SetData(groupName, key)
    end
    local data = song and groupData[key][GetSongLowerDir(song)] or {groupData[key][groupName], {}}
    data[1] = data[1] or (defaultDefine[key] and defaultDefine[key].Default or nil)
    return data[1], data[2]
end

-- グループ名を取得
-- p1:グループ名
-- 曲単位のパラメータ配列 は破棄
local function GetGroupName(self, groupName)
    return groupData.Name[groupName] or SONGMAN:ShortenGroupName(groupName) or nil
end

-- グループカラーを取得
-- p1:グループ名
-- 曲単位のパラメータ配列 は破棄
local function GetGroupColor(self, groupName)
    return groupData.GroupColor[groupName] or nil
end

-- URLを取得
-- p1:グループ名
-- 曲単位のパラメータ配列 は破棄
local function GetUrl(self, groupName)
    return groupData.Url[groupName] or nil
end

-- コメントを取得
-- p1:グループ名
-- 曲単位のパラメータ配列 は破棄
local function GetComment(self, groupName)
    return groupData.Comment[groupName] or nil
end

-- song型からORIGINALNAMEを取得
-- p1:Song
-- 曲単位のパラメータ配列 は破棄
local function GetOriginalName(self, song)
    return groupData.OriginalName[GetSongLowerDir(song)]
        and groupData.OriginalName[GetSongLowerDir(song)][1]
        or groupData.OriginalName[song:GetGroupName()]
        or song:GetGroupName()
        or nil
end

-- song型からMETERTYPEを取得
-- p1:Song
-- 曲単位のパラメータ配列 は破棄
local function GetMeterType(self, song)
    return groupData.MeterType[GetSongLowerDir(song)]
        and groupData.MeterType[GetSongLowerDir(song)][1]
        or groupData.MeterType[song:GetGroupName()]
        or defaultDefine.MeterType.Default
        or nil
end

-- song型からMENUCOLORを取得
-- p1:Song
-- 曲単位のパラメータ配列 は破棄
local function GetMenuColor(self, song)
    return groupData.MenuColor[GetSongLowerDir(song)]
        and groupData.MenuColor[GetSongLowerDir(song)][1]
        or groupData.MenuColor[song:GetGroupName()]
        or defaultDefine.MenuColor.Default
        or nil
end

-- song型からLYRICTYPEを取得
-- p1:Song
local function GetLyricType(self, song)
    local data = song
            and groupData.LyricType[GetSongLowerDir(song)]
            or {groupData.LyricType[song:GetGroupName()], {}}
    data[1] = data[1] or (defaultDefine.LyricType and defaultDefine.LyricType.Default or nil)
    return data[1], data[2]
end

-- ソートファイルを作成
-- p1:ソートファイル名（Group）
-- p2:グループをNameで指定したテキストでソート（true）
local function CreateSortText(self, ...)
    local sortName, groupNameSort = ...
    sortName = sortName or 'Group'
    groupNameSort = (groupNameSort == nil) and true or groupNameSort
    -- 1文字目が英数字以外の場合、ソートで後ろに行くように先頭にstring.char(126)をつける
    local Adjust = function(text)
        return string.gsub(string.gsub(text, '^%.', ''), '^([^%w])', string.char(126)..'%1')
    end
    local f = RageFileUtil.CreateRageFile()
    if not f:Open(THEME:GetCurrentThemeDirectory()..'Other/SongManager '..sortName..'.txt', 2) then
        f:destroy()
        return
    end
    -- 通常ソート
    local groupList = {}
    for _, groupName in pairs(SONGMAN:GetSongGroupNames()) do
        groupList[#groupList+1] = {
            Original = groupName,
            Sort     = string.lower(groupNameSort and Adjust(GetGroupName(self, groupName)) or groupName),
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
        for k,_ in pairs(sortList) do
            if k ~= 'Default' then  -- デフォルトは無視
                for i, dir in pairs(sortData[k] or {}) do
                    local folder = (type(dir) == 'table') and dir[1] or dir
                    sortOrder[string.lower(folder)] = (k ~= 'Hidden') and i + 100000 * sortList[k] or 0
                end
            end
        end
        -- ソート用のテーブル作成
        local dirList = {}
        local dirCount = 0
        for _, song in pairs(SONGMAN:GetSongsInGroup(groupName)) do
            local dir = song:GetSongDir()
            -- 楽曲フォルダ名（小文字）を取得
            local key = string.lower(string.gsub(dir, '/[^/]*Songs/[^/]+/([^/]+)/', '%1'))
            if sortOrder[key] ~= 0 then    -- 0 = Hidden（※Default = nil）
                dirCount = dirCount + 1
                dirList[#dirList+1] = {
                    Dir  = string.gsub(dir, '/[^/]*Songs/(.+)', '%1'),
                    Sort = sortOrder[key] or 0,
                    Name = string.lower(Adjust(song:GetTranslitMainTitle()..'  '..song:GetTranslitSubTitle())),
                }
            end
        end
        if dirCount > 0 then
            table.sort(dirList, function(a, b)
                                    if a.Sort ~= b.Sort then
                                        return a.Sort < b.Sort
                                    else
                                        return a.Name < b.Name
                                    end
                                end)
            f:PutLine("---"..groupName)
            for _,dir in pairs(dirList) do
                f:PutLine(dir.Dir)
            end
        end
    end
    f:Close()
    f:destroy()
    SONGMAN:SetPreferredSongs(sortName)
end

-- 初期化
AddTargetKey(nil, 'Name',         'string')
AddTargetKey(nil, 'GroupColor',   'color')
AddTargetKey(nil, 'Url',          'string')
AddTargetKey(nil, 'Comment',      'string')
AddTargetKey(nil, 'OriginalName', 'string')
AddTargetKey(nil, 'MeterType',    'string', {Default = 'DDR', DDRX = 'DDR X', ITG = 'ITG'})
AddTargetKey(nil, 'MenuColor',    'color')
AddTargetKey(nil, 'LyricType',    'mixed', {Default = 'Default'})

return {
    Scan         = Scan,
    Raw          = GetRaw,
    Name         = GetGroupName,
    GroupColor   = GetGroupColor,
    Url          = GetUrl,
    Comment      = GetComment,
    OriginalName = GetOriginalName,
    MenuColor    = GetMenuColor,
    MeterType    = GetMeterType,
    LyricType    = GetLyricType,
    Custom       = GetCustomValue,
    Sort         = CreateSortText,
    AddKey       = AddTargetKey,
    Fallback     = GetFallback,
}

--[[
Group_lua.lua

Copyright (c) 2021 A.C

This software is released under the MIT License.
https://opensource.org/licenses/mit-license.php
--]]