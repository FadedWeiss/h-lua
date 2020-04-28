--- 框架默认事件动作
--- default event actions
hevent_default_actions = {
    player = {
        esc = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetTriggerPlayer(),
                CONST_EVENT.esc,
                {
                    triggerPlayer = cj.GetTriggerPlayer()
                }
            )
        end),
        deSelection = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetTriggerPlayer(),
                CONST_EVENT.deSelection,
                {
                    triggerPlayer = cj.GetTriggerPlayer(),
                    triggerUnit = cj.GetTriggerUnit()
                }
            )
        end),
        constructStart = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetOwningPlayer(cj.GetTriggerUnit()),
                CONST_EVENT.constructStart,
                {
                    triggerUnit = cj.GetTriggerUnit()
                }
            )
        end),
        constructCancel = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetOwningPlayer(cj.GetTriggerUnit()),
                CONST_EVENT.constructCancel,
                {
                    triggerUnit = cj.GetCancelledStructure()
                }
            )
        end),
        constructFinish = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetOwningPlayer(cj.GetTriggerUnit()),
                CONST_EVENT.constructFinish,
                {
                    triggerUnit = cj.GetConstructedStructure()
                }
            )
        end),
        apm = cj.Condition(function()
            local p = cj.GetOwningPlayer(cj.GetTriggerUnit())
            if (his.playing(p) == true and his.playerSite(p) == true and his.computer(p) == false) then
                hplayer.set(p, "apm", hplayer.get(p, "apm", 0) + 1)
            end
        end),
        command = function()
            local p = cj.GetTriggerPlayer()
            local str = cj.GetEventPlayerChatString()
            if (str == "-apc") then
                if (his.autoConvertGoldToLumber(p) == true) then
                    his.set(p, "isAutoConvertGoldToLumber", false)
                    echo("|cffffcc00已关闭|r自动换算", p)
                else
                    his.set(p, "isAutoConvertGoldToLumber", true)
                    echo("|cffffcc00已开启|r自动换算", p)
                end
            elseif (str == "-apm") then
                echo("您的apm为:" .. hplayer.getApm(p), p)
            elseif (str == "-eff") then
                if (hplayer.qty_current == 1) then
                    if (heffect.enable == true) then
                        heffect.enable = false
                        hlightning.enable = false
                        echo("|cffffcc00已关闭|r大部分特效", p)
                    else
                        heffect.enable = true
                        hlightning.enable = true
                        echo("|cffffcc00已开启|r大部分特效", p)
                    end
                else
                    echo("此命令仅在单人时有效", p)
                end
            elseif (str == "-random") then
                local tp = cj.GetTriggerPlayer()
                if (#hhero.randomSelectorPool <= 0) then
                    echo("此命令仅在存有英雄选择操作时有效", tp)
                    return
                end
                if (#hhero.player_heroes[tp] >= hhero.player_allow_qty[tp]) then
                    echo("|cffffff80你已经选够了|r", tp)
                    return
                end
                local txt = ""
                local qty = 0
                while (true) do
                    local one = table.random(hhero.randomSelectorPool)
                    table.delete(one, hhero.randomSelectorPool)
                    local u = one
                    if (type(one) == 'string') then
                        u = hunit.create(
                            {
                                whichPlayer = tp,
                                unitId = one,
                                x = hhero.bornX,
                                y = hhero.bornY
                            }
                        )
                        hRuntime.hero[u] = {
                            selectorFrom = "tavern",
                        }
                    else
                        hunit.setInvulnerable(hero, false)
                        cj.SetUnitOwner(hero, whichPlayer, true)
                        cj.SetUnitPosition(whichPlayer, hhero.bornX, hhero.bornY)
                        cj.PauseUnit(whichPlayer, false)
                    end
                    hhero.setIsHero(u, true)
                    table.insert(hhero.player_heroes[tp], u)
                    -- 触发英雄被选择事件(全局)
                    hevent.triggerEvent(
                        "global",
                        CONST_EVENT.pickHero,
                        {
                            triggerPlayer = tp,
                            triggerUnit = u
                        }
                    )
                    txt = txt .. " " .. cj.GetUnitName(u)
                    qty = qty + 1
                    if (#hhero.player_heroes[tp] >= hhero.player_allow_qty[tp]) then
                        break
                    end
                end
                echo("已为您 |cffffff80random|r 挑选了 " .. "|cffffff80" .. math.floor(qty) .. "|r 个：|cffffff80" .. txt .. "|r", tp)
            elseif (str == "-repick") then
                local tp = cj.GetTriggerPlayer()
                if (#hhero.randomSelectorPool <= 0) then
                    echo("此命令仅在存有英雄选择操作时有效", tp)
                    return
                end
                if (#hhero.player_heroes[tp] <= 0) then
                    echo("|cffffff80你还没有选过任何单位|r", p)
                    return
                end
                local qty = #hhero.player_heroes
                for _, u in ipairs(hhero.player_heroes[p]) do
                    if (type(hRuntime.hero[u].selector) == "userdata") then
                        table.insert(hhero.randomSelectorPool, hunit.getId(u))
                        cj.AddUnitToStock(tavern, cj.GetUnitTypeId(u), 1, 1)
                    else
                        local new = hunit.create(
                            {
                                whichPlayer = cj.Player(PLAYER_NEUTRAL_PASSIVE),
                                unitId = heroId,
                                x = hRuntime.hero[u].selector[1],
                                y = hRuntime.hero[u].selector[2],
                                isInvulnerable = true,
                                isPause = true
                            }
                        )
                        hRuntime.hero[new] = {
                            selector = { hRuntime.hero[u].selector[1], hRuntime.hero[u].selector[2] },
                        }
                        table.insert(hhero.selectorClearPool, new)
                        table.insert(hhero.randomSelectorPool, new)
                    end
                    hunit.del(u, 0)
                end
                hhero.player_heroes[p] = {}
                echo("已为您 |cffffff80repick|r 了 " .. "|cffffff80" .. qty .. "|r 个单位", p)
            else
                local first = string.sub(str, 1, 1)
                if (first == "+" or first == "-") then
                    --视距
                    local v = string.sub(str, 2, string.len(str))
                    v = tonumber(v)
                    if (v == nil) then
                        return
                    else
                        local val = math.abs(v)
                        if (first == "+") then
                            hcamera.changeDistance(p, val)
                        elseif (first == "-") then
                            hcamera.changeDistance(p, -val)
                        end
                    end
                end
            end
        end,
        leave = cj.Condition(function()
            local p = cj.GetTriggerPlayer()
            hplayer.set(p, "status", hplayer.player_status.leave)
            echo(cj.GetPlayerName(p) .. "离开了游戏～")
            hplayer.clearUnit(p)
            hplayer.qty_current = hplayer.qty_current - 1
            -- 触发玩家离开事件(全局)
            hevent.triggerEvent(
                "global",
                CONST_EVENT.playerLeave,
                {
                    triggerPlayer = p
                }
            )
        end),
    },
    unit = {
        attackDetect = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetTriggerUnit(),
                CONST_EVENT.attackDetect,
                {
                    triggerUnit = cj.GetTriggerUnit(),
                    targetUnit = cj.GetEventTargetUnit()
                }
            )
        end),
        attackGetTarget = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetTriggerUnit(),
                CONST_EVENT.attackGetTarget,
                {
                    triggerUnit = cj.GetTriggerUnit(),
                    targetUnit = cj.GetEventTargetUnit()
                }
            )
        end),
        beAttackReady = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetTriggerUnit(),
                CONST_EVENT.beAttackReady,
                {
                    triggerUnit = cj.GetTriggerUnit(),
                    targetUnit = cj.GetAttacker(),
                    attacker = cj.GetAttacker()
                }
            )
        end),
        skillStudy = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetTriggerUnit(),
                CONST_EVENT.skillStudy,
                {
                    triggerUnit = cj.GetTriggerUnit(),
                    triggerSkill = cj.GetLearnedSkill()
                }
            )
        end),
        skillReady = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetTriggerUnit(),
                CONST_EVENT.skillReady,
                {
                    triggerUnit = cj.GetTriggerUnit(),
                    triggerSkill = cj.GetSpellAbilityId(),
                    targetUnit = cj.GetSpellTargetUnit(),
                    targetLoc = cj.GetSpellTargetLoc()
                }
            )
        end),
        skillCast = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetTriggerUnit(),
                CONST_EVENT.skillCast,
                {
                    triggerUnit = cj.GetTriggerUnit(),
                    triggerSkill = cj.GetSpellAbilityId(),
                    targetUnit = cj.GetSpellTargetUnit(),
                    targetLoc = cj.GetSpellTargetLoc()
                }
            )
        end),
        skillStop = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetTriggerUnit(),
                CONST_EVENT.skillStop,
                {
                    triggerUnit = cj.GetTriggerUnit(),
                    triggerSkill = cj.GetSpellAbilityId()
                }
            )
        end),
        skillEffect = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetTriggerUnit(),
                CONST_EVENT.skillEffect,
                {
                    triggerUnit = cj.GetTriggerUnit(),
                    triggerSkill = cj.GetSpellAbilityId(),
                    targetUnit = cj.GetSpellTargetUnit(),
                    targetLoc = cj.GetSpellTargetLoc()
                }
            )
        end),
        skillFinish = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetTriggerUnit(),
                CONST_EVENT.skillFinish,
                {
                    triggerUnit = cj.GetTriggerUnit(),
                    triggerSkill = cj.GetSpellAbilityId()
                }
            )
        end),
        upgradeStart = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetTriggerUnit(),
                CONST_EVENT.upgradeStart,
                {
                    triggerUnit = cj.GetTriggerUnit(),
                }
            )
        end),
        upgradeCancel = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetTriggerUnit(),
                CONST_EVENT.upgradeCancel,
                {
                    triggerUnit = cj.GetTriggerUnit(),
                }
            )
        end),
        upgradeFinish = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetTriggerUnit(),
                CONST_EVENT.upgradeFinish,
                {
                    triggerUnit = cj.GetTriggerUnit(),
                }
            )
        end),
        damaged = cj.Condition(function()
            local sourceUnit = cj.GetEventDamageSource()
            local targetUnit = cj.GetTriggerUnit()
            local damage = cj.GetEventDamage()
            local oldLife = hunit.getCurLife(targetUnit)
            if (damage > 0.125) then
                hattr.set(targetUnit, 0, { life = "+" .. damage })
                htime.setTimeout(
                    0,
                    function(t)
                        htime.delTimer(t)
                        hattr.set(targetUnit, 0, { life = "-" .. damage })
                        hunit.setCurLife(targetUnit, oldLife)
                        hskill.damage(
                            {
                                sourceUnit = sourceUnit,
                                targetUnit = targetUnit,
                                damage = damage,
                                damageKind = "attack"
                            }
                        )
                    end
                )
            end
        end),
        death = cj.Condition(function()
            local u = cj.GetTriggerUnit()
            local killer = hevent.getLastDamageUnit(u)
            if (killer ~= nil) then
                hplayer.addKill(cj.GetOwningPlayer(killer), 1)
            end
            -- @触发死亡事件
            hevent.triggerEvent(
                u,
                CONST_EVENT.dead,
                {
                    triggerUnit = u,
                    killer = killer
                }
            )
            -- @触发击杀事件
            hevent.triggerEvent(
                killer,
                CONST_EVENT.kill,
                {
                    triggerUnit = killer,
                    killer = killer,
                    targetUnit = u
                }
            )
        end),
        sell = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetSellingUnit(),
                CONST_EVENT.unitSell,
                {
                    triggerUnit = cj.GetSellingUnit(),
                    soldUnit = cj.GetSoldUnit(),
                    buyingUnit = cj.GetBuyingUnit(),
                }
            )
        end),
    },
    hero = {
        levelUp = cj.Condition(function()
            local u = cj.GetTriggerUnit()
            hhero.setPrevLevel(u, cj.GetHeroLevel(u))
            local diffLv = cj.GetHeroLevel(u) - hhero.getPrevLevel(u)
            if (diffLv < 1) then
                return
            end
            hattr.set(u, 0, {
                str_white = "=" .. cj.GetHeroStr(u, false),
                agi_white = "=" .. cj.GetHeroAgi(u, false),
                int_white = "=" .. cj.GetHeroInt(u, false)
            })
            -- @触发升级事件
            hevent.triggerEvent(
                u,
                CONST_EVENT.levelUp,
                {
                    triggerUnit = u,
                    value = diffLv
                }
            )
        end)
    },
    dialog = {
        click = cj.Condition(function()
            local clickedDialog = cj.GetClickedDialog()
            local clickedButton = cj.GetClickedButton()
            local val
            for _, b in ipairs(hRuntime.dialog[clickedDialog].buttons) do
                if (b.button == clickedButton) then
                    val = b.value
                end
            end
            if (type(hRuntime.dialog[clickedDialog].action) == 'function') then
                hRuntime.dialog[clickedDialog].action(val)
            end
            hdialog.del(clickedDialog)
        end)
    },
    item = {
        pickup = cj.Condition(function()
            local it = cj.GetManipulatedItem()
            local itId = string.id2char(cj.GetItemTypeId(it))
            if (hslk_global.itemsKV[itId] == nil) then
                -- 排除掉没有注册的物品。例如框架内自带的一些物品
                return
            end
            if (hRuntime.item[it] ~= nil and hRuntime.item[it].positionType == hitem.POSITION_TYPE.UNIT) then
                -- 排除掉runtime内已创建给unit的物品
                return
            end
            local u = cj.GetTriggerUnit()
            local charges = cj.GetItemCharges(it)
            local shadowItId = hitem.getShadowId(itId)
            if (shadowItId == nil) then
                if (hitem.getIsPowerUp(itId) == true) then
                    --检测是否有回调动作
                    local call = hitem.getTriggerCall(itId)
                    if (call ~= nil and type(call) == "function") then
                        call(u, it, itId, charges)
                    end
                    --触发使用物品事件
                    hevent.triggerEvent(
                        u,
                        CONST_EVENT.itemUsed,
                        {
                            triggerUnit = u,
                            triggerItem = it
                        }
                    )
                else
                    --这里删除重建是为了实现地上物品的过期重置
                    hitem.del(it, 0)
                    hitem.create(
                        {
                            itemId = itId,
                            whichUnit = u,
                            charges = charges,
                            during = 0
                        }
                    )
                end
            else
                --注意，系统内此处先获得了face物品，此物品100%是PowerUp的
                --这里删除重建是为了实现地上物品的过期重置
                hitem.del(it, 0)
                --这里是实现神符满格的关键
                hitem.create(
                    {
                        itemId = shadowItId,
                        whichUnit = u,
                        charges = charges,
                        during = 0
                    }
                )
            end
        end),
        drop = cj.Condition(function()
            local u = cj.GetTriggerUnit()
            local it = cj.GetManipulatedItem()
            local itId = string.id2char(cj.GetItemTypeId(it))
            local faceId = hitem.getFaceId(itId)
            local orderId = cj.OrderId("dropitem")
            local charges = cj.GetItemCharges(it)
            if (cj.GetUnitCurrentOrder(u) == orderId) then
                if (hRuntime.item[it] ~= nil) then
                    if (faceId ~= nil) then
                        htime.setTimeout(
                            0,
                            function(t)
                                htime.delTimer(t)
                                local x = cj.GetItemX(it)
                                local y = cj.GetItemX(it)
                                hitem.del(it, 0)
                                --这里是实现表面物品的关键
                                it = hitem.create(
                                    {
                                        itemId = faceId,
                                        x = x,
                                        y = y,
                                        charges = charges,
                                        during = 0
                                    }
                                )
                            end
                        )
                    else
                        hitem.setPositionType(it, hitem.POSITION_TYPE.COORDINATE)
                    end
                end
                hitem.subAttribute(u, itId, charges)
                --触发丢弃物品事件
                hevent.triggerEvent(
                    u,
                    CONST_EVENT.itemDrop,
                    {
                        triggerUnit = u,
                        triggerItem = it,
                        targetUnit = cj.GetOrderTargetUnit(),
                    }
                )
            end
        end),
        pawn = cj.Condition(function()
            --[[
                抵押物品的原理，首先默认是设定：物品售卖为50%，也就是地图的默认设置
                根据玩家的sellRatio，额外的减少或增加玩家的收入
                从而实现玩家的售卖率提升，至于物品的价格是根据slk获取
                所以如果无法获取slk的属性时，此方法自动无效
            ]]
            local u = cj.GetTriggerUnit()
            local it = cj.GetSoldItem()
            local goldcost = hitem.getGoldCost(it)
            local lumbercost = hitem.getLumberCost(it)
            local soldGold = 0
            local soldLumber = 0
            hRuntime.clear(it)
            if (goldcost ~= 0 or lumbercost ~= 0) then
                local p = cj.GetOwningPlayer(u)
                local sellRatio = hplayer.getSellRatio(u)
                if (sellRatio ~= 50) then
                    if (sellRatio < 0) then
                        sellRatio = 0
                    elseif (sellRatio > 1000) then
                        sellRatio = 1000
                    end
                    local tempRatio = sellRatio - 50.0
                    soldGold = math.floor(goldcost * tempRatio * 0.01)
                    soldLumber = math.floor(lumbercost * tempRatio * 0.01)
                    if (goldcost ~= 0 and soldGold ~= 0) then
                        hplayer.addGold(p, soldGold)
                    end
                    if (lumbercost ~= 0 and soldLumber ~= 0) then
                        hplayer.addLumber(p, soldLumber)
                    end
                end
            end
            --触发抵押物品事件
            hevent.triggerEvent(
                u,
                CONST_EVENT.itemPawn,
                {
                    triggerUnit = u,
                    soldItem = it,
                    buyingUnit = cj.GetBuyingUnit(),
                    soldGold = soldGold,
                    soldLumber = soldLumber,
                }
            )
        end),
        use = cj.Condition(function()
            local u = cj.GetTriggerUnit()
            local it = cj.GetManipulatedItem()
            local itId = cj.GetItemTypeId(it)
            local perishable = hitem.getIsPerishable(itId)
            --检测是否使用后自动消失，如果不是，次数补回1
            if (perishable == false) then
                hitem.setCharges(it, hitem.getCharges(it) + 1)
            end
            --检测是否有回调动作
            local call = hitem.getTriggerCall(itId)
            if (call ~= nil and type(call) == "function") then
                call(u, it, itId, charges)
            end
            --触发使用物品事件
            hevent.triggerEvent(
                u,
                CONST_EVENT.itemUsed,
                {
                    triggerUnit = u,
                    triggerItem = it
                }
            )
            --消失的清理cache
            if (perishable == true and hitem.getCharges(it) <= 0) then
                hitem.del(it)
            end
        end),
        sell = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetSellingUnit(),
                CONST_EVENT.itemSell,
                {
                    triggerUnit = cj.GetSellingUnit(),
                    soldItem = cj.GetSoldItem(),
                    buyingUnit = cj.GetBuyingUnit()
                }
            )
        end),
        destroy = cj.Condition(function()
            hevent.triggerEvent(
                cj.GetManipulatedItem(),
                CONST_EVENT.itemDestroy,
                {
                    triggerItem = cj.GetManipulatedItem(),
                    triggerUnit = cj.GetKillingUnit()
                }
            )
        end),
        separate = cj.Condition(function()
            local u = cj.GetTriggerUnit()
            local it = cj.GetManipulatedItem()
            if (it ~= nil and cj.GetSpellAbilityId() == hitem.DEFAULT_SKILL_ITEM_SEPARATE) then
                print_err("拆分物品尚未完成")
            end
        end),
    }
}