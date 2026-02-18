-- SPDX-License-Identifier: GPL-3.0-or-later
-- 李儒 - 焚城技能
-- 限定技，出牌阶段，你可以令所有其他角色依次选择一项：
-- 1. 弃置至少X+1张牌（X为上一名进行选择的角色以此法弃置的牌数）；
-- 2. 受到你造成的2点火焰伤害。

local fengcheng = fk.CreateSkill {
  name = "fengcheng",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ["fengcheng"] = "焚城",
  [":fengcheng"] = "限定技，出牌阶段，你可以令所有其他角色依次选择一项："..
    "1. 弃置至少X+1张牌（X为上一名进行选择的角色以此法弃置的牌数）；2. 受到你造成的2点火焰伤害。",

  ["#fengcheng-invoke"] = "焚城：令所有其他角色弃牌或受到火焰伤害",
  ["#fengcheng-choice"] = "焚城：请选择一项",
  ["fengcheng_discard"] = "弃置至少%arg张牌",
  ["fengcheng_damage"] = "受到2点火焰伤害",

  ["$fengcheng1"] = "焚城之计，玉石俱焚！",
  ["$fengcheng2"] = "火烧连营，片甲不留！",
}

fengcheng:addEffect("active", {
  mute = true,
  prompt = "#fengcheng-invoke",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(fengcheng.name) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, fengcheng.name, "offensive")
    player:broadcastSkillInvoke(fengcheng.name)

    local others = room:getOtherPlayers(player, false)
    local last_discard_count = 0

    for _, p in ipairs(others) do
      if not p.dead then
        local min_discard = last_discard_count + 1
        local can_discard = p:getCardIds("he"):length() >= min_discard

        local choices = {"fengcheng_damage"}
        if can_discard then
          table.insert(choices, 1, "fengcheng_discard")
        end

        local choice = room:askToChoice(p, {
          choices = choices,
          skill_name = fengcheng.name,
          prompt = "#fengcheng-choice",
          detailed = false,
        })

        if choice == "fengcheng_discard" then
          -- 弃置至少min_discard张牌
          local max_discard = p:getCardIds("he"):length()

          local cards = room:askToCards(p, {
            min_num = min_discard,
            max_num = max_discard,
            include_equip = true,
            skill_name = fengcheng.name,
            pattern = ".",
            cancelable = false,
          })

          room:throwCard(cards, fengcheng.name, p, p)
          last_discard_count = #cards
        else
          -- 受到2点火焰伤害
          room:damage{
            from = player,
            to = p,
            damage = 2,
            damageType = fk.FireDamage,
            skillName = fengcheng.name,
          }
        end
      end
    end
  end,
})

return fengcheng
