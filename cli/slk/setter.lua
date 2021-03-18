--- F6 物编
--- 固定配置项
local F6_CONF = {
    courierSkill = {
        -- 信使技能-名称、热键、图标位置、冷却
        blink = {
            Ubertip = "闪烁到任何地方", Art = "ReplaceableTextures\\CommandButtons\\BTNBlink.blp",
            Hotkey = 'Q', Buttonpos_1 = 0, Buttonpos_2 = 2, Cool1 = 10
        },
        rangePickUp = {
            Ubertip = "将附近地上的物品拾取到身上", Art = "ReplaceableTextures\\CommandButtons\\BTNPickUpItem.blp",
            Hotkey = 'W', Buttonpos_1 = 1, Buttonpos_2 = 2, Cool1 = 5
        },
        separate = {
            Ubertip = "将合成或重叠的物品拆分成零件", Art = "ReplaceableTextures\\CommandButtons\\BTNRepair.blp",
            Hotkey = 'E', Buttonpos_1 = 2, Buttonpos_2 = 2, Cool1 = 5
        },
        deliver = {
            Ubertip = "将所有物品依照顺序传送给英雄，当你的英雄没有空余物品位置，物品会返回给信使", Art = "ReplaceableTextures\\CommandButtons\\BTNLoadPeon.blp",
            Hotkey = 'R', Buttonpos_1 = 3, Buttonpos_2 = 2, Cool1 = 5
        },
    },
    -- 描述文本颜色,可配置 hcolor 里拥有的颜色函数，也可以配置 hex 6位颜色码
    color = {
        hotKey = "ffcc00", -- 热键
        itemCoolDown = "ccffff", -- 物品冷却时间
        itemAttr = "b0f26e", -- 物品属性
        itemOverlie = "ff59ff", -- 物品叠加
        itemWeight = "ee82ee", -- 物品重量
        itemRemarks = "969696", -- 物品备注
        itemFragment = hcolor.orange, -- 物品零部件
        itemProfit = "ffd88c", -- 物品合成品
        abilityCoolDown = "ccffff", -- 技能冷却时间
        abilityAttr = "b0f26e", -- 技能属性
        abilityRemarks = "969696", -- 技能备注
        ringArea = "99ccff", -- 光环范围
        ringTarget = "99ccff", -- 光环作用目标
        heroWeapon = "ff3939", -- 英雄攻击武器类型
        heroAttack = "ff8080", -- 英雄基础攻击
        heroRange = "99ccff", -- 英雄攻击范围
        heroPrimary = "ffff00", -- 英雄主属性
        heroSecondary = "ffffcc", -- 英雄主属性
        heroMove = "ccffcc", -- 英雄移动
    },
}
F6_CONF_SET = function(conf)
    F6_CONF = conf
end

local F6_IDX = 0
local F6_NAME = function(name)
    F6_IDX = F6_IDX + 1
    return (name or "HL-NAME") .. "-" .. F6_IDX
end

local F6V_I_SYNTHESIS_TMP = {
    profit = {},
    fragment = {},
}

local F6S = {}
F6S.txt = function(v, key, txt, sep)
    sep = sep or "|n"
    if (v[key] == nil) then
        v[key] = txt
    else
        v[key] = v[key] .. sep .. txt
    end
