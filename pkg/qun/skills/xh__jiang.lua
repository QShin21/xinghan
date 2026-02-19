-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孙策 - 激昂技能
-- 当你使用【决斗】或红色【杀】指定目标后，或成为【决斗】或红色【杀】的目标后，你可以摸一张牌。

local jiang = fk.CreateSkill {
  name = "xh__jiang",
}

Fk:loadTranslationTable {
  ["xh__jiang"] = "激昂",
  [":xh__jiang"] = "当你使用【决斗】或红色【杀】指定目标后，或成为【决斗】或红色【杀】的目标后，你可以摸一张牌。",

  ["#xh__jiang-invoke"] = "激昂：你可以摸一张牌",

  ["$xh__jiang1"] = "激昂慷慨，豪气干云！",
  ["$xh__jiang2"] = "江东小霸王，谁敢争锋！",
}

jiang:addEffect(fk.TargetSpecifying, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(xh__jiang.name) then return false end
    
    local card = data.card
    if not card then return false end
    
    if card.trueName == "duel" then return true end
    if card.trueName == "slash" and card.color == Card.Red then return true end
    
    return false
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xh__jiang.name,
      prompt = "#jiang-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, xh__jiang.name)
  end,
})

jiang:addEffect(fk.TargetConfirmed, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(xh__jiang.name) then return false end
    
    local card = data.card
    if not card then return false end
    
    if card.trueName == "duel" then return true end
    if card.trueName == "slash" and card.color == Card.Red then return true end
    
    return false
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xh__jiang.name,
      prompt = "#jiang-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, xh__jiang.name)
  end,
})

return jiang
