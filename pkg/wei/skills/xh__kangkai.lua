-- SPDX-License-Identifier: GPL-3.0-or-later
-- 曹昂 - 慷忾技能
-- 当一名角色成为【杀】的目标后，若你与其距离1以内，
-- 你可以摸一张牌，然后展示并交给其一张牌，若为装备牌且其不是你，其可以使用之。

local kangkai = fk.CreateSkill {
  name = "xh__kangkai",
}

Fk:loadTranslationTable {
  ["xh__kangkai"] = "慷忾",
  [":xh__kangkai"] = "当一名角色成为【杀】的目标后，若你与其距离1以内，"..
    "你可以摸一张牌，然后展示并交给其一张牌，若为装备牌且其不是你，其可以使用之。",

  ["#xh__kangkai-invoke"] = "慷忾：摸一张牌，然后交给 %dest 一张牌",

  ["$xh__kangkai1"] = "慷慨赴义，死而后已！",
  ["$xh__kangkai2"] = "父债子偿，天经地义！",
}

kangkai:addEffect(fk.TargetConfirmed, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(xh__kangkai.name) then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    return target ~= player and player:distanceTo(target) <= 1
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xh__kangkai.name,
      prompt = "#kangkai-invoke::" .. target.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 摸一张牌
    player:drawCards(1, xh__kangkai.name)

    if player:isKongcheng() then return end

    -- 展示并交给其一张牌
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = xh__kangkai.name,
      pattern = ".",
      prompt = "选择一张牌交给" .. target.name,
      cancelable = false,
    })

    local shown_card = Fk:getCardById(card[1])
    room:showCards(player, card, xh__kangkai.name)

    room:moveCardTo(card, Player.Hand, target, fk.ReasonGive, xh__kangkai.name, nil, false, player.id)

    -- 若为装备牌且其不是你，其可以使用之
    if shown_card.type == Card.TypeEquip and not target.dead then
      if target:canUse(shown_card) then
        room:askToUseCard(target, {
          skill_name = xh__kangkai.name,
          pattern = shown_card,
          prompt = "是否使用" .. shown_card.name .. "？",
          cancelable = true,
        })
      end
    end
  end,
})

return kangkai
