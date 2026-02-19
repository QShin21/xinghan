-- SPDX-License-Identifier: GPL-3.0-or-later
-- 刘协 - 天命技能
-- 当你成为【杀】的目标后，你可以弃置两张牌（不足则全弃），然后摸两张牌。

local tianming = fk.CreateSkill {
  name = "xh__tianming",
}

Fk:loadTranslationTable {
  ["xh__tianming"] = "天命",
  [":xh__tianming"] = "当你成为【杀】的目标后，你可以弃置两张牌（不足则全弃），然后摸两张牌。",

  ["#xh__tianming-invoke"] = "天命：是否弃置两张牌并摸两张牌？",

  ["$xh__tianming1"] = "天命所归，谁敢不从！",
  ["$xh__tianming2"] = "汉室正统，天命在我！",
}

tianming:addEffect(fk.TargetConfirmed, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(tianming.name) then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = tianming.name,
      prompt = "#xh__tianming-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 弃置两张牌（不足则全弃）
    local handcards = player:getCardIds("he")
    local discard_num = math.min(2, #handcards)
    
    if discard_num > 0 then
      local cards = room:askToCards(player, {
        min_num = discard_num,
        max_num = discard_num,
        include_equip = true,
        skill_name = tianming.name,
        pattern = ".",
        prompt = "选择" .. discard_num .. "张牌弃置",
        cancelable = false,
      })
      room:throwCard(cards, tianming.name, player, player)
    end
    
    -- 摸两张牌
    player:drawCards(2, tianming.name)
  end,
})

return tianming
