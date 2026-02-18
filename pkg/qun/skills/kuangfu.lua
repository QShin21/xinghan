-- SPDX-License-Identifier: GPL-3.0-or-later
-- 潘凤 - 狂斧技能
-- 出牌阶段限一次，你可以弃置一名角色装备区里的一张牌，然后视为使用一张无距离和次数限制的【杀】，
-- 当此【杀】结算结束后：若你以此法弃置的为你的牌且此【杀】造成过伤害，你摸两张牌；
-- 若你以此法弃置的不为你的牌且此【杀】未造成过伤害，你弃置两张手牌。

local kuangfu = fk.CreateSkill {
  name = "kuangfu",
}

Fk:loadTranslationTable {
  ["kuangfu"] = "狂斧",
  [":kuangfu"] = "出牌阶段限一次，你可以弃置一名角色装备区里的一张牌，然后视为使用一张无距离和次数限制的【杀】，"..
    "当此【杀】结算结束后：若你以此法弃置的为你的牌且此【杀】造成过伤害，你摸两张牌；"..
    "若你以此法弃置的不为你的牌且此【杀】未造成过伤害，你弃置两张手牌。",

  ["#kuangfu-choose"] = "狂斧：弃置一名角色装备区的一张牌，然后视为使用【杀】",

  ["$kuangfu1"] = "狂斧一出，谁敢争锋！",
  ["$kuangfu2"] = "吾乃上将潘凤，可斩华雄！",
}

kuangfu:addEffect("active", {
  mute = true,
  prompt = "#kuangfu-choose",
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

    -- 选择装备区的牌
    local id = room:askToChooseCard(player, {
      target = target,
      flag = "e",
      skill_name = kuangfu.name,
    })

    local is_own_card = (target == player)
    local card = Fk:getCardById(id)

    -- 弃置牌
    room:throwCard(id, kuangfu.name, target, player)

    -- 视为使用杀
    local slash = Fk:cloneCard("slash")
    slash.skillName = kuangfu.name

    -- 选择杀的目标
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return player:canUseTo(slash, p)
    end)

    if #targets > 0 then
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = kuangfu.name,
        prompt = "选择【杀】的目标",
        cancelable = false,
      })[1]

      local hp_before = to.hp

      room:useCard{
        from = player.id,
        tos = {to.id},
        card = slash,
        extra_data = {bypass_distances = true, bypass_times = true},
      }

      -- 检查是否造成伤害
      local damaged = (to.hp < hp_before)

      if is_own_card and damaged then
        -- 弃置自己的牌且造成伤害：摸两张牌
        if not player.dead then
          player:drawCards(2, kuangfu.name)
        end
      elseif not is_own_card and not damaged then
        -- 弃置别人的牌且未造成伤害：弃置两张手牌
        if not player.dead and player:getHandcardNum() >= 2 then
          local cards = room:askToCards(player, {
            min_num = 2,
            max_num = 2,
            include_equip = false,
            skill_name = kuangfu.name,
            pattern = ".",
            cancelable = false,
          })
          room:throwCard(cards, kuangfu.name, player, player)
        end
      end
    end
  end,
})

return kuangfu
