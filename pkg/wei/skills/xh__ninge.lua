-- SPDX-License-Identifier: GPL-3.0-or-later
-- 典韦 - 狞恶技能
-- 锁定技，当一名角色每回合第二次受到伤害后，若其为你或伤害来源为你，你摸一张牌并弃置其场上一张牌。

local ninge = fk.CreateSkill {
  name = "xh__ninge",
}

Fk:loadTranslationTable {
  ["xh__ninge"] = "狞恶",
  [":xh__ninge"] = "锁定技，当一名角色每回合第二次受到伤害后，若其为你或伤害来源为你，你摸一张牌并弃置其场上一张牌。",

  ["@@xh__ninge_damage_count"] = "狞恶伤害计数",

  ["$xh__ninge1"] = "狞恶之姿，无人能挡！",
  ["$xh__ninge2"] = "恶来之名，非虚传也！",
}

ninge:addEffect(fk.Damaged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(ninge.name) then return false end
    
    -- 检查是否为该角色本回合第二次受到伤害
    local count = target:getMark("@@ninge_damage_count") or 0
    if count ~= 1 then return false end
    
    -- 检查条件：其为你或伤害来源为你
    if target ~= player and data.from ~= player then return false end
    
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 摸一张牌
    player:drawCards(1, ninge.name)
    
    -- 弃置其场上一张牌
    if not target.dead and not target:isNude() then
      local id = room:askToChooseCard(player, {
        target = target,
        flag = "he",
        skill_name = ninge.name,
      })
      room:throwCard(id, ninge.name, target, player)
    end
  end,
})

-- 记录伤害次数
ninge:addEffect(fk.Damaged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local count = target:getMark("@@ninge_damage_count") or 0
    room:setPlayerMark(target, "@@ninge_damage_count", count + 1)
  end,
})

-- 回合结束清除标记
ninge:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@ninge_damage_count") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@ninge_damage_count", 0)
  end,
})

return ninge
