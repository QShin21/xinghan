-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 - 群雄武将包
local extension = Package:new("xinhan_qun")
extension.extensionName = "xinhanwujiang"

-- 加载技能
extension:loadSkillSkelsByPath("./packages/xinhanwujiang/pkg/qun/skills")

Fk:loadTranslationTable {
  ["xinhan_qun"] = "星汉灿烂·群",
}

-- 贾诩，男，群，3勾玉
General:new(extension, "xh__jiaxu", "qun", 3):addSkills { "wansha", "luanwu", "weimu" }
Fk:loadTranslationTable {
  ["xh__jiaxu"] = "贾诩",
  ["#xh__jiaxu"] = "冷酷的毒士",
  ["illustrator:xh__jiaxu"] = "KayaK",
  ["~xh__jiaxu"] = "我的时辰……到了……",
}

-- 吕布，男，群，5勾玉
General:new(extension, "xh__lvbu", "qun", 5):addSkills { "wushuang", "liyu" }
Fk:loadTranslationTable {
  ["xh__lvbu"] = "吕布",
  ["#xh__lvbu"] = "武的化身",
  ["illustrator:xh__lvbu"] = "KayaK",
  ["~xh__lvbu"] = "不可能！",
}

-- 貂蝉，女，群，3勾玉
General:new(extension, "xh__diaochan", "qun", 3, 3, General.Female):addSkills { "biyue" }
Fk:loadTranslationTable {
  ["xh__diaochan"] = "貂蝉",
  ["#xh__diaochan"] = "绝世的舞姬",
  ["illustrator:xh__diaochan"] = "KayaK",
  ["~xh__diaochan"] = "父亲大人，对不起……",
}

-- 董卓，男，群，4勾玉
General:new(extension, "xh__dongzhuo", "qun", 4):addSkills { "jiuchi", "hengzheng" }
Fk:loadTranslationTable {
  ["xh__dongzhuo"] = "董卓",
  ["#xh__dongzhuo"] = "魔王",
  ["illustrator:xh__dongzhuo"] = "KayaK",
  ["~xh__dongzhuo"] = "汉室……亡了……",
}

-- 袁绍，男，群，4勾玉
General:new(extension, "xh__yuanshao", "qun", 4):addSkills { "luanji" }
Fk:loadTranslationTable {
  ["xh__yuanshao"] = "袁绍",
  ["#xh__yuanshao"] = "高贵的名门",
  ["illustrator:xh__yuanshao"] = "KayaK",
  ["~xh__yuanshao"] = "老天不公啊！",
}

-- 田丰，男，群，3勾玉
General:new(extension, "xh__tianfeng", "qun", 3):addSkills { "sijian", "suishi" }
Fk:loadTranslationTable {
  ["xh__tianfeng"] = "田丰",
  ["#xh__tianfeng"] = "河北谋士",
  ["illustrator:xh__tianfeng"] = "KayaK",
  ["~xh__tianfeng"] = "吾命休矣……",
}

-- 马腾，男，群，4勾玉
General:new(extension, "xh__mateng", "qun", 4):addSkills { "mashu", "xiongyi" }
Fk:loadTranslationTable {
  ["xh__mateng"] = "马腾",
  ["#xh__mateng"] = "西凉太守",
  ["illustrator:xh__mateng"] = "KayaK",
  ["~xh__mateng"] = "西凉……完了……",
}

-- 李儒，男，群，3勾玉
General:new(extension, "xh__liru", "qun", 3):addSkills { "mieji", "juece", "fengcheng" }
Fk:loadTranslationTable {
  ["xh__liru"] = "李儒",
  ["#xh__liru"] = "魔士",
  ["illustrator:xh__liru"] = "KayaK",
  ["~xh__liru"] = "主公……",
}

-- 高顺，男，群，4勾玉
General:new(extension, "xh__gaoshun", "qun", 4):addSkills { "xianzhen", "jinjiu" }
Fk:loadTranslationTable {
  ["xh__gaoshun"] = "高顺",
  ["#xh__gaoshun"] = "陷阵营主",
  ["illustrator:xh__gaoshun"] = "KayaK",
  ["~xh__gaoshun"] = "陷阵……败了……",
}

