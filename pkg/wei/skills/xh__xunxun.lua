-- SPDX-License-Identifier: GPL-3.0-or-later
-- 李典 - 恂恂技能
-- 摸牌阶段开始时，你可以观看牌堆顶的四张牌，将其中两张牌以任意顺序置于牌堆顶，
-- 然后将其余的牌以任意顺序置于牌堆底。

local xunxun = fk.CreateSkill {
  name = "xh__xunxun",
}

Fk:loadTranslationTable {
  ["xh__xunxun"] = "恂恂",
  [":xh__xunxun"] = "摸牌阶段开始时，你可以观看牌堆顶的四张牌，将其中两张牌以任意顺序置于牌堆顶，"..
    "然后将其余的牌以任意顺序置于牌堆底。",

  ["#xh__xunxun-invoke"] = "恂恂：你可以观看牌堆顶的四张牌",
  ["#xh__xunxun-top"] = "恂恂：选择两张牌置于牌堆顶",
  ["#xh__xunxun-bottom"] = "恂恂：选择剩余牌置于牌堆底的顺序",

  ["$xh__xunxun1"] = "恂恂君子，温润如玉。",
  ["$xh__xunxun2"] = "以德服人，以礼待人。",
}

xunxun:addEffect(fk.DrawNCards, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xunxun.name) and
      player.room:getDrawPileNum() >= 4
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xunxun.name,
      prompt = "#xh__xunxun-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 获取牌堆顶的四张牌
    local cards = room:getNCards(4)

    -- 展示牌
    room:showCards(player, cards, xunxun.name)

    -- 选择两张牌置于牌堆顶
    local top_cards = room:askToCards(player, {
      min_num = 2,
      max_num = 2,
      include_equip = false,
      skill_name = xunxun.name,
      pattern = tostring(Exppattern{ id = cards }),
      prompt = "#xh__xunxun-top",
      cancelable = false,
    })

    -- 剩余的牌置于牌堆底
    local bottom_cards = table.filter(cards, function(id)
      return not table.contains(top_cards, id)
    end)

    -- 将牌放回牌堆
    -- 先放底部的牌
    for _, id in ipairs(bottom_cards) do
      room:moveCardTo(id, Card.DrawPile, nil, fk.ReasonPut, xunxun.name, nil, true)
    end

    -- 再放顶部的牌（逆序，这样最后选的在最上面）
    for i = #top_cards, 1, -1 do
      room:moveCardTo(top_cards[i], Card.DrawPile, nil, fk.ReasonPut, xunxun.name, nil, true)
    end
  end,
})

return xunxun
