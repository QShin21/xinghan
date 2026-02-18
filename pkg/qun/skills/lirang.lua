-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孔融 - 礼让技能
-- 当你的牌因弃置而置入弃牌堆后，你可以将其中的任意张牌交给其他角色；
-- 一名角色的结束阶段，你摸等同于你本回合以此法交给其他角色牌数的牌。

local lirang = fk.CreateSkill {
  name = "lirang",
}

Fk:loadTranslationTable {
  ["lirang"] = "礼让",
  [":lirang"] = "当你的牌因弃置而置入弃牌堆后，你可以将其中的任意张牌交给其他角色；"..
    "一名角色的结束阶段，你摸等同于你本回合以此法交给其他角色牌数的牌。",

  ["#lirang-give"] = "礼让：你可以将弃置的牌交给其他角色",
  ["@@lirang_count"] = "礼让",

  ["$lirang1"] = "礼让为先，谦逊待人！",
  ["$lirang2"] = "让利于人，得道多助！",
}

-- 记录弃置的牌
lirang:addEffect(fk.BeforeCardsMove, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(lirang.name) then return false end

    local discard_cards = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          table.insert(discard_cards, info.cardId)
        end
      end
    end

    if #discard_cards > 0 then
      event:setCostData(self, {cards = discard_cards})
      return true
    end
    return false
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards

    return room:askToSkillInvoke(player, {
      skill_name = lirang.name,
      prompt = "#lirang-give",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards

    -- 选择要给出的牌
    local give_cards = room:askToCards(player, {
      min_num = 1,
      max_num = #cards,
      include_equip = false,
      skill_name = lirang.name,
      pattern = tostring(Exppattern{ id = cards }),
      prompt = "选择要交给其他角色的牌",
      cancelable = true,
    })

    if #give_cards > 0 then
      local targets = room:getOtherPlayers(player, false)
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = lirang.name,
        prompt = "选择接收牌的角色",
        cancelable = false,
      })[1]

      room:moveCardTo(give_cards, Player.Hand, to, fk.ReasonGive, lirang.name, nil, false, player.id)

      -- 记录给出的牌数
      room:addPlayerMark(player, "@@lirang_count", #give_cards)
    end
  end,
})

-- 结束阶段摸牌
lirang:addEffect(fk.EventPhaseStart, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(lirang.name) and target.phase == Player.Finish and
      player:getMark("@@lirang_count") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local count = player:getMark("@@lirang_count")
    player:drawCards(count, lirang.name)
    room:setPlayerMark(player, "@@lirang_count", 0)
  end,
})

return lirang