-- 孙策(群)，男，群，4勾玉
General:new(extension, "xh__sunce_qun", "qun", 4):addSkills { "liantao" }
Fk:loadTranslationTable {
  ["xh__sunce_qun"] = "孙策",
  ["#xh__sunce_qun"] = "江东小霸王",
  ["illustrator:xh__sunce_qun"] = "KayaK",
  ["~xh__sunce_qun"] = "大业未成……",
}

-- 刘表，男，群，3勾玉
General:new(extension, "xh__liubiao", "qun", 3):addSkills { "zishou", "zongshi" }
Fk:loadTranslationTable {
  ["xh__liubiao"] = "刘表",
  ["#xh__liubiao"] = "荆州牧",
  ["illustrator:xh__liubiao"] = "KayaK",
  ["~xh__liubiao"] = "荆州……",
}

-- 杨彪，男，群，3勾玉
General:new(extension, "xh__yangbiao", "qun", 3):addSkills { "zhaohan", "rangjie", "yizheng" }
Fk:loadTranslationTable {
  ["xh__yangbiao"] = "杨彪",
  ["#xh__yangbiao"] = "汉室忠臣",
  ["illustrator:xh__yangbiao"] = "KayaK",
  ["~xh__yangbiao"] = "汉室……",
}

-- 张角，男，群，3勾玉
General:new(extension, "xh__zhangjiao", "qun", 3):addSkills { "leiji", "guidao" }
Fk:loadTranslationTable {
  ["xh__zhangjiao"] = "张角",
  ["#xh__zhangjiao"] = "天公将军",
  ["illustrator:xh__zhangjiao"] = "KayaK",
  ["~xh__zhangjiao"] = "黄天……",
}

-- 于吉，男，群，3勾玉
General:new(extension, "xh__yuji", "qun", 3):addSkills { "guhuo" }
Fk:loadTranslationTable {
  ["xh__yuji"] = "于吉",
  ["#xh__yuji"] = "太平道人",
  ["illustrator:xh__yuji"] = "KayaK",
  ["~xh__yuji"] = "蛊惑……",
}

-- 李傕，男，群，4勾玉
General:new(extension, "xh__lijue", "qun", 4):addSkills { "langxi", "yisuan" }
Fk:loadTranslationTable {
  ["xh__lijue"] = "李傕",
  ["#xh__lijue"] = "狼子野心",
  ["illustrator:xh__lijue"] = "KayaK",
  ["~xh__lijue"] = "西凉……",
}

-- 郭汜，男，群，4勾玉
General:new(extension, "xh__guosi", "qun", 4):addSkills { "tanbei", "sidao" }
Fk:loadTranslationTable {
  ["xh__guosi"] = "郭汜",
  ["#xh__guosi"] = "贪婪之徒",
  ["illustrator:xh__guosi"] = "KayaK",
  ["~xh__guosi"] = "西凉……",
}

-- 王允，男，群，3勾玉
General:new(extension, "xh__wangyun", "qun", 3):addSkills { "jiexuan", "zhongliu" }
Fk:loadTranslationTable {
  ["xh__wangyun"] = "王允",
  ["#xh__wangyun"] = "连环计主",
  ["illustrator:xh__wangyun"] = "KayaK",
  ["~xh__wangyun"] = "汉室……",
}

-- 张济，男，群，4勾玉
General:new(extension, "xh__zhangji_qun", "qun", 4):addSkills { "lueling", "tunjun" }
Fk:loadTranslationTable {
  ["xh__zhangji_qun"] = "张济",
  ["#xh__zhangji_qun"] = "西凉军阀",
  ["illustrator:xh__zhangji_qun"] = "KayaK",
  ["~xh__zhangji_qun"] = "西凉……",
}

