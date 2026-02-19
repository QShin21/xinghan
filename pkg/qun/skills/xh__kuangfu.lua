-- SPDX-License-Identifier: GPL-3.0-or-later
-- 潘凤 - 狂斧技能
-- 出牌阶段限一次，你可以弃置一名角色装备区里的一张牌，然后视为使用一张无距离和次数限制的【杀】，
-- 当此【杀】结算结束后：若你以此法弃置的为你的牌且此【杀】造成过伤害，你摸两张牌；
-- 若你以此法弃置的不为你的牌且此【杀】未造成过伤害，你弃置两张手牌。

local kuangfu = fk.CreateSkill {
  name = "xh__kuangfu",
}

Fk:loadTranslationTable {
  ["xh__kuangfu"] = "狂斧",
  [":xh__kuangfu"] = "出牌阶段限一次，你可以弃置一名角色装备区里的一张牌，然后视为使用一张无距离和次数限制的【杀】，"..
    "当此【杀】结算结束后：若你以此法弃置的为你的牌且此【杀】造成过伤害，你摸两张牌；"..
    "若你以此法弃置的不为你的牌且此【杀】未造成过伤害，你弃置两张手牌。",

  ["#xh__kuangfu-target"] = "狂斧：选择一名有装备牌的角色",
  ["@@xh__kuangfu_self"] = "狂斧自己的牌",
  ["@@xh__kuangfu_damage"] = "狂斧造成伤害",

  ["$xh__kuangfu1"] = "狂斧之威，势不可挡！",
  ["$xh__kuangfu2"] = "潘凤在此，谁敢争锋！",
}

kuangfu:addEffect("active", {
  mute = true,
  prompt = "#xh__kuangfu-target",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(kuangfu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return #to_select:getCardIds("e") > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, kuangfu.name, "offensive", {target})
    player:broadcastSkillInvoke(kuangfu.name)

    -- 选择弃置装备区的一张牌
    local id = room:askToChooseCard(player, {
      target = target,
      flag = "e",
      skill_name = kuangfu.name,
    })
    
    local is_self = target == player
    room:throwCard(id, kuangfu.name, target, player)
    
    -- 标记
    room:setPlayerMark(player, "@@kuangfu_self", is_self and 1 or 0)
    room:setPlayerMark(player, "@@kuangfu_damage", 0)
    
    -- 视为使用杀
    local slash = Fk:cloneCard("slash")
    slash.skillName = kuangfu.name
    
    room:useCard{
      from = player.id,
      tos = {target.id},
      card = slash,
      extra_data = { kuangfu = true },
    }
    
    -- 结算后效果
    local caused_damage = player:getMark("@@kuangfu_damage") > 0
    
    if is_self and caused_damage then
      -- 摸两张牌
      player:drawCards(2, kuangfu.name)
    elseif not is_self and not caused_damage then
      -- 弃置两张手牌
      if player:getHandcardNum() >= 2 then
        local cards = room:askToCards(player, {
          min_num = 2,
          max_num = 2,
          include_equip = false,
          skill_name = kuangfu.name,
          pattern = ".",
          prompt = "选择两张手牌弃置",
          cancelable = false,
        })
        room:throwCard(cards, kuangfu.name, player, player)
      end
    end
    
    -- 清除标记
    room:setPlayerMark(player, "@@kuangfu_self", 0)
    room:setPlayerMark(player, "@@kuangfu_damage", 0)
  end,
})

-- 记录是否造成伤害
kuangfu:addEffect(fk.Damage, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card and data.card.extra_data and data.card.extra_data.kuangfu
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@@kuangfu_damage", 1)
  end,
})

return kuangfu
