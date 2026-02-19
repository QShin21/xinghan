-- SPDX-License-Identifier: GPL-3.0-or-later
-- 董卓(新) - 凶逆技能
-- 出牌阶段开始时，你可以弃置一张牌，其他每名角色需弃置一张与此牌花色相同的牌，
-- 否则受到你造成的1点伤害。

local xiongni = fk.CreateSkill {
  name = "xh__xiongni",
}

Fk:loadTranslationTable {
  ["xh__xiongni"] = "凶逆",
  [":xh__xiongni"] = "出牌阶段开始时，你可以弃置一张牌，其他每名角色需弃置一张与此牌花色相同的牌，"..
    "否则受到你造成的1点伤害。",

  ["#xh__xiongni-use"] = "凶逆：选择一张牌弃置",
  ["#xh__xiongni-discard"] = "凶逆：弃置一张相同花色的牌，否则受到1点伤害",

  ["$xh__xiongni1"] = "凶逆之威，谁敢不从！",
  ["$xh__xiongni2"] = "董卓凶逆，天下大乱！",
}

xiongni:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(xiongni.name) then return false end
    if player.phase ~= Player.Play then return false end
    return not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = xiongni.name,
      pattern = ".",
      prompt = "#xh__xiongni-use",
      cancelable = true,
    })
    
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card_id = event:getCostData(self).cards[1]
    local card = Fk:getCardById(card_id)
    local suit = card.suit
    
    room:throwCard(card_id, xiongni.name, player, player)
    
    -- 其他角色需要弃置相同花色的牌
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead then
        local same_suit_cards = table.filter(p:getCardIds("he"), function(id)
          return Fk:getCardById(id).suit == suit
        end)
        
        if #same_suit_cards > 0 then
          local id = room:askToCards(p, {
            min_num = 1,
            max_num = 1,
            include_equip = true,
            skill_name = xiongni.name,
            pattern = tostring(Exppattern{ id = same_suit_cards }),
            prompt = "#xh__xiongni-discard",
            cancelable = false,
          })
          room:throwCard(id, xiongni.name, p, player)
        else
          room:damage{
            from = player,
            to = p,
            damage = 1,
            skillName = xiongni.name,
          }
        end
      end
    end
  end,
})

return xiongni