-- 徐荣，男，群，4勾玉
General:new(extension, "xh__xurong", "qun", 4):addSkills { "xionghuo" }
Fk:loadTranslationTable {
  ["xh__xurong"] = "徐荣",
  ["#xh__xurong"] = "凶镬之将",
  ["illustrator:xh__xurong"] = "KayaK",
  ["~xh__xurong"] = "西凉……",
}

-- 公孙瓒，男，群，4勾玉
General:new(extension, "xh__gongsunzan", "qun", 4):addSkills { "qiaomeng", "yicong" }
Fk:loadTranslationTable {
  ["xh__gongsunzan"] = "公孙瓒",
  ["#xh__gongsunzan"] = "白马将军",
  ["illustrator:xh__gongsunzan"] = "KayaK",
  ["~xh__gongsunzan"] = "白马……",
}

-- 韩遂，男，群，4勾玉
General:new(extension, "xh__hansui", "qun", 4):addSkills { "niluan", "xiaoxi" }
Fk:loadTranslationTable {
  ["xh__hansui"] = "韩遂",
  ["#xh__hansui"] = "西凉军阀",
  ["illustrator:xh__hansui"] = "KayaK",
  ["~xh__hansui"] = "西凉……",
}

-- 鲍信，男，群，4勾玉
General:new(extension, "xh__baoxin", "qun", 4):addSkills { "mutao", "yimou" }
Fk:loadTranslationTable {
  ["xh__baoxin"] = "鲍信",
  ["#xh__baoxin"] = "义兵首领",
  ["illustrator:xh__baoxin"] = "KayaK",
  ["~xh__baoxin"] = "义兵……",
}

-- 孔融，男，群，3勾玉
General:new(extension, "xh__kongrong", "qun", 3):addSkills { "mingshi", "lirang" }
Fk:loadTranslationTable {
  ["xh__kongrong"] = "孔融",
  ["#xh__kongrong"] = "名士",
  ["illustrator:xh__kongrong"] = "KayaK",
  ["~xh__kongrong"] = "名士……",
}


-- 华雄，男，群，4勾玉
General:new(extension, "xh__huaxiong", "qun", 4):addSkills { "yaowu", "yangwei" }
Fk:loadTranslationTable {
  ["xh__huaxiong"] = "华雄",
  ["#xh__huaxiong"] = "西凉猛将",
  ["illustrator:xh__huaxiong"] = "KayaK",
  ["~xh__huaxiong"] = "西凉……",
}

-- 袁术，男，群，4勾玉
General:new(extension, "xh__yuanshu", "qun", 4):addSkills { "yongsi" }
Fk:loadTranslationTable {
  ["xh__yuanshu"] = "袁术",
  ["#xh__yuanshu"] = "仲家",
  ["illustrator:xh__yuanshu"] = "KayaK",
  ["~xh__yuanshu"] = "仲家……",
}

-- 潘凤，男，群，4勾玉
General:new(extension, "xh__panfeng", "qun", 4):addSkills { "kuangfu" }
Fk:loadTranslationTable {
  ["xh__panfeng"] = "潘凤",
  ["#xh__panfeng"] = "无双上将",
  ["illustrator:xh__panfeng"] = "KayaK",
  ["~xh__panfeng"] = "上将……",
}

-- 纪灵，男，群，4勾玉
General:new(extension, "xh__jiling", "qun", 4):addSkills { "shuangren" }
Fk:loadTranslationTable {
  ["xh__jiling"] = "纪灵",
  ["#xh__jiling"] = "山东名将",
  ["illustrator:xh__jiling"] = "KayaK",
  ["~xh__jiling"] = "山东……",
}

-- 颜良文丑，男，群，4勾玉
General:new(extension, "xh__yanliangwenchou", "qun", 4):addSkills { "shuangxiong" }
Fk:loadTranslationTable {
  ["xh__yanliangwenchou"] = "颜良文丑",
  ["#xh__yanliangwenchou"] = "虎狼兄弟",
  ["illustrator:xh__yanliangwenchou"] = "KayaK",
  ["~xh__yanliangwenchou"] = "河北……",
}

