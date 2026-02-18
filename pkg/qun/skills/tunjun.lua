-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张济 - 屯军技能
-- 限定技，出牌阶段，你可以亮出牌堆顶的3X张牌，然后依次使用其中的至多X张装备牌
-- （X为你发动过技能"掠命"的次数且至大为4）。

local tunjun = fk.CreateSkill {
  name = "tunjun",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ["tunjun"] = "屯军",
  [":tunjun"] = "限定技，出牌阶段，你可以亮出牌堆顶的3X张牌，然后依次使用其中的至多X张装备牌"..
    "（X为你发动过技能\"掠命\"的次数且至大为4）。",

  ["#tunjun-invoke"] = "屯军：亮出牌堆顶的3X张牌，使用其中的装备牌",

  ["$tunjun1"] = "屯兵积粮，待时而动！",
  ["$tunjun2"] = "军马齐备，只待一战！",
}

tunjun:addEffect("active", {
  mute = true,
  prompt = "#tunjun-invoke",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(tunjun.name) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, tunjun.name, "support")
    player:broadcastSkillInvoke(tunjun.name)

    -- 计算X
    local x = player:getMark("@@lveming_count")
    if x == 0 then x = 1 end
    if x > 4 then x = 4 end

    -- 亮出牌堆顶的3X张牌
    local cards = room:getNCards(3 * x)
    room:showCards(player, cards, tunjun.name)

    -- 筛选装备牌
    local equips = table.filter(cards, function(id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end)

    -- 依次使用至多X张装备牌
    local used = 0
    while used < x and #equips > 0 do
      local card = room:askToCards(player, {
        min_num = 0,
        max_num = 1,
        include_equip = false,
        skill_name = tunjun.name,
        pattern = tostring(Exppattern{ id = equips }),
        prompt = "选择一张装备牌使用（已使用" .. used .. "/" .. x .. "张）",
        cancelable = true,
      })

      if #card == 0 then break end

      local equip = Fk:getCardById(card[1])
      if player:canUse(equip) then
        room:useCard{
          from = player.id,
          card = equip,
        }
        used = used + 1
      end

      table.removeOne(equips, card[1])
    end

    -- 将剩余的牌置入弃牌堆
    local remaining = table.filter(cards, function(id)
      return not table.contains(player:getCardIds("hej"), id)
    end)

    if #remaining > 0 then
      room:moveCardTo(remaining, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile)
    end
  end,
})

return tunjun
