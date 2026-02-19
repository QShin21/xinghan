-- SPDX-License-Identifier: GPL-3.0-or-later
-- 曹仁 - 肃军技能
-- 你的回合外，你可以将一张本回合所有角色均未使用过的颜色的手牌当【无懈可击】使用。

local sujun = fk.CreateSkill {
  name = "xh__sujun",
}

Fk:loadTranslationTable{
  ["xh__sujun"] = "肃军",
  [":xh__sujun"] = "你的回合外，你可以将一张本回合所有角色均未使用过的颜色的手牌当【无懈可击】使用。",

  ["#xh__sujun"] = "肃军：将一张牌当【无懈可击】使用",

  ["$xh__sujun1"] = "整军备战，严阵以待！",
  ["$xh__sujun2"] = "军纪严明，不可懈怠！",
}

sujun:addEffect("viewas", {
  pattern = "nullification",
  prompt = "#xh__sujun",
  handly_pile = true,
  filter_pattern = function (self, player, card_name)
    local colors = {"red", "black"}
    for _, c in ipairs(player:getTableMark("xh__sujun-turn")) do
      table.removeOne(colors, c)
    end
    if #colors > 0 then
      return {
        max_num = 1,
        min_num = 1,
        pattern = ".|.|" .. table.concat(colors, ",") .. "|^equip",
      }
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("nullification")
    card.skillName = sujun.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return false
  end,
  enabled_at_response = function(self, player, response)
    return not response and #player:getTableMark("xh__sujun-turn") < 2
  end,
  enabled_at_nullification = function (self, player, data)
    return #player:getTableMark("xh__sujun-turn") < 2 and #player:getHandlyIds() > 0
  end,
})

sujun:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(sujun.name, true) and data.card.color ~= Card.NoColor
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "xh__sujun-turn", data.card:getColorString())
  end,
})

sujun:addAcquireEffect(function (self, player, is_start)
  if not is_start then
    local room = player.room
    local mark = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data
      if use.card.color ~= Card.NoColor then
        table.insertIfNeed(mark, use.card:getColorString())
      end
    end, Player.HistoryTurn)
    if #mark > 0 then
      room:setPlayerMark(player, "xh__sujun-turn", mark)
    end
  end
end)

return sujun