-- 牛辅，男，群，4/5勾玉
local niufu = General:new(extension, "xh__niufu", "qun", 4, 5)
niufu:addSkills { "xiaoxiong", "xiongrao" }
Fk:loadTranslationTable {
  ["xh__niufu"] = "牛辅",
  ["#xh__niufu"] = "西凉女婿",
  ["illustrator:xh__niufu"] = "KayaK",
  ["~xh__niufu"] = "西凉……",
}

-- 刘备(群)，男，群，4勾玉
General:new(extension, "xh__liubei_qun", "qun", 4):addSkills { "jishan", "zhenqia" }
Fk:loadTranslationTable {
  ["xh__liubei_qun"] = "刘备",
  ["#xh__liubei_qun"] = "乱世枭雄",
  ["illustrator:xh__liubei_qun"] = "KayaK",
  ["~xh__liubei_qun"] = "乱世……",
}

-- 武安国，男，群，4勾玉
General:new(extension, "xh__wuananguo", "qun", 4):addSkills { "liyong" }
Fk:loadTranslationTable {
  ["xh__wuananguo"] = "武安国",
  ["#xh__wuananguo"] = "断腕猛将",
  ["illustrator:xh__wuananguo"] = "KayaK",
  ["~xh__wuananguo"] = "北海……",
}

-- 杨奉，男，群，4勾玉
General:new(extension, "xh__yangfeng", "qun", 4):addSkills { "xuetu" }
Fk:loadTranslationTable {
  ["xh__yangfeng"] = "杨奉",
  ["#xh__yangfeng"] = "白波军帅",
  ["illustrator:xh__yangfeng"] = "KayaK",
  ["~xh__yangfeng"] = "白波……",
}

-- 张燕，男，群，4勾玉
General:new(extension, "xh__zhangyan", "qun", 4):addSkills { "suji", "langdao" }
Fk:loadTranslationTable {
  ["xh__zhangyan"] = "张燕",
  ["#xh__zhangyan"] = "黑山军帅",
  ["illustrator:xh__zhangyan"] = "KayaK",
  ["~xh__zhangyan"] = "黑山……",
}

-- 梁兴，男，群，4勾玉
General:new(extension, "xh__liangxing", "qun", 4):addSkills { "lulve" }
Fk:loadTranslationTable {
  ["xh__liangxing"] = "梁兴",
  ["#xh__liangxing"] = "西凉悍将",
  ["illustrator:xh__liangxing"] = "KayaK",
  ["~xh__liangxing"] = "西凉……",
}

-- 黄祖，男，群，4勾玉
General:new(extension, "xh__huangzu", "qun", 4):addSkills { "xishe" }
Fk:loadTranslationTable {
  ["xh__huangzu"] = "黄祖",
  ["#xh__huangzu"] = "江夏太守",
  ["illustrator:xh__huangzu"] = "KayaK",
  ["~xh__huangzu"] = "江夏……",
}

-- 沮授，男，群，3勾玉
General:new(extension, "xh__jushou", "qun", 3):addSkills { "jianying", "shibei" }
Fk:loadTranslationTable {
  ["xh__jushou"] = "沮授",
  ["#xh__jushou"] = "河北谋士",
  ["illustrator:xh__jushou"] = "KayaK",
  ["~xh__jushou"] = "河北……",
}

-- 张绣，男，群，4勾玉
General:new(extension, "xh__zhangxiu", "qun", 4):addSkills { "fudi", "congjian" }
Fk:loadTranslationTable {
  ["xh__zhangxiu"] = "张绣",
  ["#xh__zhangxiu"] = "宛城侯",
  ["illustrator:xh__zhangxiu"] = "KayaK",
  ["~xh__zhangxiu"] = "宛城……",
}

-- 刘繇，男，群，4勾玉
General:new(extension, "xh__liuyao", "qun", 4):addSkills { "kannan" }
Fk:loadTranslationTable {
  ["xh__liuyao"] = "刘繇",
  ["#xh__liuyao"] = "扬州刺史",
  ["illustrator:xh__liuyao"] = "KayaK",
  ["~xh__liuyao"] = "扬州……",
}

