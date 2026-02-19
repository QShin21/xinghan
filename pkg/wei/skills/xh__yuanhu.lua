-- SPDX-License-Identifier: GPL-3.0-or-later
-- 曹洪 - 援护技能
-- 出牌阶段限一次，你可以将一张装备牌置入一名角色的装备区里，然后若此牌为：
-- 武器牌，你弃置其距离为1的另一名角色区域里的至多两张牌；
-- 防具牌，其摸两张牌；
-- 坐骑牌，其回复1点体力。

local yuanhu = fk.CreateSkill {
  name = "xh__yuanhu",
}

Fk:loadTranslationTable {
  ["xh__yuanhu"] = "援护",
  [":xh__yuanhu"] = "出牌阶段限一次，你可以将一张装备牌置入一名角色的装备区里，然后若此牌为：武器牌，你弃置其距离为1的另一名角色区域里的至多两张牌；防具牌，其摸两张牌；坐骑牌，其回复1点体力。",

  ["#xh__yuanhu-choose"] = "援护：选择一张装备牌和一名角色",
  ["#xh__yuanhu-discard"] = "援护：弃置 %dest 距离1的角色区域里的至多两张牌",
  ["#xh__yuanhu-discard2"] = "援护：选择要弃置的牌（至多2张）",

  ["$xh__yuanhu1"] = "将军，这件兵器可还趁手？",
  ["$xh__yuanhu2"] = "刀剑无眼，须得小心防护。",
  ["$xh__yuanhu3"] = "宝马配英雄！哈哈哈哈……",
}

yuanhu:addEffect("active", {
  mute = true,
  prompt = "#yuanhu-choose",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(xh__yuanhu.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local card = Fk:getCardById(to_select)
    return card.type == Card.TypeEquip and player:prohibitUse(card) == false
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    if #selected_cards == 0 then return false end
    local card = Fk:getCardById(selected_cards[1])
    return to_select ~= player and not to_select:hasEquip(card)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local card = Fk:getCardById(effect.cards[1])

    room:notifySkillInvoked(player, xh__yuanhu.name, "support", {target})
    room:moveCardIntoEquip(target, effect.cards[1], xh__yuanhu.name, false, player)

    if target.dead then return end

    if card.sub_type == Card.SubtypeWeapon then
      player:broadcastSkillInvoke(xh__yuanhu.name, 1)
      -- 弃置距离为1的另一名角色区域里的至多两张牌
      local targets = table.filter(room.alive_players, function(p)
        return p ~= target and p:distanceTo(target) == 1 and not p:isAllNude()
      end)
      if #targets == 0 then return end

      local p = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#yuanhu-discard::" .. target.id,
        skill_name = xh__yuanhu.name,
        cancelable = false,
      })[1]

      if p then
        local cards = room:askToCards(player, {
          min_num = 1,
          max_num = 2,
          include_equip = true,
          skill_name = xh__yuanhu.name,
          pattern = tostring(Exppattern{ id = p:getCardIds("hej") }),
          prompt = "#yuanhu-discard2",
          cancelable = false,
        })
        room:throwCard(cards, xh__yuanhu.name, p, player)
      end

    elseif card.sub_type == Card.SubtypeArmor then
      player:broadcastSkillInvoke(xh__yuanhu.name, 2)
      target:drawCards(2, xh__yuanhu.name)

    elseif card.sub_type == Card.SubtypeOffensiveRide or card.sub_type == Card.SubtypeDefensiveRide then
      player:broadcastSkillInvoke(xh__yuanhu.name, 3)
      if target:isWounded() then
        room:recover{
          who = target,
          num = 1,
          recoverBy = player,
          skillName = xh__yuanhu.name,
        }
      end
    end
  end,
})

return yuanhu
