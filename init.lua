-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂武将包 - 主入口文件

local prefix = "packages.xinhanwujiang.pkg."

-- 加载子扩展包
local wei = require(prefix .. "wei")
local shu = require(prefix .. "shu")
local wu = require(prefix .. "wu")
local qun = require(prefix .. "qun")

Fk:loadTranslationTable {
  ["xinhanwujiang"] = "星汉武将",
}

return {
  wei,
  shu,
  wu,
  qun,
}
