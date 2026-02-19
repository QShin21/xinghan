-- SPDX-License-Identifier: GPL-3.0-or-later
-- 关平 - 龙吟技能
-- 当一名角色于其出牌阶段内使用【杀】时，你可以弃置一张牌，
-- 令此【杀】不计入此阶段使用次数，若此【杀】为红色，你摸一张牌。
-- 若你弃置的牌与【杀】点数相同，"竭忠"视为未发动过。

local longyin = fk.CreateSkill {
  name = "xh__longyin",
}

Fk:loadTranslationTable {
  ["xh__longyin"] = "龙吟",
  [":xh__longyin"] = "当一名角色于其出牌阶段内使用【杀】时，你可以弃置一张牌，"..
    "令此【杀】不计入此阶段使用次数，若此【杀】为红色，你摸一张牌。"..
    "若你弃置的牌与【杀】点数相同，\"竭忠\"视为未发动过。",

  ["#xh__longyin-invoke"] = "龙吟：弃置一张牌令此杀不计入次数",

  ["$xh__longyin1"] = "龙吟虎啸，威震天下！",
  ["$xh__longyin2"] = "关氏龙吟，谁敢争锋！",
}

longyin:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(longyin.name) then return false end
    if target.phase ~= Player.Play then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    if player:isNude() then return false end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = longyin.name,
      pattern = ".",
      prompt = "#xh__longyin-invoke",
      cancelable = true,
    })
    
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = event:getCostData(self).cards[1]
    
    room:throwCard(card, longyin.name, player, player)
    
    -- 不计入次数
    data.extra_data = data.extra_data or {}
    data.extra_data.longyin_no_count = true
    
    -- 红色杀摸牌
    if data.card.color == Card.Red then
      player:drawCards(1, longyin.name)
    end
    
    -- 点数相同，竭忠视为未发动
    if Fk:getCardById(card).number == data.card.number then
      player:setSkillUseHistory("jiezhong", 0, Player.HistoryGame)
    end
  end,
})

return longyin
