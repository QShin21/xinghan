-- SPDX-License-Identifier: GPL-3.0-or-later
-- 刘表 - 自守技能
-- 摸牌阶段，你可以多摸X张牌（X为全场势力数）。若如此做，本回合你使用牌不能选择其他角色为目标。

local zishou = fk.CreateSkill {
  name = "zishou",
}

Fk:loadTranslationTable {
  ["zishou"] = "自守",
  [":zishou"] = "摸牌阶段，你可以多摸X张牌（X为全场势力数）。若如此做，本回合你使用牌不能选择其他角色为目标。",

  ["#zishou-invoke"] = "自守：是否多摸牌？本回合不能以其他角色为目标",
  ["@@zishou_no_target"] = "自守",

  ["$zishou1"] = "自守荆州，保境安民！",
  ["$zishou2"] = "守土有责，不敢懈怠！",
}

zishou:addEffect(fk.DrawNCards, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zishou.name)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = zishou.name,
      prompt = "#zishou-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 计算势力数
    local kingdoms = {}
    for _, p in ipairs(room.alive_players) do
      kingdoms[p.kingdom] = true
    end
    local x = table.size(kingdoms)
    
    data.num = data.num + x
    room:addPlayerMark(player, "@@zishou_no_target", 1)
  end,
})

-- 不能选择其他角色为目标
zishou:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    if from:getMark("@@zishou_no_target") > 0 and to ~= from then
      return true
    end
    return false
  end,
})

-- 回合结束清除标记
zishou:addEffect(fk.TurnEnd, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@zishou_no_target") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@zishou_no_target", 0)
  end,
})

return zishou
