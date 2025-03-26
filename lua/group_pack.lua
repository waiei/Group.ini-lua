--[[ Group_Pack v20250326 ]]

-- Format
-- https://github.com/itgmania/itgmania/releases/tag/v1.0.0

-- 検索対象の楽曲フォルダ
local songPathList = {
    '/Songs/',
    '/AdditionalSongs/',
}

-- ファイルを検索してパスを返却（大文字小文字を無視）
-- 公式は大文字小文字区別してPack.iniしか読み取らないらしいけど…なんで？
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

-- Series判定のために最初に全グループチェックを行う
local checked = false
local packSeries = {}
local allGroupPack = {}

local function GetAllPack()
    local nativeLang = PREFSMAN:GetPreference('ShowNativeLanguage')
    packSeries = {}
    allGroupPack = {}
    for _,group in pairs(SONGMAN:GetSongGroupNames()) do
        local file = SearchFile(group, 'pack.ini')
        if file then
            local pack = IniFile.ReadFile(file)
            if pack.Group then
                local pg = pack.Group
                -- 同一シリーズが存在すればテーブルに貯めていってその都度ソート、
                -- 後で読み込むほどGroup.lua/Seriesのバージョンが上がるので
                -- 結果的に同一シリーズで最後に読み取ったグループフォルダの情報が使用される
                -- ちょっと効率が悪いけどグループフォルダが数百無いのであれば速度的な問題はないかと
                if pg.Series then
                    local series = pg.Series
                    if not packSeries[pg.Series] then
                        packSeries[pg.Series] = {}
                    end
                    packSeries[pg.Series][#packSeries[pg.Series]+1] = {
                        Key = pg.SortTitle or pg.DisplayTitle or group,
                        Group = group,
                    }
                    table.sort(packSeries[pg.Series], function(a, b) return a.Key < b.Key end)
                end
                allGroupPack[group] = {
                    -- enテキストしか許容していない場合はTranslitTitleを取得する
                    Name = nativeLang and pg.DisplayTitle or pg.TranslitTitle or group,
                }
                if packSeries[pg.Series] then
                    local s = {}
                    for _,ps in pairs(packSeries[pg.Series]) do
                        s[#s+1] = ps.Group
                    end
                    allGroupPack[group].Series = {
                        Version = #s,
                        List = s,
                    }
                end
            end
        end
    end
    checked = true
end

return {
    PackReset = function(self)
        checked = false
    end,
    Load = function(self, groupName)
        if not checked then
            GetAllPack()
        end
        return allGroupPack[groupName] or {}
    end,
}


--[[
Group_pack.lua

Copyright (c) 2025 A.C

This software is released under the MIT License.
https://github.com/waiei/Group.ini-lua/blob/main/LICENSE
--]]
