-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 - 吴国武将包
local extension = Package:new("xinhan_wu")
extension.extensionName = "xinhanwujiang"

-- 加载技能
extension:loadSkillSkelsByPath("./packages/xinhanwujiang/pkg/wu/skills")

Fk:loadTranslationTable {
  ["xinhan_wu"] = "星汉灿烂·吴",
}

-- 孙坚，男，吴，4/5勾玉
local sunjian = General:new(extension, "xh__sunjian", "wu", 4, 5)
sunjian:addSkills { "xh__yinghun" }
Fk:loadTranslationTable {
  ["xh__sunjian"] = "孙坚",
  ["#xh__sunjian"] = "江东猛虎",
  ["illustrator:xh__sunjian"] = "KayaK",
  ["~xh__sunjian"] = "有埋伏……呃……",
}

-- 黄盖，男，吴，4勾玉
General:new(extension, "xh__huanggai", "wu", 4):addSkills { "xh__kurou", "xh__zhaxiang" }
Fk:loadTranslationTable {
  ["xh__huanggai"] = "黄盖",
  ["#xh__huanggai"] = "轻身为国",
  ["illustrator:xh__huanggai"] = "KayaK",
  ["~xh__huanggai"] = "再无……苦肉计了……",
}

-- 韩当，男，吴，4勾玉
General:new(extension, "xh__handang", "wu", 4):addSkills { "xh__gongqi", "xh__jiefan" }
Fk:loadTranslationTable {
  ["xh__handang"] = "韩当",
  ["#xh__handang"] = "石城侯",
  ["illustrator:xh__handang"] = "KayaK",
  ["~xh__handang"] = "江东……",
}

-- 孙权，男，吴，4勾玉
General:new(extension, "xh__sunquan", "wu", 4):addSkills { "xh__zhiheng" }
Fk:loadTranslationTable {
  ["xh__sunquan"] = "孙权",
  ["#xh__sunquan"] = "年轻的贤君",
  ["illustrator:xh__sunquan"] = "KayaK",
  ["~xh__sunquan"] = "父亲，大哥，仲谋愧矣……",
}

-- 孙坚(新)，男，吴，4/5勾玉
local sunjian_new = General:new(extension, "new__sunjian", "wu", 4, 5)
sunjian_new:addSkills { "xh__hulie" }
Fk:loadTranslationTable {
  ["new__sunjian"] = "孙坚",
  ["#new__sunjian"] = "江东猛虎",
  ["illustrator:new__sunjian"] = "KayaK",
  ["~new__sunjian"] = "有埋伏……呃……",
}

-- 孙策(吴)，男，吴，4勾玉
General:new(extension, "xh__sunce", "wu", 4):addSkills { "xh__jiang", "xh__hunzi" }
Fk:loadTranslationTable {
  ["xh__sunce"] = "孙策",
  ["#xh__sunce"] = "江东小霸王",
  ["illustrator:xh__sunce"] = "KayaK",
  ["~xh__sunce"] = "内事不决问张昭，外事不决问周瑜……",
}

-- 周瑜，男，吴，3勾玉
General:new(extension, "xh__zhouyu", "wu", 3):addSkills { "xh__yingzi", "xh__fanjian" }
Fk:loadTranslationTable {
  ["xh__zhouyu"] = "周瑜",
  ["#xh__zhouyu"] = "大都督",
  ["illustrator:xh__zhouyu"] = "KayaK",
  ["~xh__zhouyu"] = "既生瑜，何生亮……",
}

-- 庞统，男，吴，3勾玉
General:new(extension, "xh__pangtong", "wu", 3):addSkills { "xh__guolun", "xh__zhanji" }
Fk:loadTranslationTable {
  ["xh__pangtong"] = "庞统",
  ["#xh__pangtong"] = "凤雏",
  ["illustrator:xh__pangtong"] = "KayaK",
  ["~xh__pangtong"] = "落凤坡……",
}

return extension
