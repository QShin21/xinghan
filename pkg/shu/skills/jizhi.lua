-- SPDX-License-Identifier: GPL-3.0-or-later
-- 黄月英 - 集智技能
-- 当你使用一张非延时类锦囊牌时，你可以摸一张牌。

local jizhi = fk.CreateSkill {
  name = "jizhi",
}

Fk:loadTranslationTable {
  ["jizhi"] = "集智",
  [":jizhi"] = "当你使用一张非延时类锦囊牌时，你可以摸一张牌。",

  ["#jizhi-invoke"] = "集智：是否摸一张牌？",
  ["@@jizhi_hand_limit"] = "集智手牌上限",

  ["$jizhi1"] = "集智之才，天下无双！",
  ["$jizhi2"] = "黄月英集智，奇才无双！",
}

jizhi:addEffect(fk.CardUsing, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(jizhi.name) then return false end
    if not data.card then return false end
    
    return data.card.type == Card.TypeTrick and not data.card.sub_type == Card.SubtypeDelayedTrick
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jizhi.name,
      prompt = "#jizhi-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, jizhi.name)
  end,
})

return jizhi
