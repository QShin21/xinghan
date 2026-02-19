-- SPDX-License-Identifier: GPL-3.0-or-later
-- 樊稠 - 兴乱技能
-- 出牌阶段限一次，当你使用仅指定一个目标的牌结算完毕后，
-- 你可以将牌堆顶六张牌置入弃牌堆，然后从弃牌堆中选择一张点数为6且上个回合未选择的牌名的牌获得。

local xingluan = fk.CreateSkill {
  name = "xingluan",
}

Fk:loadTranslationTable {
  ["xingluan"] = "兴乱",
  [":xingluan"] = "出牌阶段限一次，当你使用仅指定一个目标的牌结算完毕后，"..
    "你可以将牌堆顶六张牌置入弃牌堆，然后从弃牌堆中选择一张点数为6且上个回合未选择的牌名的牌获得。",

  ["#xingluan-invoke"] = "兴乱：是否将牌堆顶六张牌置入弃牌堆并选择获得一张牌？",
  ["@@xingluan_used"] = "兴乱已用牌名",

  ["$xingluan1"] = "兴乱之计，天下大乱！",
  ["$xingluan2"] = "樊稠兴乱，势不可挡！",
}

xingluan:addEffect(fk.CardUseFinished, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(xingluan.name) then return false end
    if player.phase ~= Player.Play then return false end
    if player:usedSkillTimes(xingluan.name, Player.HistoryPhase) > 0 then return false end
    if not data.card or #data.use.tos ~= 1 then return false end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xingluan.name,
      prompt = "#xingluan-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 将牌堆顶六张牌置入弃牌堆
    local cards = {}
    for i = 1, 6 do
      if #room.draw_pile > 0 then
        table.insert(cards, room.draw_pile[1])
        room:moveCardTo(room.draw_pile[1], Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, xingluan.name)
        table.remove(room.draw_pile, 1)
      end
    end
    
    -- 从弃牌堆中选择一张点数为6且上个回合未选择的牌名的牌
    local used_names = player:getMark("@@xingluan_used") or {}
    if type(used_names) ~= "table" then used_names = {} end
    
    local valid_cards = table.filter(room.discard_pile, function(id)
      local card = Fk:getCardById(id)
      return card.number == 6 and not table.contains(used_names, card.name)
    end)
    
    if #valid_cards > 0 then
      local id = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = xingluan.name,
        pattern = tostring(Exppattern{ id = valid_cards }),
        prompt = "选择一张点数为6的牌获得",
        cancelable = false,
      })
      
      local card = Fk:getCardById(id[1])
      room:moveCardTo(id, Player.Hand, player, fk.ReasonPrey, xingluan.name)
      
      -- 记录已选择的牌名
      table.insert(used_names, card.name)
      room:setPlayerMark(player, "@@xingluan_used", used_names)
    end
  end,
})

-- 回合结束清除标记
xingluan:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@xingluan_used") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@xingluan_used", 0)
  end,
})

return xingluan
