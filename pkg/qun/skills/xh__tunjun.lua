-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张济 - 屯军技能
-- 限定技，出牌阶段，你可以亮出牌堆顶的3X张牌，然后依次使用其中的至多X张装备牌
-- （X为你发动过技能"掠命"的次数且至多为4）。

local tunjun = fk.CreateSkill {
  name = "xh__tunjun",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ["xh__tunjun"] = "屯军",
  [":xh__tunjun"] = "限定技，出牌阶段，你可以亮出牌堆顶的3X张牌，然后依次使用其中的至多X张装备牌"..
    "（X为你发动过技能\"掠命\"的次数且至多为4）。",

  ["#xh__tunjun-use"] = "屯军：亮出牌堆顶的牌并使用装备牌",

  ["$xh__tunjun1"] = "屯军积粮，以待天时！",
  ["$xh__tunjun2"] = "军资充足，战无不胜！",
}

tunjun:addEffect("active", {
  mute = true,
  prompt = "#tunjun-use",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(xh__tunjun.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, xh__tunjun.name, "support")
    player:broadcastSkillInvoke(xh__tunjun.name)

    -- X为掠命发动次数，至多为4
    local x = math.min(player:getMark("@@lueling_count") or 0, 4)
    if x == 0 then x = 1 end
    
    local total = 3 * x
    
    -- 亮出牌堆顶的牌
    local cards = {}
    for i = 1, total do
      if #room.draw_pile > 0 then
        table.insert(cards, room.draw_pile[1])
        room:showCards(player, {room.draw_pile[1]}, xh__tunjun.name)
        table.remove(room.draw_pile, 1)
      end
    end
    
    -- 使用其中的装备牌
    local equip_cards = table.filter(cards, function(id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end)
    
    local used = 0
    for _, id in ipairs(equip_cards) do
      if used >= x then break end
      
      local card = Fk:getCardById(id)
      if player:canUse(card) then
        room:useCard{
          from = player.id,
          card = card,
        }
        used = used + 1
      end
    end
    
    -- 剩余的牌放入弃牌堆
    for _, id in ipairs(cards) do
      if not table.contains(player:getCardIds("e"), id) then
        room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, xh__tunjun.name)
      end
    end
  end,
})

return tunjun
