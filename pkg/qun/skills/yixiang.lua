-- SPDX-License-Identifier: GPL-3.0-or-later
-- 陶谦 - 义襄技能
-- 锁定技，其他角色的出牌阶段内，其使用的第一张牌对你伤害-1；
-- 其使用的第二张牌若为黑色，则对你无效。

local yixiang = fk.CreateSkill {
  name = "yixiang",
}

Fk:loadTranslationTable {
  ["yixiang"] = "义襄",
  [":yixiang"] = "锁定技，其他角色的出牌阶段内，其使用的第一张牌对你伤害-1；"..
    "其使用的第二张牌若为黑色，则对你无效。",

  ["@@yixiang_count"] = "义襄计数",

  ["$yixiang1"] = "义襄徐州，保境安民！",
  ["$yixiang2"] = "陶谦义襄，仁德布施！",
}

-- 记录使用牌数
yixiang:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player then return false end
    if target.phase ~= Player.Play then return false end
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local count = target:getMark("@@yixiang_count") or 0
    room:setPlayerMark(target, "@@yixiang_count", count + 1)
  end,
})

-- 伤害-1
yixiang:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(yixiang.name) then return false end
    if not data.from then return false end
    local count = data.from:getMark("@@yixiang_count") or 0
    return count == 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage - 1
  end,
})

-- 黑色牌无效
yixiang:addEffect(fk.CardEffecting, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(yixiang.name) then return false end
    if not data.from then return false end
    local count = data.from:getMark("@@yixiang_count") or 0
    return count == 2 and data.card.color == Card.Black
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.nullified = true
  end,
})

-- 回合结束清除标记
yixiang:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@yixiang_count") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@yixiang_count", 0)
  end,
})

return yixiang
