---@class htexture 纹理（遮罩/警示圈）
htexture = {
    TEXTURE_ALERT_CIRCLE_TOKEN = hslk_global.unit_token_alert_circle,
}

---@private
htexture.cinematicFilterGeneric = function(duration, bmode, tex, red0, green0, blue0, trans0, red1, green1, blue1, trans1)
    if cg.bj_cineFadeContinueTimer ~= nil then
        cj.DestroyTimer(cg.bj_cineFadeContinueTimer)
    end
    if cg.bj_cineFadeFinishTimer ~= nil then
        cj.DestroyTimer(cg.bj_cineFadeFinishTimer)
    end
    cj.SetCineFilterTexture(tex)
    cj.SetCineFilterBlendMode(bmode)
    cj.SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
    cj.SetCineFilterStartUV(0, 0, 1, 1)
    cj.SetCineFilterEndUV(0, 0, 1, 1)
    cj.SetCineFilterStartColor(
        red0,
        green0,
        blue0,
        255 - trans0
    )
    cj.SetCineFilterEndColor(
        red1,
        green1,
        blue1,
        255 - trans1
    )
    cj.SetCineFilterDuration(duration)
    cj.DisplayCineFilter(true)
end

--- 创建一个遮罩
---@public
---@param path string 贴图路径 512x256 png->blp
---@param during number 持续时间
---@param whichPlayer userdata|nil 玩家
htexture.mark = function(path, during, whichPlayer)
    if (whichPlayer == nil) then
        htexture.cinematicFilterGeneric(
            0.50,
            BLEND_MODE_ADDITIVE,
            path,
            255, 255, 255, 255,
            255, 255, 255, 0
        )
        htime.setTimeout(
            during,
            function(t)
                htime.delTimer(t)
                htexture.cinematicFilterGeneric(
                    0.50,
                    BLEND_MODE_ADDITIVE,
                    path,
                    255, 255, 255, 0,
                    255, 255, 255, 255
                )
            end
        )
    elseif (whichPlayer ~= nil) then
        if (whichPlayer == cj.GetLocalPlayer()) then
            htexture.cinematicFilterGeneric(
                0.50,
                BLEND_MODE_ADDITIVE,
                path,
                255, 255, 255, 255,
                255, 255, 255, 0
            )
        end
        htime.setTimeout(
            during,
            function(t)
                htime.delTimer(t)
                if (whichPlayer == cj.GetLocalPlayer()) then
                    htexture.cinematicFilterGeneric(
                        0.50,
                        BLEND_MODE_ADDITIVE,
                        path,
                        255, 255, 255, 0,
                        255, 255, 255, 255
                    )
                end
            end
        )
    end
end

--- 创建一个警示圈
---@param diameter number 直径范围(px)
---@param x number 坐标X
---@param y number 坐标Y
---@param during number 持续时间，警示圈不允许永久存在，during默认为3秒
htexture.alertCircle = function(diameter, x, y, during)
    if (diameter == nil or diameter < 64) then
        return
    end
    during = during or 3
    if (during <= 0) then
        during = 3
    end
    local modelScale = math.round(diameter / 64)
    local u = cj.CreateUnit(hplayer.player_passive, htexture.TEXTURE_ALERT_CIRCLE_TOKEN, x, y, bj_UNIT_FACING)
    cj.SetUnitScale(u, modelScale, modelScale, modelScale)
    cj.SetUnitTimeScale(u, 1 / during)
    hunit.del(u, during)
end