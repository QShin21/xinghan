-- SPDX-License-Identifier: GPL-3.0-or-later
-- 贾诩 - 乱武技能
-- 限定技，出牌阶段，你可以令所有其他角色依次选择一项：
-- 1. 对距离最近的另一名角色使用一张【杀】；2. 失去1点体力。
-- 若如此做，你可以视为使用一张无距离限制的【杀】。

local luanwu = fk.CreateSkill {
  name = "luanwu",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ["luanwu"] = "乱武",
  [":luanwu"] = "限定技，出牌阶段，你可以令所有其他角色依次选择一项："..
    "1. 对距离最近的另一名角色使用一张【杀】；2. 失去1点体力。"..
    "若如此做，你可以视为使用一张无距离限制的【杀】。",

  ["#luanwu-invoke"] = "乱武：发动乱武",
  ["#luanwu-choice"] = "乱武：请选择一项",
  ["luanwu_choice1"] = "对距离最近的角色使用一张【杀】",
  ["luanwu_choice2"] = "失去1点体力",
  ["#luanwu-slash"] = "乱武：你可以视为使用一张无距离限制的【杀】",

  ["$luanwu1"] = "哭喊吧，哀求吧，挣扎吧，然后……死吧！",
  ["$luanwu2"] = "让我看清楚你们那丑陋的嘴脸！",
}

luanwu:addEffect("active", {
  mute = true,
  prompt = "#luanwu-invoke",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(luanwu.name) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, luanwu.name, "offensive")
    player:broadcastSkillInvoke(luanwu.name)

    local others = room:getOtherPlayers(player, false)

    -- 所有其他角色依次选择
    for _, p in ipairs(others) do
      if not p.dead then
        -- 找到距离最近的角色
        local nearest = {}
        local min_distance = 999
        for _, other in ipairs(room:getOtherPlayers(p, false)) do
          local dist = p:distanceTo(other)
          if dist < min_distance then
            min_distance = dist
            nearest = {other}
          elseif dist == min_distance then
            table.insert(nearest, other)
          end
        end

        -- 检查是否可以使用杀
        local can_slash = false
        if #nearest > 0 then
          local slash = Fk:cloneCard("slash")
          for _, target in ipairs(nearest) do
            if p:canUseTo(slash, target) then
              can_slash = true
              break
            end
          end
        end

        local choices = {"luanwu_choice2"}  -- 默认可以失去体力
        if can_slash then
          table.insert(choices, 1, "luanwu_choice1")
        end

        local choice = room:askToChoice(p, {
          choices = choices,
          skill_name = luanwu.name,
          prompt = "#luanwu-choice",
          detailed = false,
        })

        if choice == "luanwu_choice1" then
          -- 使用杀
          local slash = Fk:cloneCard("slash")
          slash.skillName = luanwu.name

          local targets = table.filter(nearest, function(target)
            return p:canUseTo(slash, target)
          end)

          if #targets > 0 then
            local to = room:askToChoosePlayers(p, {
              min_num = 1,
              max_num = 1,
              targets = targets,
              skill_name = luanwu.name,
              prompt = "选择距离最近的一名角色使用【杀】",
              cancelable = false,
            })[1]

            room:useCard{
              from = p.id,
              tos = {to.id},
              card = slash,
            }
          end
        else
          -- 失去1点体力
          room:loseHp(p, 1, luanwu.name)
        end
      end
    end

    -- 可以视为使用一张杀
    if not player.dead then
      local slash = Fk:cloneCard("slash")
      slash.skillName = luanwu.name

      local targets = table.filter(room:getOtherPlayers(player, false), function(p)
        return player:canUseTo(slash, p)
      end)

      if #targets > 0 then
        local use = room:askToUseCard(player, {
          skill_name = luanwu.name,
          pattern = slash,
          prompt = "#luanwu-slash",
          cancelable = true,
        })

        if use then
          use.card.skillName = luanwu.name
          room:useCard(use)
        end
      end
    end
  end,
})

return luanwu
