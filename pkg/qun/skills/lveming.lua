-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张济 - 掠命技能
-- 出牌阶段限一次，你可以令一名装备区的牌数小于你的其他角色声明一个点数，
-- 然后你进行判定，若结果的点数与其声明的：相同，你对其造成2点伤害；不同，其交给你一张手牌。

local lveming = fk.CreateSkill {
  name = "lveming",
}

Fk:loadTranslationTable {
  ["lveming"] = "掠命",
  [":lveming"] = "出牌阶段限一次，你可以令一名装备区的牌数小于你的其他角色声明一个点数，"..
    "然后你进行判定，若结果的点数与其声明的：相同，你对其造成2点伤害；不同，其交给你一张手牌。",

  ["#lveming-choose"] = "掠命：选择一名装备区牌数小于你的角色",
  ["#lveming-declare"] = "掠命：声明一个点数",
  ["#lveming-give"] = "掠命：交给对方一张手牌",

  ["$lveming1"] = "掠人钱财，夺人性命！",
  ["$lveming2"] = "命悬一线，生死由天！",
}

lveming:addEffect("active", {
  mute = true,
  prompt = "#lveming-choose",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(lveming.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    if to_select == player then return false end

    local my_equip = #player:getCardIds("e")
    local their_equip = #to_select:getCardIds("e")

    return their_equip < my_equip
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, lveming.name, "offensive", {target})
    player:broadcastSkillInvoke(lveming.name)

    -- 目标声明一个点数
    local numbers = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
    local declared = room:askToChoice(target, {
      choices = numbers,
      skill_name = lveming.name,
      prompt = "#lveming-declare",
      detailed = false,
    })

    -- 进行判定
    local judge = {
      who = player,
      reason = lveming.name,
      pattern = ".",
    }
    room:judge(judge)

    local judge_card = Fk:getCardById(judge.card.id)
    local judge_number = judge_card:getNumberStr()

    -- 比较点数
    if judge_number == declared then
      -- 相同：造成2点伤害
      room:damage{
        from = player,
        to = target,
        damage = 2,
        skillName = lveming.name,
      }
    else
      -- 不同：交给你一张手牌
      if not target.dead and not target:isKongcheng() then
        local card = room:askToCards(target, {
          min_num = 1,
          max_num = 1,
          include_equip = false,
          skill_name = lveming.name,
          pattern = ".",
          prompt = "#lveming-give",
          cancelable = false,
        })

        room:moveCardTo(card, Player.Hand, player, fk.ReasonGive, lveming.name, nil, false, target.id)
      end
    end

    -- 记录发动次数
    room:addPlayerMark(player, "@@lveming_count", 1)
  end,
})

return lveming