-- 邹氏，女，群，3勾玉
General:new(extension, "xh__zoushi", "qun", 3, 3, General.Female):addSkills { "huoshui", "qingcheng" }
Fk:loadTranslationTable {
  ["xh__zoushi"] = "邹氏",
  ["#xh__zoushi"] = "祸水红颜",
  ["illustrator:xh__zoushi"] = "KayaK",
  ["~xh__zoushi"] = "祸水……",
}

-- 许攸，男，群，3勾玉
General:new(extension, "xh__xuyou", "qun", 3):addSkills { "chenglue", "shicai" }
Fk:loadTranslationTable {
  ["xh__xuyou"] = "许攸",
  ["#xh__xuyou"] = "恃才傲物",
  ["illustrator:xh__xuyou"] = "KayaK",
  ["~xh__xuyou"] = "恃才……",
}

-- 刘协，男，群，3勾玉
General:new(extension, "xh__liuxie", "qun", 3):addSkills { "tianming", "mizhao" }
Fk:loadTranslationTable {
  ["xh__liuxie"] = "刘协",
  ["#xh__liuxie"] = "汉献帝",
  ["illustrator:xh__liuxie"] = "KayaK",
  ["~xh__liuxie"] = "汉室……",
}

-- 士燮，男，群，3勾玉
General:new(extension, "xh__shixie", "qun", 3):addSkills { "biluan", "lixia" }
Fk:loadTranslationTable {
  ["xh__shixie"] = "士燮",
  ["#xh__shixie"] = "交州牧",
  ["illustrator:xh__shixie"] = "KayaK",
  ["~xh__shixie"] = "交州……",
}

-- 陶谦，男，群，3勾玉
General:new(extension, "xh__taoqian", "qun", 3):addSkills { "yixiang" }
Fk:loadTranslationTable {
  ["xh__taoqian"] = "陶谦",
  ["#xh__taoqian"] = "徐州牧",
  ["illustrator:xh__taoqian"] = "KayaK",
  ["~xh__taoqian"] = "徐州……",
}

-- 张鲁，男，群，3勾玉
General:new(extension, "xh__zhanglu", "qun", 3):addSkills { "yishe", "bushi", "midao" }
Fk:loadTranslationTable {
  ["xh__zhanglu"] = "张鲁",
  ["#xh__zhanglu"] = "汉中太守",
  ["illustrator:xh__zhanglu"] = "KayaK",
  ["~xh__zhanglu"] = "汉中……",
}

-- 陈宫，男，群，3勾玉
General:new(extension, "xh__chengong", "qun", 3):addSkills { "mingce", "yinpan" }
Fk:loadTranslationTable {
  ["xh__chengong"] = "陈宫",
  ["#xh__chengong"] = "智计之士",
  ["illustrator:xh__chengong"] = "KayaK",
  ["~xh__chengong"] = "智计……",
}

-- 公孙度，男，群，4勾玉
General:new(extension, "xh__gongsundu", "qun", 4):addSkills { "zhenze", "anliao" }
Fk:loadTranslationTable {
  ["xh__gongsundu"] = "公孙度",
  ["#xh__gongsundu"] = "辽东太守",
  ["illustrator:xh__gongsundu"] = "KayaK",
  ["~xh__gongsundu"] = "辽东……",
}

-- 高干，男，群，4勾玉
General:new(extension, "xh__gaogan", "qun", 4):addSkills { "juguan" }
Fk:loadTranslationTable {
  ["xh__gaogan"] = "高干",
  ["#xh__gaogan"] = "并州刺史",
  ["illustrator:xh__gaogan"] = "KayaK",
  ["~xh__gaogan"] = "并州……",
}

-- 许贡，男，群，3勾玉
General:new(extension, "xh__xugong", "qun", 3):addSkills { "biaozhao" }
Fk:loadTranslationTable {
  ["xh__xugong"] = "许贡",
  ["#xh__xugong"] = "吴郡太守",
  ["illustrator:xh__xugong"] = "KayaK",
  ["~xh__xugong"] = "吴郡……",
}

