-- SPDX-License-Identifier: GPL-3.0-or-later
-- 荀攸 - 智愚技能
-- 当你受到伤害后，你可以摸一张牌，然后展示所有手牌且伤害来源弃置一张手牌。
-- 若所有手牌颜色均相同，你获得弃置的牌且下回合"奇策"发动次数+1。

local zhiyu = fk.CreateSkill {
  name = "zhiyu",
}

Fk:loadTranslationTable {
  ["zhiyu"] = "智愚",
  [":zhiyu"] = "当你受到伤害后，你可以摸一张牌，然后展示所有手牌且伤害来源弃置一张手牌。"..
    "若所有手牌颜色均相同，你获得弃置的牌且下回合\"奇策\"发动次数+1。",

  ["#zhiyu-invoke"] = "智愚：摸一张牌，展示手牌，令伤害来源弃置一张牌",
  ["@@zhiyu_extra"] = "智愚",

  ["$zhiyu1"] = "大智若愚，大巧若拙！",
  ["$zhiyu2"] = "智者千虑，必有一失！",
}

zhiyu:addEffect(fk.Damaged, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhiyu.name) and
      data.from and not data.from.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = zhiyu.name,
      prompt = "#zhiyu-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from

    -- 摸一张牌
    player:drawCards(1, zhiyu.name)

    if player:isKongcheng() then return end

    -- 展示所有手牌
    local handcards = player:getCardIds("h")
    room:showCards(player, handcards, zhiyu.name)

    -- 伤害来源弃置一张手牌
    if from.dead or from:isKongcheng() then return end

    local id = room:askToChooseCard(player, {
      target = from,
      flag = "h",
      skill_name = zhiyu.name,
    })

    -- 检查手牌颜色是否均相同
    local same_color = true
    local first_color = nil
    for _, card_id in ipairs(handcards) do
      local card = Fk:getCardById(card_id)
      if first_color == nil then
        first_color = card.color
      elseif card.color ~= first_color then
        same_color = false
        break
      end
    end

    if same_color then
      -- 获得弃置的牌
      room:moveCardTo(id, Player.Hand, player, fk.ReasonPrey, zhiyu.name, nil, false, from.id)

      -- 下回合奇策发动次数+1
      room:addPlayerMark(player, "@@zhiyu_extra", 1)
    else
      room:throwCard(id, zhiyu.name, from, player)
    end
  end,
})

-- 增加奇策发动次数
zhiyu:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    return player:getMark("@@zhiyu_extra")
  end,
})

-- 回合结束清除标记
zhiyu:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@zhiyu_extra") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@zhiyu_extra", 0)
  end,
})

return zhiyu
