-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孙策 - 激昂技能
-- 当你使用【决斗】或红色【杀】指定目标后，或成为【决斗】或红色【杀】的目标后，你可以摸一张牌。

local jiang = fk.CreateSkill {
  name = "jiang",
}

Fk:loadTranslationTable {
  ["jiang"] = "激昂",
  [":jiang"] = "当你使用【决斗】或红色【杀】指定目标后，或成为【决斗】或红色【杀】的目标后，你可以摸一张牌。",

  ["#jiang-invoke"] = "激昂：是否摸一张牌？",

  ["$jiang1"] = "激昂之志，天下无双！",
  ["$jiang2"] = "江东小霸王，激昂天下！",
}

jiang:addEffect(fk.TargetSpecified, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(jiang.name) then return false end
    if not data.card then return false end
    
    local card = data.card
    return card.trueName == "duel" or (card.trueName == "slash" and card.color == Card.Red)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jiang.name,
      prompt = "#jiang-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, jiang.name)
  end,
})

jiang:addEffect(fk.TargetConfirmed, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(jiang.name) then return false end
    if not data.card then return false end
    
    local card = data.card
    return card.trueName == "duel" or (card.trueName == "slash" and card.color == Card.Red)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jiang.name,
      prompt = "#jiang-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, jiang.name)
  end,
})

return jiang
