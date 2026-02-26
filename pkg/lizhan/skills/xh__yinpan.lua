local yinpan = fk.CreateSkill {
  name = "xh__yinpan",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable{
  ["xh__yinpan"] = "引叛",
  [":xh__yinpan"] = "限定技，出牌阶段，你可以对对手造成X点伤害（X为对手因"明策"摸牌的次数）。",

  ["#xh__yinpan-invoke"] = "引叛：是否对对手造成伤害？",
  ["@@xh__yinpan_count"] = "引叛计数",

  ["$xh__yinpan1"] = "引叛之计，借刀杀人！",
  ["$xh__yinpan2"] = "陈宫引叛，天下大乱！",
}

-- 获取目标因明策摸牌的次数
local function getMingceDrawCount(player)
  local mark = player:getTableMark("@@xh__yinpan_count")
  if type(mark) == "table" then
    return #mark
  elseif type(mark) == "number" then
    return mark
  end
  return 0
end

yinpan:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(yinpan.name) then return false end
    if player.phase ~= Player.Play then return false end
    if player:usedSkillTimes(yinpan.name, Player.HistoryGame) > 0 then return false end

    -- 检查是否有对手因明策摸过牌
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      if getMingceDrawCount(p) > 0 then
        return true
      end
    end
    return false
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yinpan.name,
      prompt = "#xh__yinpan-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 找出因明策摸过牌的对手
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      local count = getMingceDrawCount(p)
      if count > 0 then
        table.insert(targets, {player = p, count = count})
      end
    end

    if #targets == 0 then return end

    -- 对每个因明策摸过牌的对手造成伤害
    for _, t in ipairs(targets) do
      if not t.player.dead then
        room:damage{
          from = player,
          to = t.player,
          damage = t.count,
          skillName = yinpan.name,
        }
      end
      -- 清空该玩家的明策摸牌计数
      room:setPlayerMark(t.player, "@@xh__yinpan_count", 0)
    end
  end,
})

return yinpan
