--[[ Group_Lua v20241210]]

-- このファイルの絶対パス
local absolutePath = string.gsub(string.sub(debug.getinfo(1).source, 2), '(.+/)[^/]+', '%1')

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
if FILEMAN:DoesFileExist(absolutePath..groupIniFile) then
    groupIni = dofile(absolutePath..groupIniFile)
end

-- ファイルを検索してパスを返却（大文字小文字を無視）
-- 外部呼出し不可
-- p1:グループ名
-- p2:ファイル名
-- p3:前方一致検索
local function SearchFile(groupName, searchFileName, ...)
    local leftMatch = ...
    for i=1, #songPathList do
        local dirList = FILEMAN:GetDirListing(songPathList[i]..groupName..'/')
        for d=1, #dirList do
            local lSearch, lFilename = string.lower(searchFileName), string.lower(dirList[d])
            if (not leftMatch and lSearch == lFilename) or string.find(lFilename, lSearch, 1, true) then
                return songPathList[i]..groupName..'/'..dirList[d]
            end
        end
    end
    return nil
end

-- カラーとして変換
-- 外部呼出し不可
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
-- 外部呼出し不可
local function GetSongLowerDir(song)
    return string.lower(string.gsub(song:GetSongDir(), '/[^/]*Songs/(.+)', '%1'))
end

-- Group.iniを読み込む
-- 外部呼出し不可
local function LoadGroupIni(filePath)
    if filePath and groupIni then
        return groupIni:Load(filePath)
    else
        return {}
    end
end

-- 値をフォーマット
-- 外部呼出し不可
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
-- 外部呼出し不可
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
-- p2:取得するキー（nilの場合全データを取得）
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