end
F6S.a = {
    --- 属性系统目标文本修正
    targetLabel = function(target, actionType, actionField, isValue)
        if (actionType == 'spec' and isValue ~= true and table.includes({ 'split', 'bomb', 'lightning_chain' }, actionField)) then
            if (target == '己') then
                target = '友军'
            else
                target = '敌军'
            end
        else
            if (target == '己') then
                target = '自己'
            else
                target = '敌人'
            end
        end
        return target
    end,
    --- 键值是否百分比数据
    isPercent = function(key)
        if (table.includes({
            "attack_speed", "avoid", "aim",
            "hemophagia", "hemophagia_skill",
            "invincible",
            "knocking_odds", "knocking_extent",
            "damage_extent", "damage_decrease", "damage_rebound",
            "cure",
            "gold_ratio", "lumber_ratio", "exp_ratio", "sell_ratio",
            "knocking", "split",
        }, key))
        then
            return true
        end
        local s = string.find(key, "_oppose")
        local n = string.find(key, "e_")
        local a = string.find(key, "_attack")
        local p = string.find(key, "_append")
        if (a ~= nil or p ~= nil) then
            return false
        end
        if (s ~= nil or n == 1) then
            return true
        end
        return false
    end,
    --- 键值是否层级数据
    isLevel = function(key)
        local a = string.find(key, "_attack")
        local p = string.find(key, "_append")
        local n = string.find(key, "e_")
        if ((a ~= nil or p ~= nil) and n == 1) then
            return true
        end
        return false
    end,
    --- _attr文本构建
    attr = function(attr, sep, indent)
        indent = indent or ""
        local str = {}
        local strTable = {}
        sep = sep or "|n"
        for _, arr in ipairs(table.obj2arr(attr, CONST_ATTR_KEYS)) do
            local k = arr.key
            local v = arr.value
            -- 附加单位
            if (k == "attack_space" or k == "reborn") then
                v = v .. "秒"
            end
            if (table.includes({ "life_back", "mana_back" }, k)) then
                v = v .. "每秒"
            end
            if (F6S.a.isPercent(k) == true) then
                v = v .. "%"
            end
            if (F6S.a.isLevel(k) == true) then
                v = v .. "层"
            end
            --
            if (k == "xtras") then
                table.insert(strTable, (CONST_ATTR[k] or "") .. "：")
                local tempStr = {}
                for vvi, vv in ipairs(v) do
                    local on = vv["on"]
                    local actions = string.explode('.', vv["action"] or '')
                    if (CONST_EVENT_LABELS[on] ~= nil and #actions == 3) then
                        local target = CONST_EVENT_TARGET_LABELS[on][actions[1]]
                        local actionType = actions[2]
                        local actionField = actions[3]
                        local actionFieldLabel = CONST_ATTR[actionField]
                        local odds = vv["odds"] or 0
                        local during = vv["during"] or 0
                        local val = vv["val"] or 0
                        local percent = vv["percent"] or 100
                        local qty = vv["qty"] or 0
                        local rate = vv["rate"] or 0
                        local radius = vv["radius"] or 0
                        local distance = vv["distance"] or 0
                        local height = vv["height"] or 0
                        --
                        if (odds > 0 and percent ~= nil and val ~= nil) then
                            -- 拼凑文本
                            local temp2 = '　' .. vvi .. '.' .. CONST_EVENT_LABELS[on] .. '时,'
                            temp2 = temp2 .. "有"
                            temp2 = temp2 .. odds .. "%几率"
                            if (during > 0) then
                                temp2 = temp2 .. "在" .. during .. "秒内"
                            end

                            -- 拼凑值
                            local valLabel
                            local unitLabel = "%"
                            local isNegative = false
                            if (type(percent) == 'table') then
                                unitLabel = ''
                            elseif (percent % 100 == 0) then
                                unitLabel = "倍"
                                percent = math.floor(percent / 100)
                            end
                            if (type(val) == 'number') then
                                if (unitLabel == "%") then
                                    valLabel = math.round(percent * 0.01 * math.abs(val))
                                elseif (unitLabel == "倍") then
                                    valLabel = math.round(percent * math.abs(val))
                                elseif (unitLabel == '') then
                                    valLabel = '随机' .. math.round(percent[1] * math.abs(val)) .. '~' .. math.round(percent[2] * 0.01 * math.abs(val))
                                end
                                isNegative = val < 0
                            elseif (type(val) == 'string') then
                                if (unitLabel == '') then
                                    percent = '随机' .. percent[1] .. '%~' .. percent[2] .. '%'
                                end
                                isNegative = (string.sub(val, 1, 1) == '-')
                                if (isNegative) then
                                    val = string.sub(val, 2)
                                end
                                if (val == 'damage') then
                                    valLabel = percent .. unitLabel .. "当前伤害"
                                else
                                    local valAttr = string.explode('.', val)
                                    if (#valAttr == 2 and CONST_EVENT_TARGET_LABELS[on] and CONST_EVENT_TARGET_LABELS[on][valAttr[1]]) then
                                        local au = CONST_EVENT_TARGET_LABELS[on][valAttr[1]]
                                        au = F6S.a.targetLabel(au, actionType, actionField, true)
                                        local aa = valAttr[2]
                                        if (aa == 'level') then
                                            valLabel = percent .. unitLabel .. au .. "当前等级"
                                        elseif (aa == 'gold') then
                                            valLabel = percent .. unitLabel .. au .. "当前黄金量"
                                        elseif (aa == 'lumber') then
                                            valLabel = percent .. unitLabel .. au .. "当前木头量"
                                        else
                                            valLabel = percent .. unitLabel .. au .. (CONST_ATTR[aa] or '不明属性') .. ""
                                        end
                                    end
                                end
                            end
                            -- 补正百分号
                            if (type(val) == 'number' and F6S.a.isPercent(actionField) == true) then
                                valLabel = valLabel .. "%"
                            end
                            -- 对象名称修正
                            target = F6S.a.targetLabel(target, actionType, actionField)
                            if (valLabel ~= nil) then
                                if (actionType == 'attr') then
                                    if (isNegative) then
                                        temp2 = temp2 .. "减少" .. target
                                    else
                                        temp2 = temp2 .. "提升" .. target
                                    end
                                    temp2 = temp2 .. valLabel .. "的" .. actionFieldLabel
                                elseif (actionType == 'spec') then
                                    actionFieldLabel = vv["alias"] or actionFieldLabel
                                    if (actionField == "knocking") then
                                        temp2 = temp2
                                            .. "对" .. target .. "造成" .. valLabel .. "的" .. actionFieldLabel .. "的伤害"
                                    elseif (actionField == "split") then
                                        temp2 = temp2
                                            .. actionFieldLabel .. "攻击" .. radius .. "范围的"
                                            .. target .. ",造成" .. valLabel .. "的伤害"
                                    elseif (actionField == "bomb") then
                                        temp2 = temp2
                                            .. actionFieldLabel .. radius .. "范围的" .. target
                                            .. ",造成" .. valLabel .. "的伤害"
                                    elseif (table.includes({ "swim", "silent", "unarm", "fetter" }, actionField)) then
                                        temp2 = temp2
                                            .. actionFieldLabel .. "目标" .. during .. "秒"
                                            .. ",并造成" .. valLabel .. "点伤害"
                                    elseif (actionField == "broken") then
                                        temp2 = temp2
                                            .. actionFieldLabel .. "目标" .. ",并造成" .. valLabel .. "点伤害"
                                    elseif (actionField == "lightning_chain") then
                                        temp2 = temp2
                                            .. "对最多" .. qty .. "个目标"
                                            .. "发动" .. valLabel .. "的伤害的" .. actionFieldLabel
                                        if (rate > 0) then
                                            temp2 = temp2 .. ",每次跳跃渐强" .. rate .. "%"
                                        elseif (rate < 0) then
                                            temp2 = temp2 .. ",每次跳跃衰减" .. rate .. "%"
                                        end
                                    elseif (actionField == "crack_fly") then
                                        temp2 = temp2
                                            .. actionFieldLabel .. "目标达" .. height .. "高度并击退" .. distance .. "距离"
                                            .. ",同时造成" .. valLabel .. "的伤害"
                                    elseif (actionField == "paw") then
                                        temp2 = temp2
                                            .. "向前方击出" .. qty .. "道" .. actionFieldLabel
                                            .. ",对直线" .. radius .. "范围的" .. target .. "造成" .. valLabel .. "的伤害"
                                    end
                                end
                                table.insert(tempStr, indent .. temp2)
                            end
                        end
                    end
                end
                table.insert(strTable, string.implode(sep, tempStr))
            else
                table.insert(str, indent .. (CONST_ATTR[k] or "") .. "：" .. v)
            end
        end
        return string.implode(sep, table.merge(str, strTable))
    end,
    tip = function(v)
        if (v.Tip == nil) then
            local txt = v.Name
            if (v.Hotkey ~= nil) then
                txt = txt .. "[" .. hcolor.mixed(v.Hotkey, F6_CONF.color.hotKey) .. "]"
            end
            local _lv = v._lv or "等级"
            if (v.levels > 1) then
                v.Tip = {}
                for i = 1, v.levels do
                    table.insert(v.Tip, txt .. " - [|cffffcc00" .. _lv .. " " .. i .. "|r]")
                end
            else
                v.Tip = txt
            end
        end
    end,
    ubertip = function(v)
        if (v.Ubertip == nil) then
            v.Ubertip = { "" }
        elseif (type(v.Ubertip) == "string") then
            v.Ubertip = { v.Ubertip }
        end
        if (v.levels > 1 and #v.Ubertip < v.levels) then
            local lastUbertip = v.Ubertip[#v.Ubertip]
            for i = (#v.Ubertip + 1), v.levels, 1 do
                v.Ubertip[i] = lastUbertip
            end
        end
        local ux = {}
        for i = 1, v.levels, 1 do
            ux[i] = { v.Ubertip[i] }
        end
        if (type(v.Cool) == "table") then
            local lastCool = v.Cool[#v.Cool]
            for i = (#v.Cool + 1), v.levels, 1 do
                v.Cool[i] = lastCool
            end
            for i = 1, v.levels, 1 do
                table.insert(ux[i], hcolor.mixed("冷却：" .. v.Cool[i] .. "秒", F6_CONF.color.abilityCoolDown))
            end
        end
        if (v._attr ~= nil) then
            if (#v._attr == 0) then
                v._attr = { v._attr }
            end
            local lastAttr = v._attr[#v._attr]
            for i = (#v._attr + 1), v.levels, 1 do
                v._attr[i] = lastAttr
            end
            for i = 1, v.levels, 1 do
                table.insert(ux[i], hcolor.mixed(F6S.a.attr(v._attr[i], "|n"), F6_CONF.color.abilityAttr))
            end
        end
        if (v._ring ~= nil) then
            if (#v._ring == 0) then
                v._ring = { v._ring }
            end
            local lastRing = v._ring[#v._ring]
            for i = (#v._ring + 1), v.levels, 1 do
                v._ring[i] = lastRing
            end
            for i = 1, v.levels, 1 do
                local d = {}
                if (v._ring[i].radius ~= nil) then
                    table.insert(d, hcolor.mixed("光环范围：" .. v._ring[i].radius, F6_CONF.color.ringArea))
                end
                if (type(v._ring[i].target) == 'table' and #v._ring[i].target > 0) then
                    local labels = {}
                    for _, t in ipairs(v._ring[i].target) do
                        table.insert(labels, CONST_TARGET_LABEL[t])
                    end
                    table.insert(d, hcolor.mixed("光环目标：" .. string.implode(',', labels), F6_CONF.color.ringTarget))
                    labels = nil
                end
                if (v._ring[i].attr ~= nil) then
                    table.insert(d, hcolor.mixed("光环效果：|n" .. F6S.a.attr(v._ring[i].attr, "|n", ' - '), F6_CONF.color.ringTarget))
                end
                if (#d > 0) then
                    table.insert(ux[i], string.implode("|n", d))
                end
            end
        end
        if (v._remarks ~= nil and v._remarks ~= "") then
            for i = 1, v.levels, 1 do
                table.insert(ux[i], hcolor.mixed(v._remarks, F6_CONF.color.abilityRemarks))
            end
        end
        for i = 1, v.levels, 1 do
            v.Ubertip[i] = string.implode("|n", ux[i])
        end
        if (#v.Ubertip == 1) then
            v.Ubertip = v.Ubertip[1]
        end
    end,
}

F6S.i = {
    description = {
        _attr = function(v)
            if (v._attr ~= nil) then
                F6S.txt(v, "Description", F6S.a.attr(v._attr, ","), ';')
            end
        end,
        _overlie = function(v)
            if (v._overlie ~= nil and v._overlie > 0) then
                local o = tostring(math.floor(v._overlie))
                F6S.txt(v, "Description", "叠加：" .. o, ';')
            end
        end,
        _weight = function(v)
            if (v._weight ~= nil) then
                local w = tostring(math.round(v._weight))
                F6S.txt(v, "Description", "重量：" .. w .. "Kg", ';')
            end
        end,
        _remarks = function(v)
            if (v._remarks ~= nil and v._remarks ~= "") then
                F6S.txt(v, "Description", v._remarks, ';')
            end
        end,
    },
    ubertip = {
        _cooldown = function(v)
            if (v._cooldown ~= nil and v._cooldown > 0) then
                F6S.txt(v, "Ubertip", hcolor.mixed("冷却：" .. v._cooldown .. "秒", F6_CONF.color.itemCoolDown))
            end
        end,
        _ring = function(v)
            if (v._ring ~= nil) then
                if (v._ring.attr ~= nil and v._ring.radius ~= nil and (type(v._ring.target) == 'table' and #v._ring.target > 0)) then
                    local txt = "光环：[" .. v._ring.radius .. "px]|n"
                    F6S.txt(v, "Ubertip", hcolor.mixed(txt .. F6S.a.attr(v._ring.attr, "|n", ' - '), F6_CONF.color.ringTarget))
                end
            end
        end,
        _attr = function(v)
            if (v._attr ~= nil) then
                F6S.txt(v, "Ubertip", hcolor.mixed(F6S.a.attr(v._attr, "|n"), F6_CONF.color.itemAttr))
            end
        end,
        _fragment = function(v)
            if (F6V_I_SYNTHESIS_TMP.fragment[v.Name] ~= nil and #F6V_I_SYNTHESIS_TMP.fragment[v.Name] > 0) then
                local txt = "可以合成：" .. string.implode('、', F6V_I_SYNTHESIS_TMP.fragment[v.Name])
                F6S.txt(v, "Ubertip", hcolor.mixed(txt, F6_CONF.color.itemFragment))
            end
        end,
        _profit = function(v)
            if (F6V_I_SYNTHESIS_TMP.profit[v.Name] ~= nil) then
                local txt = "需要零件：" .. F6V_I_SYNTHESIS_TMP.profit[v.Name]
                F6S.txt(v, "Ubertip", hcolor.mixed(txt, F6_CONF.color.itemProfit))
            end
        end,
        _overlie = function(v)
            if (v._overlie ~= nil and v._overlie > 0) then
                local o = tostring(math.floor(v._overlie))
                F6S.txt(v, "Ubertip", hcolor.mixed("叠加：" .. o, F6_CONF.color.itemOverlie))
            end
        end,
        _weight = function(v)
            if (v._weight ~= nil) then
                local w = tostring(math.round(v._weight))
                F6S.txt(v, "Ubertip", hcolor.mixed("重量：" .. w .. "Kg", F6_CONF.color.itemWeight))
            end
        end,
        _remarks = function(v)
            if (v._remarks ~= nil and v._remarks ~= "") then
                F6S.txt(v, "Ubertip", hcolor.mixed(v._remarks, F6_CONF.color.itemRemarks))
            end
        end,
    },
}
F6S.u = {}

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------@private
F6V_I_SYNTHESIS = function(formula)
    F6V_I_SYNTHESIS_TMP.fragment = {}
    F6V_I_SYNTHESIS_TMP.profit = {}
    for _, v in ipairs(formula) do
        local profit = ''
        local fragment = {}
        if (type(v) == 'string') then
            local f1 = string.explode('=', v)
            if (string.strpos(f1[1], 'x') == false) then
                profit = { f1[1], 1 }
            else
                local temp = string.explode('x', f1[1])
                temp[2] = math.floor(temp[2])
                profit = temp
            end
            local f2 = string.explode('+', f1[2])
            for _, vv in ipairs(f2) do
                if (string.strpos(vv, 'x') == false) then
                    table.insert(fragment, { vv, 1 })
                else
                    local temp = string.explode('x', vv)
                    temp[2] = math.floor(tonumber(temp[2]))
                    table.insert(fragment, temp)
                end
            end
        elseif (type(v) == 'table') then
            profit = v[1]
            for vi = 2, table.len(v), 1 do
                table.insert(fragment, v[vi])
            end
        end
        --
        local fmStr = {}
        for _, fm in ipairs(fragment) do
            if (fm[2] <= 1) then
                table.insert(fmStr, fm[1])
            else
                table.insert(fmStr, fm[1] .. 'x' .. fm[2])
            end
            if (F6V_I_SYNTHESIS_TMP.fragment[fm[1]] == nil) then
                F6V_I_SYNTHESIS_TMP.fragment[fm[1]] = {}
            end
            if (table.includes(F6V_I_SYNTHESIS_TMP.fragment[fm[1]], profit[1]) == false) then
                table.insert(F6V_I_SYNTHESIS_TMP.fragment[fm[1]], profit[1])
            end
        end
        F6V_I_SYNTHESIS_TMP.profit[profit[1]] = string.implode('+', fmStr)
    end
end

local F6_RING_SINGLE = function(_r)
    _r.effect = _r.effect or nil
    _r.effectTarget = _r.effectTarget or "Abilities\\Spells\\Other\\GeneralAuraTarget\\GeneralAuraTarget.mdl"
    _r.attach = _r.attach or "origin"
    _r.attachTarget = _r.attachTarget or "origin"
    _r.radius = _r.radius or 600
    -- target请参考物编的目标允许
    local target
    if (type(_r.target) == 'table' and #_r.target > 0) then
        target = _r.target
    elseif (type(_r.target) == 'string' and string.len(_r.target) > 0) then
        target = string.explode(',', _r.target)
    else
        target = { 'air', 'ground', 'friend', 'self', 'vuln', 'invu' }
    end
    _r.target = target
end
local F6_RING = function(_v)
    if (type(_v._ring) == "table") then
        if (#_v._ring == 0) then
            F6_RING_SINGLE(_v._ring)
        else
            for i = 1, #_v._ring, 1 do
                F6_RING_SINGLE(_v._ring[i])
            end
        end
    end
end

local F6_HERO = function(_v)
    _v.Primary = _v.Primary or "STR"
    _v.weapTp1 = _v.weapTp1 or "normal"
    _v.cool1 = _v.cool1 or 2
    _v.dmgplus1 = _v.dmgplus1 or 10
    _v.rangeN1 = _v.rangeN1 or 100
    _v.STR = _v.STR or 10
    _v.AGI = _v.AGI or 10
    _v.INT = _v.INT or 10
    _v.STRplus = _v.STRplus or 1
    _v.AGIplus = _v.AGIplus or 1
    _v.INTplus = _v.INTplus or 1
    _v.spd = _v.spd or 300
    local Ubertip
    if (_v.Ubertip == nil or _v.Ubertip == "") then
        Ubertip = ""
    else
        Ubertip = _v.Ubertip .. "|n"
    end
    Ubertip = Ubertip .. hcolor.mixed("攻击类型：" .. CONST_WEAPON_TYPE[_v.weapTp1].label .. "(" .. _v.cool1 .. "秒/击)", F6_CONF.color.heroWeapon)
    Ubertip = Ubertip .. "|n" .. hcolor.mixed("基础攻击：" .. _v.dmgplus1, F6_CONF.color.heroAttack)
    Ubertip = Ubertip .. "|n" .. hcolor.mixed("攻击范围：" .. _v.rangeN1, F6_CONF.color.heroRange)
    if (_v.Primary == "STR") then
        Ubertip = Ubertip .. "|n" .. hcolor.mixed("力量：" .. _v.STR .. "(+" .. _v.STRplus .. ")", F6_CONF.color.heroPrimary)
    else
        Ubertip = Ubertip .. "|n" .. hcolor.mixed("力量：" .. _v.STR .. "(+" .. _v.STRplus .. ")", F6_CONF.color.heroSecondary)
    end
    if (_v.Primary == "AGI") then
        Ubertip = Ubertip .. "|n" .. hcolor.mixed("敏捷：" .. _v.AGI .. "(+" .. _v.AGIplus .. ")", F6_CONF.color.heroPrimary)
    else
        Ubertip = Ubertip .. "|n" .. hcolor.mixed("敏捷：" .. _v.AGI .. "(+" .. _v.AGIplus .. ")", F6_CONF.color.heroSecondary)
    end
    if (_v.Primary == "INT") then
        Ubertip = Ubertip .. "|n" .. hcolor.mixed("智力：" .. _v.INT .. "(+" .. _v.INTplus .. ")", F6_CONF.color.heroPrimary)
    else
        Ubertip = Ubertip .. "|n" .. hcolor.mixed("智力：" .. _v.INT .. "(+" .. _v.INTplus .. ")", F6_CONF.color.heroSecondary)
    end
    Ubertip = Ubertip .. "|n" .. hcolor.mixed("移动：" .. _v.spd .. " " .. CONST_MOVE_TYPE[_v.movetp].label, F6_CONF.color.heroMove)
    _v.Ubertip = Ubertip
end

F6V_A = function(_v)
    _v._class = "ability"
    _v._type = _v._type or "common"
    if (_v._parent == nil) then
        _v._parent = "ANcl"
    end
    if (_v.Name == nil) then
        if (_v._type == "empty") then
            _v.Name = F6_NAME("未命名空被动")
        elseif (_v._type == "ring") then
            _v.Name = F6_NAME("未命名空光环")
        else
            _v.Name = F6_NAME("未命名技能")
        end
    end
    if (_v.levels == nil) then
        _v.levels = 1
    end
    if (_v.Hotkey ~= nil) then
        _v.Buttonpos_1 = _v.Buttonpos_1 or CONST_HOTKEY_ABILITY_KV[_v.Hotkey].Buttonpos_1 or 0
        _v.Buttonpos_2 = _v.Buttonpos_2 or CONST_HOTKEY_ABILITY_KV[_v.Hotkey].Buttonpos_2 or 0
    end
    -- 处理 _ring光环
    F6_RING(_v)
    F6S.a.tip(_v)
    F6S.a.ubertip(_v)
    return _v
end

F6V_U = function(_v)
    _v._class = "unit"
    _v._type = _v._type or "common"
    if (_v._parent == nil) then
        _v._parent = "nban"
    end
    if (_v.Name == nil) then
        if (_v._type == "hero") then
            _v.Name = F6_NAME("未命名英雄")
        elseif (_v._type == "ring") then
            _v.Name = F6_NAME("未命名空光环")
        else
            _v.Name = F6_NAME("未命名单位")
        end
    end
    if (_v._type == "hero") then
        F6_HERO(_v)
    end
    if (_v.Hotkey ~= nil) then
        _v.Buttonpos_1 = _v.Buttonpos_1 or CONST_HOTKEY_FULL_KV[_v.Hotkey].Buttonpos_1 or 0
        _v.Buttonpos_2 = _v.Buttonpos_2 or CONST_HOTKEY_FULL_KV[_v.Hotkey].Buttonpos_2 or 0
        _v.Tip = "选择：" .. _v.Name .. "(" .. hcolor.mixed(_v.Hotkey, F6_CONF.color.hotKey) .. ")"
    else
        _v.Buttonpos_1 = _v.Buttonpos_1 or 0
        _v.Buttonpos_2 = _v.Buttonpos_2 or 0
        _v.Tip = "选择：" .. _v.Name
    end
    _v.goldcost = _v.goldcost or 0
    _v.lumbercost = _v.lumbercost or 0
    _v.fmade = _v.fmade or 0
    _v.fused = _v.fused or 0
    local targs1 = _v.targs1 or "vulnerable,ground,ward,structure,organic,mechanical,debris,air" --攻击目标
    if (_v.weapTp1 ~= nil) then
        if (_v.weapTp1 ~= "normal") then
            _v.weapType1 = "" --攻击声音
            _v.Missileart_1 = _v.Missileart_1 -- 箭矢模型
            _v.Missilespeed_1 = _v.Missilespeed_1 or 900 -- 箭矢速度
            _v.Missilearc_1 = _v.Missilearc_1 or 0.10
        end
        if (_v.weapTp1 == "normal") then
            _v.weapType1 = _v.weapType1 or "" --攻击声音
            _v.Missileart_1 = ""
            _v.Missilespeed_1 = 0
            _v.Missilearc_1 = 0
        elseif (_v.weapTp1 == "msplash" or _v.weapTp1 == "artillery") then
            --溅射/炮火
            _v.Farea1 = _v.Farea1 or 1
            _v.Qfact1 = _v.Qfact1 or 0.05
            _v.Qarea1 = _v.Qarea1 or 500
            _v.Hfact1 = _v.Hfact1 or 0.15
            _v.Harea1 = _v.Harea1 or 350
            _v.splashTargs1 = targs1 .. ",enemies"
        elseif (_v.weapTp1 == "mbounce") then
            --弹射
            _v.Farea1 = _v.Farea1 or 450
            _v.targCount1 = _v.targCount1 or 4
            _v.damageLoss1 = _v.damageLoss1 or 0.3
            _v.splashTargs1 = targs1 .. ",enemies"
        elseif (_v.weapTp1 == "mline") then
            --穿透
            _v.spillRadius1 = _v.spillRadius1 or 300
            _v.spillDist1 = _v.spillDist1 or 450
            _v.damageLoss1 = _v.damageLoss1 or 0.3
            _v.splashTargs1 = targs1 .. ",enemies"
        elseif (_v.weapTp1 == "aline") then
            --炮火穿透
            _v.Farea1 = _v.Farea1 or 1
            _v.Qfact1 = _v.Qfact1 or 0.05
            _v.Qarea1 = _v.Qarea1 or 500
            _v.Hfact1 = _v.Hfact1 or 0.15
            _v.Harea1 = _v.Harea1 or 350
            _v.spillRadius1 = _v.spillRadius1 or 300
            _v.spillDist1 = _v.spillDist1 or 450
            _v.damageLoss1 = _v.damageLoss1 or 0.3
            _v.splashTargs1 = targs1 .. ",enemies"
        end
    end
    local targs2 = _v.targs2 or "vulnerable,ground,ward,structure,organic,mechanical,debris,air" --攻击目标
    if (_v.weapTp2 ~= nil) then
        if (_v.weapTp2 ~= "normal") then
            _v.weapType2 = "" --攻击声音
            _v.Missileart_2 = _v.Missileart_2 -- 箭矢模型
            _v.Missilespeed_2 = _v.Missilespeed_2 or 900 -- 箭矢速度
            _v.Missilearc_2 = _v.Missilearc_2 or 0.10
        end
        if (_v.weapTp2 == "normal") then
            _v.weapType2 = _v.weapType2 or "" --攻击声音
            _v.Missileart_2 = ""
            _v.Missilespeed_2 = 0
            _v.Missilearc_2 = 0
        elseif (_v.weapTp2 == "msplash" or _v.weapTp2 == "artillery") then
            --溅射/炮火
            _v.Farea2 = _v.Farea2 or 1
            _v.Qfact2 = _v.Qfact2 or 0.05
            _v.Qarea2 = _v.Qarea2 or 500
            _v.Hfact2 = _v.Hfact2 or 0.15
            _v.Harea2 = _v.Harea2 or 350
            _v.splashTargs2 = targs2 .. ",enemies"
        elseif (_v.weapTp2 == "mbounce") then
            --弹射
            _v.Farea2 = _v.Farea2 or 450
            _v.targCount2 = _v.targCount2 or 4
            _v.damageLoss2 = _v.damageLoss2 or 0.3
            _v.splashTargs2 = targs2 .. ",enemies"
        elseif (_v.weapTp2 == "mline") then
            --穿透
            _v.spillRadius2 = _v.spillRadius2 or 300
            _v.spillDist2 = _v.spillDist2 or 450
            _v.damageLoss2 = _v.damageLoss2 or 0.3
            _v.splashTargs2 = targs2 .. ",enemies"
        elseif (_v.weapTp2 == "aline") then
            --炮火穿透
            _v.Farea2 = _v.Farea2 or 1
            _v.Qfact2 = _v.Qfact2 or 0.05
            _v.Qarea2 = _v.Qarea2 or 500
            _v.Hfact2 = _v.Hfact2 or 0.15
            _v.Harea2 = _v.Harea2 or 350
            _v.spillRadius2 = _v.spillRadius2 or 300
            _v.spillDist2 = _v.spillDist2 or 450
            _v.damageLoss2 = _v.damageLoss2 or 0.3
            _v.splashTargs2 = targs2 .. ",enemies"
        end
    end
    if (_v.Propernames ~= nil) then
        _v.nameCount = #string.explode(',', _v.Propernames)
    end
    return _v
end

local courier_skill_ids
F6V_COURIER_SKILL = function()
    if (courier_skill_ids == nil) then
        courier_skill_ids = { "AInv", "Avul" }
        local Name = "信使-闪烁"
        local tmp = {
            _parent = "AEbl",
            _type = "courier",
            Name = Name,
            Ubertip = F6_CONF.courierSkill.blink.Ubertip,
            Hotkey = F6_CONF.courierSkill.blink.Hotkey,
            Buttonpos_1 = F6_CONF.courierSkill.blink.Buttonpos_1,
            Buttonpos_2 = F6_CONF.courierSkill.blink.Buttonpos_2,
            hero = 0,
            levels = 1,
            Art = F6_CONF.courierSkill.blink.Art,
            SpecialArt = "Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl",
            Areaeffectart = "Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl",
            race = "other",
            DataA = { 99999 },
            DataB = { 0 },
            Cool = { F6_CONF.courierSkill.blink.Cool1 },
            Cost = { 0 },
        }
        table.insert(courier_skill_ids, hslk_ability(tmp)._id)
        Name = "信使-拾取"
        tmp = {
            _parent = "ANcl",
            _type = "courier",
            Name = Name,
            Tip = Name .. "(" .. hcolor.mixed(F6_CONF.courierSkill.rangePickUp.Hotkey, F6_CONF.color.hotKey) .. ")",
            Order = "manaburn",
            Hotkey = F6_CONF.courierSkill.rangePickUp.Hotkey,
            Ubertip = F6_CONF.courierSkill.rangePickUp.Ubertip,
            Buttonpos_1 = F6_CONF.courierSkill.rangePickUp.Buttonpos_1,
            Buttonpos_2 = F6_CONF.courierSkill.rangePickUp.Buttonpos_2,
            hero = 0,
            levels = 1,
            Art = F6_CONF.courierSkill.rangePickUp.Art,
            CasterArt = "",
            EffectArt = "",
            TargetArt = "",
            race = "other",
            DataA = { 0 },
            DataB = { 0 },
            DataC = { 1 },
            DataD = { 0.01 },
            DataF = { "manaburn" },
            Cool = { F6_CONF.courierSkill.rangePickUp.Cool1 },
            Cost = { 0 },
        }
        table.insert(courier_skill_ids, hslk_ability(tmp)._id)
        Name = "信使-拆分物品"
        tmp = {
            _parent = "ANtm",
            _type = "courier",
            Name = Name,
            Tip = Name .. "(" .. hcolor.mixed(F6_CONF.courierSkill.separate.Hotkey, F6_CONF.color.hotKey) .. ")",
            Ubertip = F6_CONF.courierSkill.separate.Ubertip,
            Art = F6_CONF.courierSkill.separate.Art,
            Hotkey = F6_CONF.courierSkill.separate.Hotkey,
            Buttonpos_1 = F6_CONF.courierSkill.separate.Buttonpos_1,
            Buttonpos_2 = F6_CONF.courierSkill.separate.Buttonpos_2,
            Missileart = "",
            Missilespeed = 99999,
            Missilearc = 0.00,
            Animnames = "",
            hero = 0,
            race = "other",
            DataD = { 0 },
            DataA = { 0 },
            BuffID = { "" },
            Cool = { F6_CONF.courierSkill.separate.Cool1 },
            targs = { "item,nonhero" },
            Cost = { 0 },
            Rng = { 200.00 },
        }
        table.insert(courier_skill_ids, hslk_ability(tmp)._id)
        Name = "信使-传递"
        tmp = {
            _parent = "ANcl",
            _type = "courier",
            Name = Name,
            Tip = Name .. Name .. "(" .. hcolor.mixed(F6_CONF.courierSkill.deliver.Hotkey, F6_CONF.color.hotKey) .. ")",
            Order = "polymorph",
            Hotkey = F6_CONF.courierSkill.deliver.Hotkey,
            Ubertip = F6_CONF.courierSkill.deliver.Ubertip,
            Buttonpos_1 = F6_CONF.courierSkill.deliver.Buttonpos_1,
            Buttonpos_2 = F6_CONF.courierSkill.deliver.Buttonpos_2,
            hero = 0,
            levels = 1,
            Art = F6_CONF.courierSkill.deliver.Art,
            CasterArt = "",
            EffectArt = "",
            TargetArt = "",
            race = "other",
            DataA = { 0 },
            DataB = { 0 },
            DataC = { 1 },
            DataD = { 0.01 },
            DataF = { "polymorph" },
            Cool = { F6_CONF.courierSkill.deliver.Cool1 },
            Cost = { 0 },
        }
        table.insert(courier_skill_ids, hslk_ability(tmp)._id)
        courier_skill_ids = string.implode(",", courier_skill_ids)
    end
    return courier_skill_ids
end

F6V_I_CD = function(_v)
    if (_v._cooldown < 0) then
        _v._cooldown = 0
    end
    local adTips = "H_LUA_ICD_" .. _v.Name
    local cdID
    local ad = {
        Effectsound = "",
        Name = adTips,
        Tip = adTips,
        Ubertip = adTips,
        TargetArt = _v.TargetArt or "",
        Targetattach = _v.Targetattach or "",
        Animnames = _v.Animnames or "spell",
        CasterArt = _v.CasterArt or "",
        Art = "",
        item = 1,
        Requires = "",
        Hotkey = "",
        Buttonpos_1 = 0,
        Buttonpos_2 = 0,
        race = "other",
        Cast = { _v._cast or 0 },
        Cost = { _v._cost or 0 },
        Cool = { _v._cooldown },
    }
    if (_v._cooldownTarget == CONST_ABILITY_TARGET.location.value) then
        -- 对点（模版：照明弹）
        ad._parent = "Afla"
        ad.DataA = { 0 }
        ad.EfctID = { "" }
        ad.Dur = { 0.01 }
        ad.HeroDur = { 0.01 }
        ad.Rng = _v.Rng or { 600 }
        ad.Area = { 0 }
        ad.DataA = { 0 }
        ad.DataB = { 0 }
        local av = hslk_ability(ad)
        cdID = av._id
    elseif (_v.cooldownTarget == CONST_ABILITY_TARGET.range.value) then
        -- 对点范围（模版：暴风雪）
        ad._parent = "ACbz"
        ad.BuffID = { "" }
        ad.EfctID = { "" }
        ad.Rng = _v.Rng or { 300 }
        ad.Area = _v.Area or { 300 }
        ad.DataA = { 0 }
        ad.DataB = { 0 }
        ad.DataC = { 0 }
        ad.DataD = { 0 }
        ad.DataE = { 0 }
        ad.DataF = { 0 }
        local av = hslk_ability(ad)
        cdID = av._id
    elseif (_v._cooldownTarget == CONST_ABILITY_TARGET.unit.value) then
        -- 对单位（模版：霹雳闪电）
        ad._parent = "ACfb"
        ad.Missileart = _v.Missileart or "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
        ad.Missilespeed = _v.Missilespeed or 1000
        ad.Missilearc = _v.Missilearc or 0
        ad.targs = _v.targs or { "air,ground,organic,enemy,neutral" }
        ad.Rng = _v.Rng or { 800 }
        ad.Area = _v.Area or { 0 }
        ad.DataA = { 0 }
        ad.Dur = { 0.01 }
        ad.HeroDur = { 0.01 }
        local av = hslk_ability(ad)
        cdID = av._id
    else
        -- 立刻（模版：金箱子）
        ad._parent = "AIgo"
        ad.DataA = { 0 }
        local av = hslk_ability(ad)
        cdID = av._id
    end
    return cdID
end

F6V_I_SHADOW = function(_v)
    _v._parent = "gold"
    _v._class = "item"
    _v._type = "shadow"
    _v.Name = "　" .. _v.Name .. "　"
    _v.class = "Charged"
    _v.abilList = ""
    _v.cooldownID = "AIat"
    _v.ignoreCD = 1
    _v.perishable = 1
    _v.usable = 1
    _v.powerup = 1
    return _v
end

F6V_I = function(_v)
    _v._class = "item"
    _v._type = _v._type or "common"
    if (_v._cooldown ~= nil) then
        local cd = F6V_I_CD(_v)
        _v.abilList = cd
        _v.cooldownID = cd
        _v.usable = 1
        if (_v.powerup == 1) then
            _v.class = "PowerUp"
        elseif (_v.perishable == 1) then
            _v.class = "Charged"
        end
    end
    if (_v._parent == nil) then
        if (_v.class == "Charged") then
            _v._parent = "hlst"
        elseif (_v.class == "PowerUp") then
            _v._parent = "gold"
        else
            _v._parent = "rat9"
        end
    end
    if (_v.Name == nil) then
        _v.Name = F6_NAME("未命名物品")
    end
    if (_v.file == nil) then
        if (_v.class == "PowerUp") then
            _v.file = "Objects\\InventoryItems\\tomeRed\\tomeRed.mdl"
        else
            _v.file = "Objects\\InventoryItems\\TreasureChest\\treasurechest.mdl"
        end
    end
    -- 处理 _shadow
    if (type(_v._shadow) ~= 'boolean') then
        _v._shadow = false
    end
    -- 处理 _ring光环
    F6_RING(_v)
    -- 处理文本
    F6S.i.description._attr(_v)
    F6S.i.description._overlie(_v)
    F6S.i.description._weight(_v)
    F6S.i.description._remarks(_v)
    F6S.i.ubertip._cooldown(_v)
    F6S.i.ubertip._ring(_v)
    F6S.i.ubertip._attr(_v)
    F6S.i.ubertip._fragment(_v)
    F6S.i.ubertip._profit(_v)
    F6S.i.ubertip._overlie(_v)
    F6S.i.ubertip._weight(_v)
    F6S.i.ubertip._remarks(_v)
    if (_v.uses == nil) then
        _v.uses = 1
    end
    if (_v._overlie == nil or _v._overlie < _v.uses) then
        _v._overlie = _v.uses
    end
    if (_v.goldcost == nil) then
        _v.goldcost = 1000000
    end
    if (_v.lumbercost == nil) then
        _v.lumbercost = 0
    end
    if (_v.Level == nil) then
        _v.Level = math.floor((_v.goldcost + _v.lumbercost) / 500)
    end
    if (_v.oldLevel == nil) then
        _v.oldLevel = _v.Level
    end
    if (_v.Hotkey ~= nil) then
        _v.Buttonpos_1 = _v.Buttonpos_1 or CONST_HOTKEY_FULL_KV[_v.Hotkey].Buttonpos_1 or 0
        _v.Buttonpos_2 = _v.Buttonpos_2 or CONST_HOTKEY_FULL_KV[_v.Hotkey].Buttonpos_2 or 0
        _v.Tip = "获得" .. _v.Name .. "(" .. hcolor.mixed(_v.Hotkey, F6_CONF.color.hotKey) .. ")"
    else
        _v.Buttonpos_1 = _v.Buttonpos_1 or 0
        _v.Buttonpos_2 = _v.Buttonpos_2 or 0
        _v.Tip = "获得" .. _v.Name
    end
    return _v
end

F6V_B = function(_v)
    _v._class = "buff"
    _v._type = _v._type or "common"
    if (_v.Name == nil) then
        _v.Name = F6_NAME("未命名魔法效果")
    end
    return _v
end

F6V_UP = function(_v)
    _v._class = "upgrade"
    _v._type = _v._type or "common"
    if (_v.Name == nil) then
        _v.Name = F6_NAME("未命名科技")
    end
    return _v
end