-- 袁谭袁尚袁熙，男，群，4勾玉
General:new(extension, "xh__yuantanyuanshangyuanxi", "qun", 4):addSkills { "neifa" }
Fk:loadTranslationTable {
  ["xh__yuantanyuanshangyuanxi"] = "袁谭袁尚袁熙",
  ["#xh__yuantanyuanshangyuanxi"] = "袁氏兄弟",
  ["illustrator:xh__yuantanyuanshangyuanxi"] = "KayaK",
  ["~xh__yuantanyuanshangyuanxi"] = "袁氏……",
}

-- 刘辟，男，群，4勾玉
General:new(extension, "xh__liupi", "qun", 4):addSkills { "yicheng" }
Fk:loadTranslationTable {
  ["xh__liupi"] = "刘辟",
  ["#xh__liupi"] = "黄巾渠帅",
  ["illustrator:xh__liupi"] = "KayaK",
  ["~xh__liupi"] = "黄巾……",
}

-- 段煨，男，群，4勾玉
General:new(extension, "xh__duanwei", "qun", 4):addSkills { "langmie" }
Fk:loadTranslationTable {
  ["xh__duanwei"] = "段煨",
  ["#xh__duanwei"] = "忠义之士",
  ["illustrator:xh__duanwei"] = "KayaK",
  ["~xh__duanwei"] = "忠义……",
}

-- 张郃，男，群，4勾玉
General:new(extension, "xh__zhanghe_qun", "qun", 4):addSkills { "zhouxuan" }
Fk:loadTranslationTable {
  ["xh__zhanghe_qun"] = "张郃",
  ["#xh__zhanghe_qun"] = "巧变之士",
  ["illustrator:xh__zhanghe_qun"] = "KayaK",
  ["~xh__zhanghe_qun"] = "巧变……",
}

-- 樊稠，男，群，4勾玉
General:new(extension, "xh__fanchou", "qun", 4):addSkills { "xingluan" }
Fk:loadTranslationTable {
  ["xh__fanchou"] = "樊稠",
  ["#xh__fanchou"] = "西凉悍将",
  ["illustrator:xh__fanchou"] = "KayaK",
  ["~xh__fanchou"] = "西凉……",
}

-- 董卓(新)，男，群，4勾玉
General:new(extension, "xh__dongzhuo_new", "qun", 4):addSkills { "xiongni", "fengshang" }
Fk:loadTranslationTable {
  ["xh__dongzhuo_new"] = "董卓",
  ["#xh__dongzhuo_new"] = "魔王",
  ["illustrator:xh__dongzhuo_new"] = "KayaK",
  ["~xh__dongzhuo_new"] = "汉室……亡了……",
}

-- 郭图，男，群，3勾玉
General:new(extension, "xh__guotu", "qun", 3):addSkills { "qushi", "weijie" }
Fk:loadTranslationTable {
  ["xh__guotu"] = "郭图",
  ["#xh__guotu"] = "河北谋士",
  ["illustrator:xh__guotu"] = "KayaK",
  ["~xh__guotu"] = "河北……",
}

-- 张辽(群)，男，群，4勾玉
General:new(extension, "xh__zhangliao_qun", "qun", 4):addSkills { "mubing", "ziqu" }
Fk:loadTranslationTable {
  ["xh__zhangliao_qun"] = "张辽",
  ["#xh__zhangliao_qun"] = "雁门张辽",
  ["illustrator:xh__zhangliao_qun"] = "KayaK",
  ["~xh__zhangliao_qun"] = "雁门……",
}

-- 刘璋，男，群，3勾玉
General:new(extension, "xh__liuzhang", "qun", 3):addSkills { "jutu", "yaohu" }
Fk:loadTranslationTable {
  ["xh__liuzhang"] = "刘璋",
  ["#xh__liuzhang"] = "益州牧",
  ["illustrator:xh__liuzhang"] = "KayaK",
  ["~xh__liuzhang"] = "益州……",
}
return extension