-- グループの定義部分を取得
-- p1:グループ名
-- p2:取得するキー
local function GetDefine(self, groupName, key)
    local define = {}
    for k,v in pairs(defaultDefine[key] or {}) do
        define[string.lower(k)] = v
    end
    local raw = GetRaw(self, groupName, key)
    if not raw then
        return define
    end
    -- テーブル以外、またはテーブルだがcolor型
    if type(raw) ~= 'table' or (keyType[key] == 'color' and #raw == 4) then
        define.default = FormatValue(raw, key)
    else
        for k,v in pairs(raw[1] or {}) do
            define[string.lower(k)] = v
        end
    end
    return define
end

-- パラメータを指定して一時変数に格納
-- 外部呼出し不可
-- groupData[key][グループフォルダ名] = デフォルト値
-- groupData[key][小文字（グループフォルダ名/楽曲フォルダ名/）][定義名] = {楽曲単位の値, 追加パラメータ}
local function SetData(groupName, key)
    if not groupData[key] then
        groupData[key] = {}
    end
    local data = {}
    local raw = GetRaw(nil, groupName, key)
    if type(raw) == 'table' then
        -- キー名を大文字小文字で区別しないようにする
        for k,v in pairs(raw or {}) do
            data[(k == 1) and 1 or string.lower(k)] = v
        end
    else
        data = raw
    end
    raw = nil
    if data then
        local lGroupName = string.lower(groupName)
        -- デフォルトの定義を設定
        local define = GetDefine(nil, groupName, key)
        -- デフォルト値
        groupData[key][groupName] = FormatValue(define.default or nil, key)

        -- デフォルト定義のみの場合はここで処理終了
        if type(data) ~= 'table' or (keyType[key] == 'color' and #data == 4) then
            return
        end

        -- フォルダ単位で定義
        -- 各フォルダ
        for k,_ in pairs(define or {}) do
            if k ~= 'default' and data[k] and type(data[k]) == 'table' then
                for _,v in pairs(data[k]) do
                    if type(v) == 'string' then
                        -- フォルダ名のみを定義
                        if not groupData[key][lGroupName..'/'..string.lower(v)..'/'] then
                            groupData[key][lGroupName..'/'..string.lower(v)..'/'] = {}
                        end
                        groupData[key][lGroupName..'/'..string.lower(v)..'/'][k] = {FormatValue(define[k], key), {}}
                    elseif type(v) == 'table' then
                        -- 楽曲単位でパラメータを定義
                        local folder = v[1] or nil
                        if folder then
                            if not groupData[key][lGroupName..'/'..string.lower(folder)..'/'] then
                                groupData[key][lGroupName..'/'..string.lower(folder)..'/'] = {}
                            end
                            -- 数字キーを削除、大文字小文字を区別させない
                            local params = {}
                            for vk,vv in pairs(v) do
                                if type(vk) ~= 'number' then
                                    params[string.lower(vk)] = vv
                                end
                            end
                            groupData[key][lGroupName..'/'..string.lower(folder)..'/'][k] = {FormatValue(define[k], key), params or {}}
                        end
                    end
                end
            end
        end
    end
end

-- 取得対象のキーを追加
-- p1:登録するキー
-- p2:キーの型の種類（number/string/table/mixed/functionのいずれか）
-- p3:デフォルトの定義（未指定の場合、p2の値によって決まる）
local function AddTargetKey(self, key, typeString, ...)
    local define = ...
    keyType[key] = typeString
    if define and type(define) == 'table' then
        defaultDefine[key] = {}
        for k,v in pairs(define) do
            defaultDefine[key][string.lower(k)] = v
        end
        if not defaultDefine[key].default then
            defaultDefine[key].default = FormatValue(nil, key)
        end
    else
        defaultDefine[key] = {default = FormatValue(define or nil, key)}
    end
end

-- フォルダをスキャン
-- p1:グループ名 (nil)
local function Scan(self, ...)
    local groupName = ...
    -- グループ名の指定がない場合は全グループを検索
    if not groupName then
        local groups = SONGMAN and SONGMAN:GetSongGroupNames() or {}    -- 5.0.7RC対策
        for _, group in pairs(groups) do
            Scan(self, group)
        end
        return
    end

    -- 読みこんでRawに保存
    local groupLuaPath = SearchFile(groupName, 'group.lua')
    local groupIniPath = (not groupLuaPath) and SearchFile(groupName, 'group.ini') or nil
    SetRaw(groupName, groupLuaPath, groupIniPath)

    -- 情報を取得
    for key,_ in pairs(keyType) do
        SetData(groupName, key)
    end
end

-- キーのデフォルト値を取得
-- p1:取得するキー
local function GetFallback(key)
    if not defaultDefine[key] then
        return nil
    end
    return FormatValue(defaultDefine[key].default or nil)
end

-- テーブルを返却した場合、上書きされる可能性があるので配列をコピーして返却する
-- 配列以外はそのまま返却する
local function CopyTable(tbl)
    if type(tbl) ~= 'table' then
        return tbl
    end
    local ret = {}
    for k,v in pairs(tbl) do
        ret[k] = v
    end
    return ret
end

-- カスタムパラメータから指定キーの定義と値をテーブルで取得
-- p1:string/song groupOrSong グループフォルダ名の文字列またはsong型
-- p2:string key Group.ini/luaに定義したカスタムキー名
-- p3:string defineName 楽曲に対して複数の値が設定されている場合、取得する定義名
-- 定義値, 曲単位のパラメータ配列 を返却
local function GetCustomValue(self, groupOrSong, key, ...)
    local defineName = ...
    local song = (type(groupOrSong) ~= 'string') and groupOrSong or nil
    local groupName = song and song:GetGroupName() or groupOrSong
    if not groupName or groupName == '' then
        return nil, {}
    end
    if not groupData[key] then
        SetData(groupName, key)
    end
    local data = {}
    if song and groupData[key][GetSongLowerDir(song)] then
        -- defineが定義されていない場合は最初の定義
        if not defineName then
            for k,_ in pairs(groupData[key][GetSongLowerDir(song)] or {}) do
                defineName = k
                break
            end
        end
        data = groupData[key][GetSongLowerDir(song)][string.lower(defineName)]
    else
        data = {groupData[key][groupName], {}}
    end
    data[1] = data[1] or (defaultDefine[key] and defaultDefine[key].default or nil)
    return CopyTable(data[1]), CopyTable(data[2])
end

-- グループ名を取得
-- p1:グループ名
-- 曲単位のパラメータ配列 は破棄
local function GetGroupName(self, groupName)
    return CopyTable(groupData.Name and (groupData.Name[groupName] or SONGMAN:ShortenGroupName(groupName)) or nil)
end

-- グループカラーを取得
-- p1:グループ名
-- 曲単位のパラメータ配列 は破棄
local function GetGroupColor(self, groupName)
    return CopyTable(groupData.GroupColor and groupData.GroupColor[groupName] or nil)
end

-- URLを取得
-- p1:グループ名
-- 曲単位のパラメータ配列 は破棄
local function GetUrl(self, groupName)
    return CopyTable(groupData.Url and groupData.Url[groupName] or nil)
end

-- コメントを取得
-- p1:グループ名
-- 曲単位のパラメータ配列 は破棄
local function GetComment(self, groupName)
    return CopyTable(groupData.Comment and groupData.Comment[groupName] or nil)
end

-- song型からORIGINALNAMEを取得
-- p1:Song
-- 曲単位のパラメータ配列 は破棄
local function GetOriginalName(self, song)
    if not groupData.OriginalName then
        return nil
    end
    local ret
    if groupData.OriginalName[GetSongLowerDir(song)] then
        for _,v in pairs(groupData.OriginalName[GetSongLowerDir(song)] or {}) do
            if v[1] then
                ret = v[1]
                break
            end
        end
    end
    return CopyTable(ret or groupData.OriginalName[song:GetGroupName()]
        or song:GetGroupName()
        or nil)
end

-- song型からMETERTYPEを取得
-- p1:Song
-- 曲単位のパラメータ配列 は破棄
local function GetMeterType(self, song)
    if not groupData.MeterType then
        return nil
    end
    local ret
    if groupData.MeterType[GetSongLowerDir(song)] then
        for _,v in pairs(groupData.MeterType[GetSongLowerDir(song)] or {}) do
            if v[1] then
                ret = v[1]
                break
            end
        end
    end
    return CopyTable(ret or groupData.MeterType[song:GetGroupName()]
        or defaultDefine.MeterType.default
        or nil)
end

-- song型からMENUCOLORを取得
-- p1:Song
-- 曲単位のパラメータ配列 は破棄
local function GetMenuColor(self, song)
    if not groupData.MenuColor then
        return nil
    end
    local ret
    if groupData.MenuColor[GetSongLowerDir(song)] then
        for _,v in pairs(groupData.MenuColor[GetSongLowerDir(song)] or {}) do
            if v[1] then
                ret = v[1]
                break
            end
        end
    end
    return CopyTable(ret or groupData.MenuColor[song:GetGroupName()]
        or defaultDefine.MenuColor.default
        or nil)
end

-- song型からLYRICTYPEを取得
-- p1:Song
local function GetLyricType(self, song)
    if not groupData.LyricType then
        return nil
    end
    local data
    if groupData.LyricType[GetSongLowerDir(song)] then
        for _,v in pairs(groupData.LyricType[GetSongLowerDir(song)] or {}) do
            data = v
            break
        end
    end
    data = data or {groupData.LyricType[song:GetGroupName()], {}}
    data[1] = data[1] or (defaultDefine.LyricType and defaultDefine.LyricType.default or nil)
    return CopyTable(data[1]), CopyTable(data[2])
end

-- 1文字目が英数字以外の場合、ソートで後ろに行くように先頭にstring.char(126)をつける
local function AdjustSortText(text)
    return string.gsub(string.gsub(text, '^%.', ''), '^([^%w])', string.char(126)..'%1')
end

-- グループ単位のソートした情報を取得
-- p1:グループフォルダ名
-- return:ソート後のテーブル[Dir, Sort, Name]
local function GetGroupSort(self, groupName)
    local sortDataOrg = GetRaw(self, groupName, 'SortList') or {}
    local sortList = {
        default = 0,
        front   = -1,
        rear    = 1,
        hidden  = 0,
    }
    local sortOrder = {}
    -- ソート優先度を定義しているか取得
    for k,v in pairs(sortDataOrg[1] or {}) do
        sortList[string.lower(k)] = tonumber(v)
    end
    -- キーを小文字で持つ（group.luaの方で大文字小文字を区別させない）
    local sortData = {}
    for k,v in pairs(sortDataOrg) do
        if k ~= 1 then
            sortData[string.lower(k)] = v
        end
    end
    sortDataOrg = nil
    -- ソート順序を設定
    for k,_ in pairs(sortList) do
        if k ~= 'default' then  -- デフォルトは無視
            for i, dir in pairs(sortData[k] or {}) do
                local folder = (type(dir) == 'table') and dir[1] or dir
                sortOrder[string.lower(folder)] = (k ~= 'hidden') and i + 100000 * sortList[k] or 0
            end
        end
    end
    -- ソート用のテーブル作成
    local dirList = {}
    for _, song in pairs(SONGMAN:GetSongsInGroup(groupName)) do
        local dir = song:GetSongDir()
        -- 楽曲フォルダ名（小文字）を取得
        local key = string.lower(string.gsub(dir, '/[^/]*Songs/[^/]+/([^/]+)/', '%1'))
        if sortOrder[key] ~= 0 then    -- 0 = Hidden（※Default = nil）
            dirList[#dirList+1] = {
                Dir  = string.gsub(dir, '/[^/]*Songs/(.+)', '%1'),
                Song = song,
                Sort = sortOrder[key] or 0,
                Name = string.lower(AdjustSortText(song:GetTranslitMainTitle()..'  '..song:GetTranslitSubTitle())),
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
    return dirList
end

-- ソートファイルを作成
-- p1:ソートファイル名（Group）
-- p2:グループをGroup.luaのNameで指定したテキストでソート（true）
local function CreateSortText(self, ...)
    local sortName, groupNameSort = ...
    sortName = sortName or 'Group'
    groupNameSort = (groupNameSort == nil) and true or groupNameSort
    local f = RageFileUtil.CreateRageFile()
    if not f:Open(THEME:GetCurrentThemeDirectory()..'Other/SongManager '..sortName..'.txt', 2) then
        f:destroy()
        return
    end
    -- 通常ソート
    local groupList = {}
    for _, groupName in pairs(SONGMAN:GetSongGroupNames()) do
        local name = string.lower(groupNameSort and AdjustSortText(GetGroupName(self, groupName)) or groupName)
        groupList[#groupList+1] = {
            Original = groupName,
            Name     = name,
            Series   = {Group = name, Version = -1, Index = 0}
        }
    end
    for i=1, #groupList do
        for _, groupName in pairs(SONGMAN:GetSongGroupNames()) do
            local Series = GetRaw(self, groupName, 'Series')
            if Series then
                for index=1, #(Series.List or {}) do
                    local version = tonumber(Series.Version) or 0
                    if Series.List[index] == groupList[i].Original
                        and version > groupList[i].Series.Version then
                        groupList[i].Series.Group = string.lower(groupNameSort and AdjustSortText(GetGroupName(self, groupName)) or groupName)
                        groupList[i].Series.Version = version
                        groupList[i].Series.Index = index
                        break
                    end
                end
            end
        end
    end
    for i=1, #groupList do
        groupList[i].Sort = string.format(
            -- [A]より[A B]が後ろに行くようにスペースを二つ付ける
            '%s  :%010.2f:%04d:%s',
            groupList[i].Series.Group,
            groupList[i].Series.Version,
            groupList[i].Series.Index,
            groupList[i].Name
        )
    end
    table.sort(groupList, function(a, b)
                return a.Sort < b.Sort
            end)
    -- table.sort(groupList, function(a, b)
    --             return a.Name < b.Name
    --         end)
    for g = 1, #groupList do

        local groupName = groupList[g].Original
        local dirList = GetGroupSort(self, groupName)

        if #dirList > 0 then
            f:PutLine("---"..groupName)
            for _,dir in pairs(dirList) do
                f:PutLine(dir.Dir)
            end
        end
    end
    f:Close()
    f:destroy()
    if FILEMAN.FlushDirCache then
        FILEMAN:FlushDirCache(THEME:GetCurrentThemeDirectory()..'Other/')
    end
    SONGMAN:SetPreferredSongs(sortName)
end

-- 楽曲の表示条件を満たしているかチェック
-- p1:songまたは楽曲フォルダのパス（グループフォルダ名/楽曲フォルダ名/）
-- p2:取得対象の定義名（Folderの識別子）
local function IsFolderSongEnabled(self, songOrPath, defineName)
    local path = (type(songOrPath) ~= 'string') and GetSongLowerDir(songOrPath) or string.lower(songOrPath)
    local songData = groupData.Folder[path] and groupData.Folder[path][defineName] or nil
    -- 楽曲がdefineのリストに存在しない
    if not songData then
        return false
    end
    -- 条件が設定されていない（常に表示）
    if not songData[2] or songData[2].condition == nil then
        return true
    end
    -- 条件をチェック（関数）
    if type(songData[2].condition) == 'function' then
        return songData[2].condition()
    end
    -- 条件をチェック（真偽値）
    return (songData[2].condition ~= false)
end

-- フォルダ一覧を取得
-- p1:グループ名
-- p2:楽曲表示条件を満たしているフォルダのみ（デフォルトtrue）
local function GetFolderList(self, groupName, ...)
    local activeOnly = ...
    activeOnly = (activeOnly == nil or activeOnly ~= false)
    local folderList = {}
    local data = GetRaw(nil, groupName, 'Folder')
    for k,v in pairs(data and data[1] or {}) do
        local condition = false
        -- activeOnlyがfalseの場合は強制的に表示条件true
        if not activeOnly then
            condition = true
        else
            if type(v.condition) == 'function' then
                condition = v.condition()
            else
                -- false以外（未指定かtrue）なら表示条件true
                condition = (v.condition ~= false)
            end
        end
        if condition then
            -- 全フォルダ取得
            local show = {}
            -- vFolderは楽曲フォルダ名か{フォルダ名, params}の配列
            for _,vFolder in pairs(data and data[k] or {}) do
                local folder = (type(vFolder) == 'table') and vFolder[1] or vFolder
                if type(folder) == 'string' then
                    -- 全フォルダ取得モードか楽曲表示条件を満たしている場合楽曲フォルダ名を一覧に追加
                    if not activeOnly or IsFolderSongEnabled(self, groupName..'/'..folder..'/', k) then
                        show[#show+1] = folder
                    end
                end
            end
            if #show > 0 then
                folderList[k] = show
            end
        end
    end
    return folderList
end

-- フォルダの詳細を取得
-- p1:グループ名
-- p2:Folderの識別子
local function GetFolder(self, groupName, defineName)
    local raw = GetRaw(nil, groupName, 'Folder')
    local folder = raw and raw[1] and raw[1][defineName] or {}
    local jacket = SearchFile(groupName, 'jacket', true)
    local condition
    -- EXFolderの場合は明示的に条件指定しなくても判定する
    if defineName == 'EXFolder1' or defineName == 'EXFolder2' then
        condition = EXFCondition(defineName)
    else
        -- 定義が存在していればtrue
        condition = (raw and raw[1] and raw[1][defineName]) and true or false
    end
    -- 三項演算だとand falseのときにorが実行されるのでここで判定、ただし既にfalseの場合は不要
    if folder.Condition and condition then
        if type(folder.Condition) == 'function' then
            condition = folder.Condition()
        else
            condition = folder.Condition
        end
    end
    local bannerPath = SONGMAN:GetSongGroupBannerPath(groupName)
    return {
        Defined = (raw and raw[1] and raw[1][defineName]) and true or false,
        Name = folder.Name or defineName,
        Jacket = folder.Jacket or (jacket or bannerPath),
        Banner = folder.Banner or bannerPath,
        Condition = condition,
    }
end


-- 初期化
AddTargetKey(nil, 'Name',         'string')
AddTargetKey(nil, 'GroupColor',   'color')
AddTargetKey(nil, 'Url',          'string')
AddTargetKey(nil, 'Comment',      'string')
AddTargetKey(nil, 'OriginalName', 'string')
AddTargetKey(nil, 'MeterType',    'string', {Default = 'DDR', DDR = 'DDR', DDRX = 'DDR X', X = 'DDR X', ITG = 'ITG'})
AddTargetKey(nil, 'MenuColor',    'color')
AddTargetKey(nil, 'LyricType',    'mixed', {Default = 'Default'})
AddTargetKey(nil, 'Folder',       'mixed')

EXFCondition = function(value)
    return true
end

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
    GroupSort    = GetGroupSort,
    Sort         = CreateSortText,
    AddKey       = AddTargetKey,
    Fallback     = GetFallback,
    Define       = GetDefine,
    FolderSong   = IsFolderSongEnabled,
    FolderList   = GetFolderList,
    Folder       = GetFolder,
}

--[[
Group_lua.lua

Copyright (c) 2021 A.C

This software is released under the MIT License.
https://opensource.org/licenses/mit-license.php
--]]