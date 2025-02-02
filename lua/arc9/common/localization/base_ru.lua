L = {}

/////////////////////////////////////// Font
////////////////////// See "font_en" file

/////////////////////////////////////// General
////////////////////// Translation
L["translation.name"] = "Russian Translation by"
L["translation.authors"] = "darsu"

--[[
"translation.name" should be changed to "English Translation" but translated
		for example "Deutsche Übersetzung", "Svensk Översättning", etc.

If set to false, both of these will not show.

"translation.authors" should include the list of the translators. For example, "Moka" or "darsu".
--]]

////////////////////// Units of measurement
L["unit.second"] = "с"
L["unit.meter"] = "м"
L["unit.millimeter"] = "мм"
L["unit.meterpersecond"] = "м/с"
L["unit.hammerunit"] = "HU"
L["unit.decibel"] = "дБ"
L["unit.rpm"] = "RPM"
L["unit.moa"] = "MOA"
L["unit.dmg"] = "DMG"
L["unit.projectiles"] = "PROJ"

L["unit.inch"] = "in"
L["unit.foot"] = "ft"
L["unit.footpersecond"] = "ft/s"
L["unit.yard"] = "yd"

////////////////////// Ammo types
L["ammo.pistol"] = "Пистолет. патрон"
L["ammo.357"] = "Магнум патроны"
L["ammo.smg1"] = "Карабин. патроны"
L["ammo.ar2"] = "Винтов. патроны"
L["ammo.buckshot"] = "Дробов. патроны"
L["ammo.sniperpenetratedround"] = "Снайп. патроны"
L["ammo.smg1_grenade"] = "Гранаты"
L["ammo.xbowbolt"] = "Арбалет. болты"
L["ammo.rpg_round"] = "Ракеты"
L["ammo.grenade"] = "Гранаты"
L["ammo.slam"] = "SLAM"
L["ammo.alyxgun"] = "Alyx Gun патроны"

/////////////////////////////////////// HUD
L["hud.version"] = "ARCTIC SYSTEMS HUD v"
L["hud.jammed"] = "КЛИН!"
L["hud.therm_deco"] = "ТЕМП. СТВОЛА"

L["hud.firemode.single"] = "ОДИНОЧ."
L["hud.firemode.burst"] = "ОЧЕРЕДЬ"
L["hud.firemode.auto"] = "АВТОМАТ."
L["hud.firemode.safe"] = "ПРЕДОХР."

L["hud.hint.bash"] = "УДАР"
L["hud.hint.bipod"] = "Сошки"
L["hud.hint.breath"] = "ЗАДЕРЖАТЬ ДЫХАНИЕ"
L["hud.hint.customize"] = "КАСТОМИЗАЦИЯ"
L["hud.hint.cycle"] = "ВЗВОД ЗАТВОРА"
L["hud.hint.firemode"] = "СМЕНА РЕЖИМА ОГНЯ"
L["hud.hint.inspect"] = "ОСМОТР"
L["hud.hint.lean"] = "НАКЛОН"
L["hud.hint.peek"] = "ВЫГЛЯНУТЬ"
L["hud.hint.reload"] = "Перезарядка!"
L["hud.hint.safe"] = "ПРЕДОХРАНИТЕЛЬ"
L["hud.hint.switchsights"] = "СМЕНИТЬ ПРИЦЕЛ"
L["hud.hint.toggleatts"] = "ПЕРЕКЛ. МОДУЛЬ"
L["hud.hint.ubgl"] = "ПЕРЕКЛ. НА"
-- L["hud.hint.unjam"] = "Unjam"
L["hud.hint.zoom"] = "СМЕНА КРАТНОСТИ"
L["hud.hint.quicknade"] = "КИНУТЬ «%s»"

L["hud.hint.lowammo"] = "Мало патрон"
L["hud.hint.noammo"] = "Нет патрон"

L["hud.error.missingbind"] = "Нет бинда для %s"
L["hud.error.missingbind_zoom"] = "Забиндь \"Приблизить\" в настройках игры!"
L["hud.error.missingbind_context"] = "Забиндь \"Open Context Menu\" в настройках игры!"
L["hud.error.missingbind_flight"] = "Забиндь \"Фонарик\" в настройках игры!"
L["hud.error.missingbind_use"] = "Забиндь \"Использовать\" в настройках игры!"
L["hud.error.missingbind_invnext"] = "Забиндь \"След. оруж.\" в настройках игры!"
L["hud.error.missingbind_invprev"] = "Забиндь \"Пред. оруж.\" в настройках игры!"

/////////////////////////////////////// Customization menu
L["customize.panel.customize"] = "КАСТОМИЗАЦИЯ"
L["customize.panel.personalize"] = "КОСМЕТИКА"
L["customize.panel.stats"] = "ХАР-КИ & БАЛЛИСТИКА"
L["customize.panel.trivia"] = "ИНФО"
L["customize.panel.inspect"] = "ОСМОТР"
L["customize.panel.presets"] = "Пресеты"

L["customize.stats.aimtime"] = "Скорость прицел."
L["customize.stats.ammo"] = "Тип патрона"
L["customize.stats.armorpiercing"] = "Бронепробиваемость"
L["customize.stats.burstdelay"] = "Задержка очереди"
L["customize.stats.capacity"] = "Ёмкость"
L["customize.stats.cyclic"] = "Скорострельность"
L["customize.stats.explosive"] = "Урон взрывом"
L["customize.stats.firemodes"] = "Режимы"
L["customize.stats.firepower"] = "Огн. мощь"
L["customize.stats.freeaim"] = "Радиус свобод. прицела"
L["customize.stats.muzzlevelocity"] = "Скорости пули"
L["customize.stats.noise"] = "Громкость"
L["customize.stats.penetration"] = "Пробивание"
L["customize.stats.precision"] = "Точность"
L["customize.stats.range"] = "Дальность"
L["customize.stats.ricochet"] = "Шанс рикошета"
L["customize.stats.rof"] = "Скорострельность"
L["customize.stats.speed"] = "Скорость движения"
L["customize.stats.sprinttofire"] = "После бега"
L["customize.stats.supplylimit"] = "Лимит магазинов"
L["customize.stats.sway"] = "Стабильность"
L["customize.stats.triggerdelay"] = "Задержка курка"

L["customize.hint.attach"] = "Установить"
L["customize.hint.controller"] = "Режим контроллера включен."
L["customize.hint.cursor"] = "Курсор"
L["customize.hint.cycle"] = "След. слот"
L["customize.hint.delete"] = "Удалить"
L["customize.hint.deselect"] = "Отм. выделение"
L["customize.hint.expand"] = "Раскрыть"
L["customize.hint.export"] = "Экспорт"
L["customize.hint.favorite"] = "Добавить в избранное"
L["customize.hint.import"] = "Импорт"
L["customize.hint.install"] = "Установить"
L["customize.hint.last"] = "Посл. слот"
L["customize.hint.lastmode"] = "Пред. режим"
L["customize.hint.nextmode"] = "След. режим"
L["customize.hint.open"] = "Открыть"
L["customize.hint.pan"] = "Схватить"
L["customize.hint.quicksave"] = "Быстрое сохранение"
L["customize.hint.randomize"] = "Случайный обвес"
L["customize.hint.recalculate"] = "Пересчитать"
L["customize.hint.recenter"] = "Центрирование"
L["customize.hint.rotate"] = "Поворот"
L["customize.hint.save"] = "Сохранить"
L["customize.hint.select"] = "Выбрать"
L["customize.hint.unattach"] = "Убрать"
L["customize.hint.unfavorite"] = "Убрать из избранного"
L["customize.hint.zoom"] = "Приблизить"

L["customize.trivia.description"] = "Описание"

L["customize.stats.explain.firepower"] = "Урон вплотную."
L["customize.stats.explain.rof"] = "Фактическая скорострельность."
L["customize.stats.explain.cyclic"] = "Темп стрельбы не учитывая задержки очередей или перезарядку."
L["customize.stats.explain.capacity"] = "Сколько боеприпасов оружие может содержать в магазине и патроннике."
L["customize.stats.explain.range"] = "Расстояние на котором урон минимален."
L["customize.stats.explain.precision"] = "Точность оружия. Измеряется в угловых минутах (MoA)."
L["customize.stats.explain.muzzlevelocity"] = "Начальная скорость пули."
L["customize.stats.explain.ammo"] = "Тип патронов оружия."
L["customize.stats.explain.penetration"] = "На сколько толстую стенку пробьет пуля."
L["customize.stats.explain.ricochet"] = "Максимальный шанс пули отрикошетить."
L["customize.stats.explain.armorpiercing"] = "Количество урона пуля нанесет игнорируя броню."
L["customize.stats.explain.explosive"] = "Урон взрывом."
L["customize.stats.explain.speed"] = "Насколько быстро вы сможете передвигаться держа это оружие."
L["customize.stats.explain.aimtime"] = "Насколько быстро вы сможете прицелиться."
L["customize.stats.explain.sprinttofire"] = "Насколько быстрым будет выход из спринта до возможного выстрела."
L["customize.stats.explain.firemodes"] = "Какие режимы стрельбы есть у оружия."
L["customize.stats.explain.burstdelay"] = "Задержка после очереди."
L["customize.stats.explain.triggerdelay"] = "Задержка между нажатием на спуск и выстрелом."
L["customize.stats.explain.noise"] = "Насколько громким будет выстрел."
L["customize.stats.explain.sway"] = "Количество качания у этого оружия."
L["customize.stats.explain.freeaim"] = "Максимальный угол свободного прицела. Меньше - лучше."
L["customize.stats.explain.supplylimit"] = "Количество патронов которое можно взять из коробок ARC9."

L["customize.bench.dummy"] = "БАЛЛИСТИЧЕСКАЯ МИШЕНЬ"
L["customize.bench.effect"] = "ЭФФЕКТ НА ДАЛЬНОСТИ"
L["customize.bench.ballistics"] = "ОЦЕНКА БАЛЛИСТИЧЕСКИХ ХАРАКТЕРИСТИК"
L["customize.bench.precision"] = "ИСПЫТАНИЕ ТОЧНОСТИ"

L["folder.back"] = "Назад"
L["folder.deselect"] = "Назад"
L["folder.favorites"] = "В избранное"
L["folder.select"] = "Выбрать"

////////////////////// Automatic stats
L["autostat.enable.pre"] = "Вкл."
L["autostat.disable.pre"] = "Выкл."
L["autostat.enable.post"] = ""
L["autostat.disable.post"] = ""

L["autostat.aimdownsightstime"] = "Скорость прицеливания"
L["autostat.alwaysphysbullet"] = "Физические пули"
L["autostat.ammopershot"] = "Патронов за выстрел"
L["autostat.armdamage"] = "Урон по рукам"
L["autostat.armorpiercing"] = "Бронепробиваемость"
L["autostat.autoburst"] = "Автоматические очереди"
L["autostat.autoreload"] = "Автоперезарядка"
L["autostat.bash"] = "Рукопашная"
L["autostat.bashdamage"] = "Урон врукопашную"
L["autostat.bashlungerange"] = "Дальность выпада рукопашного"
L["autostat.bashrange"] = "Дальность рукопашного"
L["autostat.bashspeed"] = "Скорость рукопашного"
L["autostat.bipod"] = "Сошки"
L["autostat.bottomlessclip"] = "Безлимитный магазин"
L["autostat.breathholdtime"] = "Время задержки дыхания"
L["autostat.bulletguidance"] = "Автонаведение"
L["autostat.bulletguidanceamount"] = "Сила автонаведения"
L["autostat.canfireunderwater"] = "Подводная стрельба"
L["autostat.cantpeek"] = "Отключены выглядывания"
L["autostat.chambersize"] = "Патронник"
L["autostat.chestdamage"] = "Урон в грудь"
L["autostat.clipsize"] = "Емкость магазина"
L["autostat.cycletime"] = "Скорость взвода"
L["autostat.damagemax"] = "Урон вблизи"
L["autostat.damagemin"] = "Урон на расстоянии"
L["autostat.damagerand"] = "Разброс урона"
L["autostat.deploytime"] = "Скорость доставания"
L["autostat.distance"] = "Дальность поражения"
L["autostat.entitymuzzlevelocity"] = "Скорость снаряда"
L["autostat.explosiondamage"] = "Урон взрывом"
L["autostat.explosionradius"] = "Радиус взрыва"
L["autostat.fixtime"] = "Скорость починки клина"
L["autostat.freeaimradius"] = "Радиус свободного прицела"
L["autostat.headshotdamage"] = "Урон в голову"
L["autostat.heatcapacity"] = "Теплоемкость"
L["autostat.heatdissipation"] = "Скорость охлаждения"
L["autostat.heatpershot"] = "Нагрев за выстрел"
L["autostat.hybridreload"] = "Гибридная перезарядка"
-- L["autostat.impactforce"] = "Impact Force"
L["autostat.infiniteammo"] = "Бесконечный боезапас"
L["autostat.legdamage"] = "Урон по ногам"
L["autostat.malfunction"] = "Клины"
L["autostat.malfunctionmeanshotstofail"] = "Шанс клина"
L["autostat.malfunctionwait"] = "Задержка после клина"
L["autostat.manualaction"] = "Ручной взвод"
L["autostat.manualactionchamber"] = "Патронов за взведение"
L["autostat.neverphysbullet"] = "Нефизические пули"
L["autostat.noflash"] = "Без дульной вспышки"
L["autostat.num"] = "Кол-во снарядов"
L["autostat.overheat"] = "Перегрев"
L["autostat.overheattime"] = "Скорость перегрева"
L["autostat.pelletspread"] = "Разброс  дроби"
L["autostat.penetration"] = "Пробивная способность"
L["autostat.penetrationdelta"] = "Урон после пробития"
L["autostat.physbulletdrag"] = "Баллистика пули"
L["autostat.physbulletgravity"] = "Баллистика пули"
L["autostat.physbulletmuzzlevelocity"] = "Скорость пули"
L["autostat.postburstdelay"] = "Задержка после очереди"
L["autostat.pushbackforce"] = "Отталкивание"
L["autostat.rangemax"] = "Максимальная дальность"
L["autostat.rangemin"] = "Минимальная дальность"
L["autostat.recoil"] = "Отдача"
L["autostat.recoilautocontrol"] = "Автоконтроль отдачи"
L["autostat.recoildissipationrate"] = "Скорость рассеивания отдачи"
L["autostat.recoilkick"] = "Рывки отдачи"
L["autostat.recoilmodifiercap"] = "Потолок отдачи"
L["autostat.recoilpatterndrift"] = "Непредсказуемость отдачи"
L["autostat.recoilpershot"] = "Увел. разброса за выстрел"
L["autostat.recoilrandomside"] = "Гориз. случайная отдача"
L["autostat.recoilrandomup"] = "Верт. случайная отдачи"
L["autostat.recoilresettime"] = "Время до сброса отдачи"
L["autostat.recoilside"] = "Горизонтальная отдача"
L["autostat.recoilup"] = "Вертикальная отдача"
L["autostat.reloadtime"] = "Скорость перезарядки"
L["autostat.ricochetanglemax"] = "Угол рикошета"
L["autostat.ricochetchance"] = "Шанс рикошета"
-- L["autostat.ricochetseeking"] = "Seeking Ricochet"
-- L["autostat.ricochetseekingangle"] = "Seeking Ricochet Angle"
L["autostat.rpm"] = "Скорострельность"
L["autostat.runawayburst"] = "Очередь до конца"
L["autostat.secondarysupplylimit"] = "Лимит вторичных патронов"
L["autostat.shootvolume"] = "Громкость выстрела"
L["autostat.shootwhilesprint"] = "Стрельба во время бега"
L["autostat.shotgunreload"] = "Перезарядка по одному"
L["autostat.speed"] = "Скорость ходьбы"
L["autostat.spread"] = "Разброс"
L["autostat.sprinttofiretime"] = "Возвращение после бега"
L["autostat.stomachdamage"] = "Урон в живот"
L["autostat.supplylimit"] = "Лимит магазинов"
L["autostat.sway"] = "Стабильность прицеливания"
L["autostat.triggerdelay"] = "Задержка курка"
L["autostat.triggerdelaytime"] = "Время задержки спуска курка"
L["autostat.visualrecoil"] = "Физическая отдача"
L["autostat.visualrecoilpunch"] = "Физ. толчок отдачи"
L["autostat.visualrecoilroll"] = "Физ. угловая отдача"
L["autostat.visualrecoilside"] = "Физ. горизонтальная отдача"
L["autostat.visualrecoilup"] = "Физ. вертикальная отдача"

--[[
Secondary autostats are now controlled by string.format.
This means that the above stats are displayed where the "%s" is located.
For example, "%s on Bipod" results in "Spread on Bipod".
Alternatively, "On Bipod: %s" results in "On Bipod: Spread".
]]--

L["autostat.secondary.bipod"] = "%s на сошках"
L["autostat.secondary.crouch"] = "%s в присяди"
L["autostat.secondary.empty"] = "%s последним выстрелом"
L["autostat.secondary.evenreload"] = "%s каждую чёт. перезарядку"
L["autostat.secondary.evenshot"] = "%s каждый чётный выстрел"
L["autostat.secondary.first"] = "%s первым выстрелом"
L["autostat.secondary.firstshot"] = "%s первым выстрелом"
L["autostat.secondary.heated"] = "%s при нагреве"
L["autostat.secondary.hipfire"] = "%s от бедра"
L["autostat.secondary.hot"] = "%s от тепла"
L["autostat.secondary.last"] = "%s последним выстрелом"
L["autostat.secondary.lastshot"] = "%s последним выстрелом"
L["autostat.secondary.midair"] = "%s в воздухе"
L["autostat.secondary.move"] = "%s в движении"
L["autostat.secondary.oddreload"] = "%s каждую нечёт. перезарядку"
L["autostat.secondary.oddshot"] = "%s каждый нечётный выстрел"
L["autostat.secondary.recoil"] = "%s пока стреляешь" --"With Each Shot"
L["autostat.secondary.shooting"] = "%s пока стреляешь"
L["autostat.secondary.sighted"] = "%s в прицеле"
L["autostat.secondary.sights"] = "%s в прицеле"
L["autostat.secondary.silenced"] = "%s с глушителем"
L["autostat.secondary.sprint"] = "%s во время бега"
L["autostat.secondary.true"] = "%s при вкл. TrueNames"
L["autostat.secondary.ubgl"] = "%s у подствольника"

////////////////////// Blacklist menu
L["blacklist.title"] = "ARC9 Чёрный список обвесов"
L["blacklist.desc"] = "Выбранные тут обвесы будут заблокированы"
L["blacklist.blisted"] = "В ЧС"
L["blacklist.all"] = "ВСЕ"
L["blacklist.id"] = "ID"
L["blacklist.name"] = "ИМЯ"
L["blacklist.filter"] = "ФИЛЬТР"

////////////////////// Incompatible addons
L["incompatible.title"] = "ARC9: НЕСОВМЕСТИМЫЕ АДДОНЫ"
L["incompatible.line1"] = "У вас включены аддоны которые точно не будут работать с ARC9."
L["incompatible.line2"] = "Отключите их, иначе что-то может пойти не так!"
L["incompatible.confirm"] = "Ознакомлен"
L["incompatible.wait"] = "Подождите {time}с"
L["incompatible.never"] = "Не предупреждайте меня"
L["incompatible.never.hover"] = "Уверен? Надеюсь, ты понимаешь последствия своего решения."
L["incompatible.never.confirm"] = "Ты решил отказаться от предупреждений несовместимостых аддонов. Если что-то окажется сломано - это на твоей совести, мы не будем тебе помогать."

////////////////////// Warning panel
L["badconf.title"] = "ARC9: НЕКОРРЕКТНЫЕ НАСТРОЙКИ ИГРЫ"
L["badconf.line1"] = "Некоторые ваши настройки игры вызывают проблемы."
L["badconf.line2"] = "Снизу перечислены все обнаруженные проблемы и их решения."
L["badconf.confirm"] = "Ознакомлен"
L["badconf.wait"] = "Подождите {time}с"

L["badconf.directx.title"] = "Устаревшая версия DirectX"
L["badconf.directx.desc"] = "Игра в данный момент использует старый DirectX 8 или 8.1. Современный GMod не поддерживает его, скорее всего вы не будете видеть модели оружия на всех паках оружия. (dx9 был представлен 21 год назад!)"
L["badconf.directx.solution"] = "Решение: открыть параметры запуска Garry's Mod's и вставить туда \"-dxlevel 95\". Если там есть \"-dxlevel 70/80/85\" то удалите эту строчку."

L["badconf.tickrate.title"] = "Слишком низкий тикрейт сервера"
L["badconf.tickrate.desc"] = "Сервер на котором вы находитесь имеет слишком низкий тикрейт. ARC9 работает лучше всего на тикрейтах от 20 и выше (рекомендуется 66+)."
L["badconf.tickrate.solution"] = "Решение: Если вы владелец сервера, вставьте \"-tickrate 33\" в настройки запуска сервера."

L["badconf.matbumpmap.title"] = "mat_bumpmap отключен"
L["badconf.matbumpmap.desc"] = "У вас отключены карты нормалей, оружие будет выглядеть плохо и некоторые прицелы могут не работать."
L["badconf.matbumpmap.solution"] = "Решение: В консоль введите \"mat_bumpmap 1\". Если вы используете любые FPS конфиги то найдите и удалите из \"autoexec.cfg\" строчку mat_bumpmap 0."

L["badconf.addons.title"] = "Слишком много аддонов! Лимит lua файлов исчерпан"
L["badconf.addons.desc"] = "Вы установили слиииишком много аддонов и достигли лимита Lua файлов. ARC9 не закончил загрузку, обвесы не будут работать."
L["badconf.addons.solution"] = "Решение: Удалите немного тяжелых аддонов через игру или воркшоп (например другие базы оружия, JMOD, паки энтити и т.д.)."

L["badconf.warning"] = "Внимание! Производительность ограничена - наведитесь чтобы узнать детали."
L["badconf.warning.desc"] = "Больше FPS всегда лучше. Особенно на этой базе оружия.\n\nНаведите курсор на пункты ниже чтобы узнать решение."

L["badconf.x64.title"] = "► Медленный 32-битный GMod обнаружен"
L["badconf.x64.desc"] = [[В данный момент игра работает в 32-битном режиме, это сильно ограничивает производительность.

Решение: в параметрах запуска Garry's Mod's зайдите в "Бета версии" и измените ветку на "x86-64 - Chromium + 64-bit binaries".

Гугли "gmod x64" чтобы найти гайд как это сделать.]]

L["badconf.multicore.title"] = "► Многопотоковый рендеринг отключен"
L["badconf.multicore.desc"] = [[Отсутствуют некоторые команды для многопотоковых процессоров, можно увеличить производительность путём добавления нужных команд в autoexec.cfg.

Гугли "gmod multicore" чтобы найти гайд как это сделать.

Все команды для увеличения производительности:
gmod_mcore_test 1
mat_queue_mode 2
cl_threaded_bone_setup 1
r_threaded_client_shadow_manager 1
r_threaded_renderables 1]]

////////////////////// Presets
L["customize.presets.atts"] = " обвесов"
L["customize.presets.back"] = "Назад"
L["customize.presets.cancel"] = "Отмена"
L["customize.presets.code"] = "Код пресета (Скопирован в буфер обмена)"
L["customize.presets.default"] = "Стандартный"
L["customize.presets.default.long"] = "Стандартный пресет"
L["customize.presets.dumb"] = "Ты ебнутый?"
L["customize.presets.import"] = "Импорт"
L["customize.presets.invalid"] = "Неправильная строка!"
L["customize.presets.new"] = "Название нового пресета"
L["customize.presets.paste"] = "Вставьте код пресета"
L["customize.presets.random"] = "Случайный"
L["customize.presets.save"] = "Сохранить"
L["customize.presets.unnamed"] = "Без названия"

L["customize.presets.deldef"] = "Ты точно хочешь удалить стандартный \"{name}\" пресет?"
L["customize.presets.deldef2"] = "Чтобы его вернуть, тебе придётся сбрасывать данные оружия в настройках разработчика."
L["customize.presets.yes"] = "Да"

////////////////////// Tips
L["tips.arc-9"] = "Правильно писать ARC9, не ARC-9 и не Arc9."
L["tips.blacklist"] = "Вы можете заносить обвесы в черный список! Посмотри как это сделать в описании ARC9 в воркшопе."
L["tips.bugs"] = "Репорть баги в официальном дискорде или открой issue на гитхабе."
L["tips.custombinds"] = "Комбинации клавиш можно заменить кастомными биндами. Начни писать +arc9_ в консоль чтобы найти возможные."
L["tips.cyberdemon"] = "Чтобы убить террориста - стреляй ему в голову."
L["tips.description"] = "Советуем читать описания аддонов перед тем как оставлять там комментарии."
L["tips.development"] = "Хочешь делать контент на ARC9? В официальном дискорде есть много полезной инфы."
L["tips.discord"] = "Присоединяйся к нашему дискорду! Ссылка в описании и сверху в настройках (такой себе сервер если честно)."
L["tips.external"] = "Если ты используешь ARC9 с гитхаба, не забудь часто обновляться!"
L["tips.hints"] = "Не выключай HUD если хочешь видеть подсказки управления."
L["tips.lean"] = "Чтобы наклонятся по кнопкам, забинди клавиши на +alt1 и +alt2."
L["tips.love"] = "Говорить хорошие слова разработчикам модов - хорошое дело."
L["tips.m9k"] = "Зацени M9K!."
L["tips.official"] = "Скачивай ARC9 только с офиц. источников. Неизвестные сайты скорее всего имеют устаревший код (или вирусы)."
L["tips.presets"] = "Экспортируй свои крутые пресеты пушек и делись ими со своими друзьями!"
L["tips.settings"] = "Ты можешь отключить эти советы, а также многое другое в настройках ARC9. Жми на кнопку слева сверху!"
L["tips.tips"] = "У советов определенный порядок. Продолжай читать и ты увидишь их все."
L["tips.tolerance"] = "Все оружейные базы работают вместе без проблем и у всех есть свои недостатки. Не стоит выставлять одну базу лучше другой."

////////////////////// Other
L["atts.favourites"] = "Избранное"
L["atts.filter"] = "Фильтр"

/////////////////////////////////////// Settings menu
///////////////////////////////// Legacy
--[[
These strings are from the old settings menu.
If you wish to translate, these are to be removed, and only used as inspiration.
]]--

////////////////////// General
L["settings.tabname.general"] = "Основное"

L["settings.general.client"] = "Клиент"
L["settings.quick.lang.title"] = "Язык"
L["settings.quick.lang.desc"] = "Язык интерфейса ARC9."
L["settings.truenames.title"] = "Настоящие названия оружия"
L["settings.truenames.desc"] = "Будут ли оружия показывать настоящие или вымышленые названия сделанные разработчиком. (не все оружия поддерживают эту функцию)\n\nЭто серверная переменная."
L["settings.client.reset.title"] = "Сброс клиентских настроек"

L["settings.general.server"] = "Сервер"
L["settings.server.gameplay.truenames.title"] = "Наст. названия по умолч."
L["settings.server.gameplay.truenames.desc"] = "Устанавливает режим настоящих названий оружия на сервере. Все игроки имеющее выбранным \"По умолчанию\" в настройках будут использовать это."
L["settings.truenames_enforced.title"] = "Настоящие названия принудительно"
L["settings.truenames_enforced.desc"] = "Все игроки будут иметь переменную как у сервера."

L["settings.server.reset.title"] = "Сброс серверных настроек"

L["settings.reset"] = "Сброс!"

////////////////////// Performance
L["settings.tabname.performance"] = "Производительность"

L["settings.performance.important"] = "Важное"
L["settings.gameplay.cheapscopes.title"] = "Производительные прицелы"
L["settings.gameplay.cheapscopes.desc"] = "Более производельный вариант рендеринга прицелов путём приближения всей камеры, вместо рендеринга второй сцены. Сильно улучшает производительность на больших картах и не только."
L["settings.tpik.title"] = "Включить TPIK"
L["settings.tpik.desc"] = "TPIK (Инверсивная Кинематика для третьего лица) это система для анимации оружия и рук у игроков от третьего лица.\n\nВы можете настроить эту систему во вкладке Визуал."
L["settings.effects.allflash.title"] = "Фонарики у всех игроков"
L["settings.effects.allflash.desc"] = "Показывать фонарики у всех игроков на сервере.\n\nЗначительно снижает производительность на серверах."

L["settings.tabname.blur"] = "Размытие"
L["settings.blur.cust_blur.title"] = "Фон кастомизации"
L["settings.blur.cust_blur.desc"] = "Размывает фон в меню кастомизации."
L["settings.blur.fx_reloadblur.title"] = "Во время перезарядки"
L["settings.blur.fx_reloadblur.desc"] = "Размытие мира во время перезарядки."
L["settings.blur.fx_animblur.title"] = "При первом доставании"
L["settings.blur.fx_animblur.desc"] = "Размытие мира при доставании нового оружия в первый раз."
L["settings.blur.fx_rtblur.title"] = "В оптике"
L["settings.blur.fx_rtblur.desc"] = "Размытие мира при использовании оптических прицелов."
L["settings.blur.fx_adsblur.title"] = "В прицелах"
L["settings.blur.fx_adsblur.desc"] = "Размытие части оружия при использовании любых прицелов."
L["settings.fx_rtvm.title"] = "Отображать оружие в прицелах"
L["settings.fx_rtvm.desc"] = "! ЭКСПЕРЕМЕНТАЛЬНАЯ ОПЦИЯ !\nРендерит модель оружия и обвесов в RT прицелах. Необходимо отключить \"Производительные прицелы\".\nЗначительно снижает производительность."
L["settings.blur.fx_rtblur.title2"] = "Размытие за прицелами"

L["settings.performance.shelleject.title"] = "Гильзы"
L["settings.effects.eject_fx.title"] = "Эффект дыма"
L["settings.effects.eject_fx.desc"] = "Производит эффект дыма от только что выпущенных гильз. (если возможно)"
L["settings.effects.eject_time.title"] = "Доп. время"
L["settings.effects.eject_time.desc"] = "Позволяет гильзам существовать дольше. Может снизить производительность."

L["settings.tabname.effects"] = "Эффекты"
L["settings.effects.muzzle_light.title"] = "Динам. свет от выстрелов"
L["settings.effects.muzzle_light.desc"] = "Включает динамический свет от вспышек выстрелов."
L["settings.effects.muzzle_others.title"] = "Эффекты от выстрелов у игроков"
L["settings.effects.muzzle_others.desc"] = "Включает эффекты от выстрелов от пушек у других игроков на сервере."

////////////////////// Optics
L["settings.tabname.optics"] = "Оптика"

L["settings.optics.control"] = "Управление"
L["settings.gameplay.sensmult.title"] = "Чувствительность в прицеле"
L["settings.gameplay.sensmult.desc"] = "Умножает чувствительность мыши при прицеливании\nЧем меньше значение - тем меньше чувствительность.\nПолезно на контроллерах или же если вы просто хотите чувствительность пониже."
L["settings.gameplay.compensate_sens.title"] = "Компенсировать чувствительность"
L["settings.gameplay.compensate_sens.desc"] = "Компенсировать чувствительность мыши в оптических прицелах."
L["settings.gameplay.toggleads.title"] = "Прицеливание по нажатию"
L["settings.gameplay.toggleads.desc"] = "Вместо удерживания кнопки прицеливания достаточно нажать один раз."

L["settings.optics.color"] = "Цвет сетки"
L["settings.gameplay.color.reflex.title"] = "Коллиматорных прицелов"
L["settings.gameplay.color.reflex.desc"] = "Цвет сетки у коллиматорных/ голографических прицелов.\n\nНе все прицелы поддерживают смену цвета."
L["settings.gameplay.color.scope.title"] = "Оптики"
L["settings.gameplay.color.scope.desc"] = "Цвет сетки у оптических прицелов.\n\nНе все прицелы поддерживают смену цвета."

////////////////////// Crosshair
L["settings.tabname.crosshair"] = "Перекрестие"

L["settings.crosshair.crosshair"] = "Перекрестие"
L["settings.crosshair.cross_enable.title"] = "Включить перекрестие"
L["settings.crosshair.cross_enable.desc"] = "Включить перекрестие. Заблокировано на некоторых оружиях."
L["settings.crosshair.cross.title"] = "Цвет"
L["settings.crosshair.cross.desc"] = "Цвет перекрестия."
L["settings.crosshair.cross_size_mult.title"] = "Размер"
L["settings.crosshair.cross_size_mult.desc"] = "Множитель размера перекрестия."
L["settings.crosshair.cross_size_dot.title"] = "Размер точки"
L["settings.crosshair.cross_size_dot.desc"] = "Множитель размера точки перекрестия."
L["settings.crosshair.cross_size_prong.title"] = "Размер зубцов"
L["settings.crosshair.cross_size_prong.desc"] = "Множитель размера зубцов у перекрестия."
L["settings.crosshair.crosshair_static.title"] = "Статичный"
L["settings.crosshair.crosshair_static.desc"] = "Включает полностью статичный прицел, который не двигается от стрельбы."
L["settings.crosshair.crosshair_force.title"] = "Принудительно включить"
L["settings.crosshair.crosshair_force.desc"] = "Принудительно включает перекрестие даже не пушках которые не позволяют это.\n\nЭто серверная переменная."
L["settings.crosshair.crosshair_target.title"] = "Красный прицел на цели"
L["settings.crosshair.crosshair_target.desc"] = "Делает прицел красным при наведении на цель.\nНаведение так же активирует аим-ассист (если включено)"
L["settings.crosshair.crosshair_peeking.title"] = "Перекрестие при выглядивании"
L["settings.crosshair.crosshair_peeking.desc"] = "Показывает перекрестие во время выглядывания из-за прицела."

L["settings.crosshair.crosshair_sgstyle.title"] = "Перекрестие у дробовиков"
L["settings.crosshair.crosshair_sgstyle.desc"] = "Меняет стиль перекрестия на оружии, которое стреляет несколькими снарядами за выстрел.\n\nПоследний пункт рисует столько точек, сколько снарядов у патрона."
L["settings.crosshair.crosshair_sgstyle_fullcircle"] = "Закрытый круг"
L["settings.crosshair.crosshair_sgstyle_four"] = "4 полукруга"
L["settings.crosshair.crosshair_sgstyle_two"] = "2 полукруга"
L["settings.crosshair.crosshair_sgstyle_dots"] = "Ориг. точки"
L["settings.crosshair.crosshair_sgstyle_dots_accurate"] = "Точки дроби"

////////////////////// Customization
L["settings.tabname.arc9_hud"] = "Персонализация"

L["settings.custmenu.hud"] = "HUD"
L["settings.hud_game.hud_scale.title"] = "Масштаб"
L["settings.hud_game.hud_scale.desc"] = "Множитель размера интерфейса ARC9."
L["settings.hud_game.hud_deadzonex.title"] = "Гориз. мёртвая зона"
L["settings.hud_game.hud_deadzonex.desc"] = "Горизонтальная \"мёртвая зона\" для меню кастомизации и HUD панели.\nПолезно на ультрашироких мониторах."
L["settings.custmenu.hud_color.title"] = "Цвет интерфейса"
L["settings.custmenu.hud_color.desc"] = "Главный цвет интерфейса, акцент."
L["settings.custmenu.hud_holiday.title"] = "Праздничные темы"
L["settings.custmenu.hud_holiday.desc"] = "Различные темы будут активироваться во время (реальных) праздников.\nПереназначит акцентный цвет интерфейса."
L["settings.custmenu.hud_darkmode.title"] = "Темная тема"
L["settings.custmenu.hud_darkmode.desc"] = "Включает темные цвета интерфейса вместо серого и отключает виньетку у фона."
L["settings.custmenu.cust_light.title"] = "Включить подсветку"
L["settings.custmenu.cust_light.desc"] = "Включает подсветку оружия в меню кастомизации.\n\nТо же самое, что и кнопка рядом с настройками."
L["settings.custmenu.cust_light_brightness.title"] = "Яркость подсветки"
L["settings.custmenu.cust_light_brightness.desc"] = "Яркость подсветки оружия.\n\nНе забудьте включить её сперва!"

L["settings.custmenu.customization"] = "Кастомизация"
L["settings.custmenu.cust_hints.title"] = "Подсказки"
L["settings.custmenu.cust_hints.desc"] = "Включает подсказки в меню кастомизации."
L["settings.custmenu.cust_tips.title"] = "Советы"
L["settings.custmenu.cust_tips.desc"] = "Советы о базе около подсказок."
L["settings.custmenu.cust_exit_reset_sel.title"] = "Сброс слота при выходе"
L["settings.custmenu.cust_exit_reset_sel.desc"] = "Выход из меню кастомизации будет сбрасывать выбор активного слота."

////////////////////// Game HUD
L["settings.tabname.hud_game"] = "Игровой HUD"

L["settings.hud_game.lcd"] = "LCD Панель"
L["settings.hud_game.hud_arc9.title"] = "Включить HUD"
L["settings.hud_game.hud_arc9.desc"] = "Включает HUD на ARC9 пушках."
L["settings.hud_game.hud_always.title"] = "На всех оружиях"
L["settings.hud_game.hud_always.desc"] = "Включает этот HUD на всех пушках."
L["settings.hud_game.hud_compact.title"] = "Компактный режим"
L["settings.hud_game.hud_compact.desc"] = "Компактный режим для панели HUD."
L["settings.hud_game.nohints.title"] = "Отключить подсказки"
L["settings.hud_game.nohints.desc"] = "Отключить подсказки вообще. Их не будет ни в 3D интерфейсе, ни в 2D."
L["settings.hud_game.keephints.title"] = "Подсказки"
L["settings.hud_game.keephints.desc"] = "Показывать подсказки по управлению оружием ARC9 наверху панели."
L["settings.server.hud_game.hud_arc9.title"] = "Принудительно отключить HUD"
L["settings.server.hud_game.hud_arc9.desc"] = "Принудительно отключает интерфейс для всех игроков на сервере. Не влияет на подсказки."

L["settings.hud_game.killfeed"] = "Киллфид"
L["settings.hud_game.killfeed_enable.title"] = "Иконки в киллфиде"
L["settings.hud_game.killfeed_enable.desc"] = "Включает автогенерацию иконок ARC9 пушек."
L["settings.hud_game.killfeed_dynamic.title"] = "Динамичное обновление"
L["settings.hud_game.killfeed_dynamic.desc"] = "Иконки оружия в киллфиде будет обновлятся после каждого убийства.\n\nВыключи, если хочешь эти самые 0.1 фпс."
L["settings.hud_game.killfeed_colour.title"] = "Цветные иконки"
L["settings.hud_game.killfeed_colour.desc"] = "Динамически генерируемые иконки не будут залиты белым цветом (киллфид и хотбар)."

L["settings.hud_game.breath"] = "Задержка дыхания"
L["settings.centerhint.breath_hud.title"] = "Индикатор"
L["settings.centerhint.breath_hud.desc"] = "Показывать, сколько вы можете ещё задерживать дыхание в прицелах в интерфейсе."
L["settings.centerhint.breath_pp.title"] = "Пост-обработка"
L["settings.centerhint.breath_pp.desc"] = "Задержка дыхания будет делать эффекты резкости на экране."
L["settings.hud_game.breath_sfx.title"] = "Озвучка"
L["settings.hud_game.breath_sfx.desc"] = "При задерживании дыхания будут воспроизводится соответствующие звуки."

L["settings.tabname.centerhint"] = "Подсказки по центру экрана"
L["settings.centerhint.reload.title"] = "Перезарядка"
L["settings.centerhint.reload_percent.title"] = "Процент магазина"
L["settings.centerhint.bipod.title"] = "Сошки"
L["settings.centerhint.bipod.desc"] = "Подсказка по центру экрана о возможности установки сошек."
L["settings.centerhint.jammed.title"] = "Клины"

L["settings.centerhint.firemode.title"] = "Режим огня"

L["settings.centerhint.overheat.title"] = "Перегрев"

L["settings.hud_game.hud_glyph"] = "Тип глифов"

L["settings.hud_game.hud_glyph_type_hud.title"] = "HUD"
L["settings.hud_game.hud_glyph_type_hud.desc"] = "Меняет семейство глифов для использования в интерфейсе.\nЭто также затронет подсказки."

L["settings.hud_game.hud_glyph_type_cust.title"] = "Меню кастомизации"
L["settings.hud_game.hud_glyph_type_cust.desc"] = "CМеняет семейство глифов для использования в интерфейсе.\nИзменения применятся при следующем открытии меню."

L["settings.hud_game.hud_glyph_light"] = "Светлая тема"
L["settings.hud_game.hud_glyph_dark"] = "Темная тема"
L["settings.hud_game.hud_glyph_knockout"] = "Knockout тема"

////////////////////// NPCs
L["settings.tabname.npc"] = "NPC"

L["settings.npc.weapons"] = "Оружие NPC"
L["settings.server.npc.npc_equality.title"] = "Одинаковый урон"
L["settings.server.npc.npc_equality.desc"] = "NPC будут делать точно такой же урон как и игроки.\n\nЭто серверная переменная."
L["settings.server.npc.npc_spread.title"] = "Разброс у NPC"
L["settings.server.npc.npc_spread.desc"] = "Множитель неточности выстрелов ARC9 пушек у NPC."
L["settings.server.npc.npc_atts.title"] = "Спавнить NPC с обвесами"
L["settings.server.npc.npc_atts.desc"] = "NPC с ARC9 пушками будут с случайным набором обвесов.\n\nЭто серверная переменная."
L["settings.server.npc.ground_atts.title"] = "Спавнить оружие на земле с обвесами"
L["settings.server.npc.ground_atts.desc"] = "Заспавленные ARC9 пушки на земле будут с случайным набором обвесов.\n\nЭто серверная переменная."
L["settings.server.npc.npc_autoreplace.title"] = "Заменить оружие у NPC"
L["settings.server.npc.npc_autoreplace.desc"] = "Заменить оружие у NPC случайным ARC9 стволом.\n\nЭто серверная переменная."
L["settings.server.npc.replace_spawned.title"] = "Заменять оружие на полу"
L["settings.server.npc.replace_spawned.desc"] = "Заменяет заспавненные картой или вами HL2 оружие случайным ARC9 стволом.\n\nЭто серверная переменная."
L["settings.server.npc.npc_give_weapons.title"] = "Игроки могут давать оружие"
L["settings.server.npc.npc_give_weapons.desc"] = "Игроки могут нажать Е на NPC чтобы дать им своё оружие.\n\nЭто серверная переменная."

////////////////////// Gameplay
L["settings.tabname.gameplay"] = "Геймплей"

L["settings.gameplay.controls"] = "Управление"
L["settings.gameplay.toggleads.title"] = "Прицеливание по нажатию"
L["settings.gameplay.toggleads.desc"] = "Вместо удерживания кнопки прицеливания достаточно нажать один раз."
L["settings.gameplay.autolean.title"] = "Автонаклоны"
L["settings.gameplay.autolean.desc"] = "Прицеливония возле угла стены будет автоматически наклонять игрока если возможно."
L["settings.gameplay.autoreload.title"] = "Автоперезарядка"
L["settings.gameplay.autoreload.desc"] = "Пустое оружие ARC9 будет перезаряжатся автоматически."
L["settings.gameplay.togglelean.title"] = "Наклон по нажатию"
L["settings.gameplay.togglelean.desc"] = "Вместо удерживания кнопки наклона достаточно нажать один раз."
L["settings.gameplay.togglepeek.title"] = "Выглядывание по нажатию"
L["settings.gameplay.togglepeek.desc"] = "Вместо удерживания кнопки выглядывания достаточно нажать один раз."
L["settings.gameplay.togglepeek_reset.title"] = "Сброс выглядывания после прицел."
L["settings.gameplay.togglepeek_reset.desc"] = "(Только если Выглядывание по нажатию включено)\nСостояние выглядывения будет сброшено после выхода из прицела."
L["settings.gameplay.togglebreath.title"] = "Задержка дыхания по нажатию"
L["settings.gameplay.togglebreath.desc"] = "Вместо удерживания кнопки задержки дыхания достаточно нажать один раз."

L["settings.gameplay.mechanics"] = "Игровые механики"
L["settings.server.gameplay.infinite_ammo.title"] = "Бесконечные патроны"
L["settings.server.gameplay.infinite_ammo.desc"] = "Оружие будет иметь неограниченный боезапас.\n\nЭто серверная переменная."
L["settings.server.gameplay.realrecoil.title"] = "Физическая отдача"
L["settings.server.gameplay.realrecoil.desc"] = "Некоторое настроенное оружие будет иметь (полностью) физическую отдачу и всё с этим связанное, вместо обыкновенной отдачи. Очень важно для баланса некоторых оружейных паков.\n\nЭто серверная переменная."
L["settings.server.gameplay.lean.title"] = "Наклоны"
L["settings.server.gameplay.lean.desc"] = "Игрок сможет наклонять тело через бинды +alt1 и +alt2, а также автоматически (если включено).\n\nЭто серверная переменная."
L["settings.server.gameplay.mod_sway.title"] = "Качение оружия"
L["settings.server.gameplay.mod_sway.desc"] = "Некоторые настроенные пушки будут качаться и быть нестабильными в прицелах (и без прицелов тоже).\n\nЭто серверная переменная."
L["settings.server.gameplay.mod_freeaim.title"] = "Свободный прицел"
L["settings.server.gameplay.mod_freeaim.desc"] = "Пушки будет иметь свободный прицел, вместо фиксирования в центр экрана (Free aim).\n\nЭто серверная переменная."
L["settings.server.gameplay.mod_bodydamagecancel.title"] = "Выкл. множитель урона по игрокам"
L["settings.server.gameplay.mod_bodydamagecancel.desc"] = "Выключает стандартный множитель урона по игрокам. Выключайте только если у вас есть аддон изменяющий множители урона в разные части тела.\n\nЭто серверная переменная."
L["settings.server.gameplay.breath_slowmo.title"] = "Слоу-мо в задержке дыхания"
L["settings.server.gameplay.breath_slowmo.desc"] = "Задерживание дыхания будет замедлять течение времени.\n\nТолько в одиночной игре."
L["settings.server.gameplay.manualbolt.title"] = "Ручные болтовки"
L["settings.server.gameplay.manualbolt.desc"] = "Вместо автоматического взвода затвора после отпускания кнопки стрельбы, болтовые оружия будет требовать нажатия R. \n\nПрямо как в FA:S 2.0"
L["settings.server.gameplay.never_ready.title"] = "Отключить Ready анимации"
L["settings.server.gameplay.never_ready.desc"] = "Никогда не проигрывать \"ready\" анимации при доставании любого оружия.\n\nЭто серверная переменная."
L["settings.server.gameplay.recoilshake.title"] = "Тряска поля зрения от отдачи"
L["settings.server.gameplay.recoilshake.desc"] = "Поле зрения дергается когда стреляешь"
L["settings.server.gameplay.equipment_generate_ammo.title"] = "Уникальные типы патронов для снаряжения"
L["settings.server.gameplay.equipment_generate_ammo.desc"] = "В игре есть лимит в 255 типов патронов, если у тебя установлено много аддонов, выключение этого пункта может помочь с некоторыми проблемами.\n\nЭто серверная переменная.\n\nТребуется перезапуск."

-- ??
L["settings.server.gameplay.mult_defaultammo.title"] = "Запас патрон. по умолч."
L["settings.server.gameplay.mult_defaultammo.desc"] = "Как много магазинов/гранат/снаряжения давать игроку когда он берёт оружие в руки первый раз?\n\nЭто серверная переменная."
L["settings.gameplay.nearwall.title"] = "Рядом со стеной"
L["settings.gameplay.nearwall.desc"] = "Не позволяет стрелять стоя вплотную к стенке или к другому препятствию перед тобой."

////////////////////// Visuals
L["settings.tabname.visuals"] = "Визуал"

L["settings.vm.vm_bobstyle.title"] = "Тип качения"
L["settings.vm.vm_bobstyle.desc"] = "Выберете стиль качения оружия созднный разными разработчиками ARC9 (и valve!)."
L["settings.vm.fov.desc"] = "Меняет поле зрения вьюмодели. Делает её больше или меньше. Используйте ответственно."
L["settings.vm.vm_addx.title"] = "Смещение по X"
L["settings.vm.vm_addx.desc"] = "Сместить вьюмодель налево или направо."
L["settings.vm.vm_addy.title"] = "Смещение по Y"
L["settings.vm.vm_addy.desc"] = "Сместить вьюмодель вперед или назад."
L["settings.vm.vm_addz.title"] = "Смещение по Z"
L["settings.vm.vm_addz.desc"] = "Сместить вьюмодель вверх или вниз."

L["settings.visuals.cambob"] = "Тряска камеры"
L["settings.vm.vm_cambob.title"] = "Тряска при беге"
L["settings.vm.vm_cambob.desc"] = "При беге у камеры будет тряска."
L["settings.vm.vm_cambobwalk.title"] = "Тряска при ходьбе"
L["settings.vm.vm_cambobwalk.desc"] = "При обычный ходьбе у камеры тоже будет тряска (требует включенной тряски при беге)"
L["settings.vm.vm_cambobintensity.title"] = "Интенсивность"
L["settings.vm.vm_cambobintensity.desc"] = "Насколько сильная будет тряска"

L["settings.tpik"] = "TPIK"
L["settings.tpik.title"] = "Включить TPIK"
L["settings.tpik.desc"] = "TPIK (Инверсивная Кинематика для третьего лица) это система для анимации оружия и рук у игроков от третьего лица."
L["settings.tpik_others.title"] = "TPIK всех игроков"
L["settings.tpik_others.desc"] = "Включить эту систему на игроках помимо вас. Понижает производительность."
L["settings.tpik_framerate.title"] = "Частота TPIK"
L["settings.tpik_framerate.desc"] = "Максимальная частота на которой TPIK работает. Ставь на 0 для снятия ограничения."

////////////////////// Bullet Physics
L["settings.tabname.bulletphysics"] = "Физика пуль"

L["settings.bullets.bullets"] = "Физика пуль"
L["settings.server.bulletphysics.bullet_physics.title"] = "Физические пули"
L["settings.server.bulletphysics.bullet_physics.desc"] = "Физические пули имеют физику. Падение на расстоянии, требуется некоторое время до приземления и всё в этом роде. Некоторое оружие может не поддерживать такое.\n\nЭто серверная переменная."
L["settings.server.bulletphysics.bullet_gravity.title"] = "Гравитация"
L["settings.server.bulletphysics.bullet_gravity.desc"] = "Множитель гравитации пуль.\n\nЭто серверная переменная."
L["settings.server.bulletphysics.bullet_drag.title"] = "Сопротивлен. воздуха"
L["settings.server.bulletphysics.bullet_drag.desc"] = "Множитель сопротивления воздуха у пуль.\n\nЭто серверная переменная."
L["settings.server.bulletphysics.ricochet.title"] = "Рикошеты"
L["settings.server.bulletphysics.ricochet.desc"] = "Некоторые пули смогут отскакивать от поверхностей и наносить урон.\n\nЭто серверная переменная."
L["settings.server.bulletphysics.mod_penetration.title"] = "Пробивание"
L["settings.server.bulletphysics.mod_penetration.desc"] = "Некоторые пули смогут пробивать различные поверхности и наносить урон всему, что стоит за этой поверхностью.\n\nЭто серверная переменная."
L["settings.server.bulletphysics.bullet_lifetime.title"] = "Время жизни"
L["settings.server.bulletphysics.bullet_lifetime.desc"] = "Сколько пуля сможет просуществовать в свободном полете.\n\nЭто серверная переменная."
L["settings.bullets.bullet_imaginary.title"] = "Воображаемые пули"
L["settings.bullets.bullet_imaginary.desc"] = "Пули будут смогут преодолевать границы карты и \"существовать\" в скайбоксе."

////////////////////// Attachments
L["settings.tabname.attachments"] = "Обвесы"

L["settings.tabname.customization"] = "Кастомизация"
L["settings.server.custmenu.atts_nocustomize.title"] = "Отключить кастомизацию"
L["settings.server.custmenu.atts_nocustomize.desc"] = "Отключить всю кастомизацию через меню.\n\nЭто серверная переменная."
L["settings.server.custmenu.atts_max.title"] = "Макс. обвесов"
L["settings.server.custmenu.atts_max.desc"] = "Максимальное число обвесов на одном оружии, включая косметические обвесы.\n\nЭто серверная переменная."
L["settings.custmenu.autosave.title"] = "Автосохранение"
L["settings.custmenu.autosave.desc"] = "Ваше последняя конфигурация оружия будет сохранена и автоматически установлена при следующем доставании."
L["settings.server.custmenu.blacklist.title"] = "Чёрный список"
L["settings.server.custmenu.blacklist.open"] = "Открыть"

L["settings.attachments.inventory"] = "Инвентарь"
L["settings.server.custmenu.free_atts.title"] = "Бесплатные обвесы"
L["settings.server.custmenu.free_atts.desc"] = "Обвесы можно использовать на оружии без подбирания их.\n\nЭто серверная переменная."
L["settings.server.custmenu.atts_lock.title"] = "Один для всего"
L["settings.server.custmenu.atts_lock.desc"] = "Подбирание одного обвеса позволить использовать его неограниченное количество раз на любом оружии.\n\nЭто серверная переменная."
L["settings.server.custmenu.atts_loseondie.title"] = "Терять после смерти"
L["settings.server.custmenu.atts_loseondie.desc"] = "Все подобранные обвесы удалятся после вашей смерти.\n\nЭто серверная переменная."
L["settings.server.custmenu.atts_generateentities.title"] = "Генерировать энтити"
L["settings.server.custmenu.atts_generateentities.desc"] = "Генерировать энтити обвесов для их спавна и последующего использования (если бесплатные обвесы выключены).\n\nВозможно увеличит время запуска в игру.\n\nЭто серверная переменная."

////////////////////// Modifiers
L["settings.tabname.modifiers"] = "Модификаторы"

L["settings.tabname.quickstat"] = "Быстрые модификаторы характеристик"
L["settings.tabname.quickstat.desc"] = " "

L["settings.server.quickstat.mod_damage.title"] = "Урон"
L["settings.mod_spread.title"] = "Разброс"
L["settings.mod_recoil.title"] = "Отдача"
L["settings.mod_visualrecoil.title"] = "Физ. отдача"
L["settings.mod_adstime.title"] = "Скорость прицеливания"
L["settings.mod_sprinttime.title"] = "Возвращение после бега"
L["settings.server.quickstat.mod_damagerand.title"] = "Вариация урона"
L["settings.mod_muzzlevelocity.title"] = "Дульная скорость"
L["settings.mod_rpm.title"] = "Скорострельность"
L["settings.mod_headshotdamage.title"] = "Урон в голову"
L["settings.server.quickstat.mod_malfunction.title"] = "Шанс неполадки"

////////////////////// Controller
L["settings.tabname.controller"] = "Контроллер"

L["settings.controller.misc"] = "Прочее"
L["settings.controller.misc.desc"] = "Здесь должна быть кнопка для вызова панели для продвинутой конфигурации контроллеров, но пока что она в спавнменю > Options > ARC9 > Controller."
L["settings.controller.controller.title"] = "Символы контроллера"
L["settings.controller.controller.desc"] = "Включает отображение символов для контроллеров, показывая кнопки контроллера вместо обычных клавиатурных кнопок."
L["settings.controller.controller_config.title"] = "Продвинутый конфиг"
L["settings.controller.controller_config.content"] = "Открыть панель"
L["settings.controller.controller_config.desc"] = "Открывает панель для продвинутой конфигурации контроллеров."

L["settings.controller.glyphs.title"] = "Тип глифов"
L["settings.controller.glyphs.desc"] = "Меняет семейство глифов для использования в интерфейсе.\nНастрой глифы в \"спавнменю\" > Options > ARC9 > Controller."

////////////////////// Aim Assist
L["settings.tabname.aimassist"] = "Аим-ассист"
L["settings.tabname.aimassist.desc"] = "Вы можете включить помощь в прицеливании (аим-ассист) если у вас проблемы с прицеливанием или если вам лень точно целиться."

L["settings.server.aimassist.enable.desc"] = "Включает помощь в прицеливании. Понижает чувствительность мыши при наведении возле цели.\n\nЭто серверная переменная.\n\nТак же требует включения аим-ассиста на клиенте."

L["settings.aimassist.enable_general.desc"] = "Включает помощь в прицеливании которая ведет мышь к ближайшему противнику.\n\nНастрой во вкладке \"Аим-ассист\"."

L["settings.aimassist.enable_client.desc"] = "Включает помощь в прицеливании. Понижает чувствительность мыши при наведении возле цели.\n\nТтребует включения аим-ассиста со стороны сервера."

L["settings.server.aimassist.intensity.title"] = "Интенсивность"
L["settings.server.aimassist.intensity.desc"] = "На сколько интенсивна помощь в прицеливании.\n\nЭто серверная переменная."

L["settings.server.aimassist.cone.title"] = "Угол помощи"
L["settings.server.aimassist.cone.desc"] = "Насколько далеко или близко нужно смотреть возле цели чтобы аим-ассист начал работать.\n\nЭто серверная переменная."

L["settings.server.aimassist.heads.title"] = "Фиксация на головах"
L["settings.server.aimassist.heads.desc"] = "Должен ли аим-ассист целить вас на головы противников вместо торса?\n\nЭто серверная переменная."

L["settings.aimassist.sensmult.desc"] = "Множитель чувствительности мыши когда прицел на противнике.\nЧем ниже значение, тем ниже чувствительность."

////////////////////// Asset Caching
L["settings.tabname.caching"] = "Кэширование"
L["settings.tabname.assetcache"] = "Кэширование ассетов"
L["settings.tabname.assetcache.desc"] = "Вы можете кэшировать (сохранять в память без подгрузок во время игры) некоторые ассеты для предотвращения статтеров для более комфортной игры!\n\nТебе точно стоит включить что-нибудь если твой гмод установлен на жестком диске."

L["settings.server.assetcache.precache_sounds_onfirsttake.title"] = "При первом взятии: Кэшировать звуки"
L["settings.server.assetcache.precache_sounds_onfirsttake.desc"] = "Кэшировать звуки оружия которое вы только что подобрали (кроме звуков перезарядок).\n\nНе особо влияет на производительность, однако крайне полезно для предотвращения статтеров во время стрельбы."

L["settings.server.assetcache.precache_attsmodels_onfirsttake.title"] = "При первом взятии: Кэш. все обвесы"
L["settings.server.assetcache.precache_attsmodels_onfirsttake.desc"] = "Кэшировать все модельки ARC9 обвесов когда любая ARC9 пушка была взята в руки.\n\nВызывает достаточно большой фриз, особенно когда у вас установлено много оружия."
L["settings.server.assetcache.precache_wepmodels_onfirsttake.title"] = "При первом взятии: Кэш. все модели оружия"
L["settings.server.assetcache.precache_wepmodels_onfirsttake.desc"] = "Кэшировать все вьюмодели оружия ARC9 когда любая ARC9 пушка была взята в руки.\n\nВызывает ОЧЕНЬ БОЛЬШОЙ фриз, особенно когда у вас установлено много оружия."

L["settings.server.assetcache.precache_allsounds_onstartup.title"] = "При старте игры: Кэш. все звуки оружия"
L["settings.server.assetcache.precache_allsounds_onstartup.desc"] = "Кэшировать все звуки всего ARC9 оружия при старте сервера (кроме звуков перезарядок).\n\nНе особо влияет на производительность, но лучше просто использовать первую опцию здесь."
L["settings.server.assetcache.precache_attsmodels_onstartup.title"] = "При старте игры: Кэш. все обвесы"
L["settings.server.assetcache.precache_attsmodels_onstartup.desc"] = "Кэшировать все модельки ARC9 обвесов при старте сервера.\n\nДелает загрузку в игру немного дольше, особенно когда у вас установлено много оружия."
L["settings.server.assetcache.precache_wepmodels_onstartup.title"] = "При старте игры: Кэш. все модели оружия"
L["settings.server.assetcache.precache_wepmodels_onstartup.desc"] = "Кэшировать все вьюмодели оружия ARC9 при старте сервера.\n\nДелает загрузку в игру НАМНОГО дольше, особенно когда у вас установлено много оружия."

L["settings.server.assetcache.precache_allsounds.title"] = "Все звуки оружия"
L["settings.server.assetcache.precache_wepmodels.title"] = "Все модели оружия"
L["settings.server.assetcache.precache_attsmodels.title"] = "Все модели обвесы"

L["settings.server.assetcache"] = "Кэшировать"

////////////////////// Developer
L["settings.tabname.developer"] = "Для разработчиков"

L["settings.tabname.developer.settings"] = "Настройки разработчика"
L["settings.server.developer.dev_always_ready.title"] = "Всегда Ready"
L["settings.server.developer.dev_always_ready.desc"] = "Всегда проигрывать анимацию \"ready\" при доставании оружия.\n\nЭто серверная переменная."
L["settings.server.developer.dev_benchgun.title"] = "Benchgun"
L["settings.server.developer.dev_benchgun.desc"] = "Оставить вьюмодель оружия там же, где оно и находится прямо сейчас."
L["settings.server.developer.dev_crosshair.title"] = "Прицел разработчика"
L["settings.server.developer.dev_crosshair.desc"] = "Покажет куда точно пойдут ваши пули и ещё пару интересных циферок.\n\nЭто серверная переменная только для админов."
L["settings.server.developer.dev_show_shield.title"] = "Показывать щиты"
L["settings.server.developer.dev_show_shield.desc"] = "Показывать модель щитов у игроков."
L["settings.server.developer.dev_greenscreen.title"] = "Зеленый экран в кастомизации"
L["settings.server.developer.dev_greenscreen.desc"] = "Показывает зеленый экран вместо фона в меню кастомизации для скриншотов.\n\nЕсли вы используете HDR, не забудьте поставить mat_bloom_scalefactor_scalar на 0!"
L["settings.server.developer.reloadatts.title"] = "Обвесы"
L["settings.server.developer.reloadlangs.title"] = "Языки"
L["settings.server.printconsole.dev_listmyatts.title"] = "Список обвесов"
L["settings.server.printconsole.dev_listanims.title"] = "Список анимаций"
L["settings.server.printconsole.dev_listbones.title"] = "Список костей"
L["settings.server.printconsole.dev_listbgs.title"] = "Список бодигрупп"
L["settings.server.printconsole.dev_listatts.title"] = "Список QCAttachaments"
L["settings.server.printconsole.dev_export.title"] = "Код экспорта"
L["settings.server.printconsole.dev_getjson.title"] = "JSON оружия"

L["settings.server.developer.presets_clear.title"] = "Очистить данные"
L["settings.server.developer.presets_clear.desc"] = "Удалить все пресеты, иконки и дефолтный пресет для оружия, что вы сейчас держете в руках.\n\nВнимание: если у вас сейчас нет ARC9 пушки в руках, это удалит всю данные всех пушек!"

L["settings.server.developer.clear"] = "Очистить"
L["settings.server.printconsole"] = "В консоль"
L["settings.server.developer.reload"] = "Перезагрузить"

-- End of Legacy

////////////////////// Universal
-- Use this method to localize convars in settings menu:
-- settings.convar.title = "Convar Title"
-- settings.convar.desc = "Convar Description"

L["settings.title"] = "Настройки ARC9"
L["settings.desc"] = "Описание"

L["settings.default_convar"] = "Значение по умолчанию"
L["settings.convar_server"] = "Серверная переменная"
L["settings.convar_client"] = "Клиентская переменная"

-- L["settings.disabled"] = "(Disabled) "
-- L["settings.disabled.desc"] = "! Disabled by server admin !\n\n"
-- L["settings.server"] = "\n\nThis is a server variable."

////////////////////// Quick Access
L["settings.tabname.quick"] = "Быстрый доступ"
-- L["settings.tabname.quick.desc"] = "Get quick access to the more important settings right here."

-- L["settings.quick.lang.title"] = "ARC9 Language"
-- L["settings.quick.lang.desc"] = "Change the displayed language for ARC9.\n\nNote: Not all languages are supported on weapon packs!"

-- L["settings.hud_game.hud_arc9.desc2"] = "Tweak in \"Game HUD\"\n\nEnable a custom LCD display HUD when using ARC9 weapons."

-- L["settings.tpik.desc2"] = "Tweak in \"Visuals\"\n\nEnables TPIK (Third Person Inverse Kinematics).\n\nImpacts performance."

-- L["settings.aimassist.enable.desc2"] = "Tweak in \"Gameplay\"\n\nEnables aim assist, which moves your camera closer to valid targets if one is detected close to your crosshair."

////////////////////// Reset Settings
L["settings.tabname.reset"] = "Сброс настроек"
-- L["settings.tabname.reset.desc"] = "Press the \"Reset\" button to fully reset ARC9 settings back to their default values."

-- L["settings.client.reset.title"] = "Reset Client Settings"
-- L["settings.client.reset.desc"] = "Fully resets all ARC9 client settings.\n\nWarning: Cannot be reversed."

-- L["settings.server.reset.title"] = "Reset Server Settings"
-- L["settings.server.reset.desc"] = "Fully resets all ARC9 server settings.\n\nWarning: Cannot be reversed."

-- L["settings.reset"] = "RESET"

////////////////////// Game HUD
-- L["settings.tabname.hud_game"] = "Game HUD"

////////// ARC9 HUD
-- L["settings.server.hud_game.hud_arc9.title"] = "Globally Disable ARC9 HUD"
-- L["settings.server.hud_game.hud_arc9.desc"] = "Disables the ability for users to utilize the ARC9 HUD."

-- L["settings.tabname.arc9_hud"] = "ARC9 HUD"
-- L["settings.tabname.arc9_hud.desc"] = "Everything related to ARC9's custom HUD and its elements."

-- L["settings.hud_game.hud_arc9.title"] = "Enable ARC9 HUD"
-- L["settings.hud_game.hud_arc9.desc"] = "Enable a custom LCD display HUD when using ARC9 weapons."
-- L["settings.hud_game.hud_compact.title"] = "Compact mode"
-- L["settings.hud_game.hud_compact.desc"] = "Hides certain elements on the ARC9 HUD, providing a more compact look."
-- L["settings.hud_game.hud_always.title"] = "Display on non-ARC9 Weapons"
-- L["settings.hud_game.hud_always.desc"] = "Enable the custom HUD when using non-ARC9 weapons."

-- L["settings.hud_game.hints.title"] = "Hint Behavior"
-- L["settings.hud_game.hints.desc"] = "Choose to always display, fade away or completely disable control hints."

-- L["settings.hud_game.hints.off"] = "Always Off"
-- L["settings.hud_game.hints.fade"] = "Fade Away"
-- L["settings.hud_game.hints.on"] = "Always On"

-- L["settings.hud_game.killfeed_enable.title"] = "Auto-Generate Killfeed Icons"
-- L["settings.hud_game.killfeed_enable.desc"] = "Generate killfeed icons automatically on ARC9 weapons."
-- L["settings.hud_game.killfeed_dynamic.title"] = "Dynamic Icons"
-- L["settings.hud_game.killfeed_dynamic.desc"] = "Dynamically generates icons when getting kills or altering attachments."
-- L["settings.hud_game.killfeed_colour.title"] = "Display in Color"
-- L["settings.hud_game.killfeed_colour.desc"] = "Generates icons in full color rather than black and white."

-- L["settings.hud_game.hud_scale.title"] = "HUD Scale"
-- L["settings.hud_game.hud_scale.desc"] = "Alter the size scale of the ARC9 HUD and the customization menu.\n\nNote: If set below 1, the ARC9 HUD will be disabled."

-- L["settings.hud_game.hud_deadzonex.title"] = "HUD Horizontal Deadzone"
-- L["settings.hud_game.hud_deadzonex.desc"] = "Alters the horizontal deadzone of the HUD and customization menu. The higher the value, the more towards the center it is.\n\nUseful for ultrawide monitors."

////////// Glyphs
-- L["settings.tabname.glyphs"] = "Glyphs"
-- L["settings.tabname.glyphs.desc"] = "Choose which kind of glyphs you'd like to display on the HUD and in the customization menu."

-- L["settings.hud_glyph.type_hud.title"] = "On the HUD"
-- L["settings.hud_glyph.type_hud.desc"] = "Which glyphs to use on the ARC9 HUD and Hints."
-- L["settings.hud_glyph.type_cust.title"] = "In Customization Menu"
-- L["settings.hud_glyph.type_cust.desc"] = "Which glyphs to use when in the customization menu."

-- L["settings.hud_glyph.light"] = "Light"
-- L["settings.hud_glyph.dark"] = "Dark"
-- L["settings.hud_glyph.knockout"] = "Knockout"

////////// Display Tooltips
-- L["settings.tabname.centerhint"] = "Display Tooltips"
-- L["settings.tabname.centerhint.desc"] = "Display tooltips on your HUD when certain criteria are met."

-- L["settings.centerhint.reload.title"] = "When Low on Ammo"
-- L["settings.centerhint.reload.desc"] = "Displays a tooltip when the magazine reaches a certain percentage value.\n\nAlso displays which button to press."
-- L["settings.centerhint.reload_percent.title"] = "Percentage"
-- L["settings.centerhint.reload_percent.desc"] = "When, in percentage value, the tooltip should appear."

-- L["settings.centerhint.bipod.title"] = "When using Bipods"
-- L["settings.centerhint.bipod.desc"] = "Displays a tooltip when you can utilize the weapon's bipod.\n\nAlso displays which button to press."

-- L["settings.centerhint.jammed.title"] = "When Jammed"
-- L["settings.centerhint.jammed.desc"] = "Displays a tooltip when the weapon is jammed.\n\nAlso displays which button to press."

-- L["settings.centerhint.firemode.title"] = "When Cycling Firing Modes"
-- L["settings.centerhint.firemode.desc"] = "Displays a tooltip when cycling firing modes."

-- L["settings.centerhint.firemode_time.title"] = "Display Time"
-- L["settings.centerhint.firemode_time.desc"] = "How long, in seconds, the tooltip should remain on screen."

-- L["settings.centerhint.overheat.title"] = "When Overheating"
-- L["settings.centerhint.overheat.desc"] = "Displays a tooltip when the weapon is about to overheat."

////////////////////// Visuals
-- L["settings.tabname.visuals"] = "Visuals"

////////// TPIK
L["settings.tabname.tpik"] = "TPIK - Инверсивная кинематика третьего лица"
-- L["settings.tabname.tpik.desc"] = "\"Third Person Inverse Kinematics\" is a system that allows most weapons to be displayed in third person using their first person animations and positions."

-- L["settings.tpik.title"] = "Enable TPIK"
-- L["settings.tpik.desc"] = "Enables TPIK (Third Person Inverse Kinematics).\n\nImpacts performance."

-- L["settings.tpik_others.title"] = "Other Players' TPIK"
-- L["settings.tpik_others.desc"] = "Show other players' TPIK.\n\nImpacts performance."

-- L["settings.tpik_framerate.title"] = "TPIK Frame Rate"
-- L["settings.tpik_framerate.desc"] = "At which frame rate the TPIK runs at.\n\nSet to 0 for unlimited.\n\nUnlimited or higher values impact performance."

////////// Blur
-- L["settings.tabname.blur"] = "Blur"
-- L["settings.tabname.blur.desc"] = "Applies a blur effect when certain criteria are met."

-- L["settings.blur.cust_blur.title"] = "Blur world when Customizing"
-- L["settings.blur.cust_blur.desc"] = "Blurs the background when the customization menu is open."

-- L["settings.blur.fx_reloadblur.title"] = "Blur world when Reloading"
-- L["settings.blur.fx_reloadblur.desc"] = "Blurs the background when reloading."

-- L["settings.blur.fx_animblur.title"] = "Blur world when Readying"
-- L["settings.blur.fx_animblur.desc"] = "Blurs the background when pulling out a weapon."

-- L["settings.blur.fx_inspectblur.title"] = "Blur world when Inspecting"
-- L["settings.blur.fx_inspectblur.desc"] = "Blurs the background when inspecting a weapon."

-- L["settings.blur.fx_rtblur.title"] = "Blur world when aiming RT scopes"
-- L["settings.blur.fx_rtblur.desc"] = "Blurs the background when aiming with any RT scope."

-- L["settings.blur.fx_adsblur.title"] = "Blur weapon when aiming"
-- L["settings.blur.fx_adsblur.desc"] = "Applies a blur effect on the bottom of your screen when aiming.\n\nNot all weapons support this."

////////// Effects
-- L["settings.tabname.effects"] = "Effects"
-- L["settings.tabname.effects.desc"] = "Adjust certain visual effects."

-- L["settings.effects.eject_fx.title"] = "Shell Eject Smoke"
-- L["settings.effects.eject_fx.desc"] = "Adds extra effects (sparks and smoke) to the shell ejection.\n\nHas minimal impact to performance."

-- L["settings.effects.eject_time.title"] = "Shell Eject Life Time"
-- L["settings.effects.eject_time.desc"] = "How long, in seconds, the shells ejected from ARC9 guns should remain on the ground.\n\nSet to -1 to disable.\n\nDepending on the value, can have minimal to a slight impact to performance."

-- L["settings.effects.muzzle_light.title"] = "Muzzle Lights"
-- L["settings.effects.muzzle_light.desc"] = "Lights up the surrounding area when firing a weapon without a suppressor.\n\nHas minimal impact to performance."

-- L["settings.effects.muzzle_others.title"] = "Other's Muzzle Effects"
-- L["settings.effects.muzzle_others.desc"] = "Display the muzzle effects from other player's ARC9 weapons.\n\nHas a slight impact to performance."

-- L["settings.effects.allflash.title"] = "Other's Flashlights"
-- L["settings.effects.allflash.desc"] = "Renders the flashlights from all players.\n\nImpacts performance."

-- L["settings.effects.lod.title"] = "LOD (Level of Detail) Distance"
-- L["settings.effects.lod.desc"] = "How far away you have to be from models for them to change into lower quality variants without attachments.\n\nLower values make the models change at lower distances, and could improve performance.\n\nHigher values could impact performance, but keeps the highest quality models loaded at further distances.\n\nTPIK distance is also affected."

////////// Viewmodel Settings
L["settings.tabname.vm"] = "Настройки Вьюмодели"
-- L["settings.tabname.vm.desc"] = "Alter various settings related to the viewmodels."

-- L["settings.vm.vm_bobstyle.title"] = "Bob Style"
-- L["settings.vm.vm_bobstyle.desc"] = "Choose one of various viewmodel bobbing styles, graciously contributed by the ARC9 team (and Valve)."

L["settings.vm.fov.title"] = "Поле зрения"
-- L["settings.vm.fov.desc"] = "Add this value to the viewmodel's field of view.\n\nNote: Could cause visual glitches if set too high or low."

-- L["settings.vm.vm_addx.title"] = "Viewmodel X-Axis"
-- L["settings.vm.vm_addx.desc"] = "Move the viewmodel left/right."

-- L["settings.vm.vm_addy.title"] = "Viewmodel Y-Axis"
-- L["settings.vm.vm_addy.desc"] = "Move the viewmodel up/down."

-- L["settings.vm.vm_addz.title"] = "Viewmodel Z-Axis"
-- L["settings.vm.vm_addz.desc"] = "Move the viewmodel forwards/backwards."

-- L["settings.vm.vm_cambob.title"] = "Sprint View Bobbing"
-- L["settings.vm.vm_cambob.desc"] = "Makes the camera move when sprinting."

-- L["settings.vm.vm_cambobwalk.title"] = "Walk View Bobbing"
-- L["settings.vm.vm_cambobwalk.desc"] = "Makes the camera move when walking."

-- L["settings.vm.vm_cambobintensity.title"] = "Intensity"
-- L["settings.vm.vm_cambobintensity.desc"] = "How intense the sprint and walk bobbing should be."

-- L["settings.vm.vm_camstrength.title"] = "Viewmodel Camera Strength"
-- L["settings.vm.vm_camstrength.desc"] = "Alters the strength of the camera movement used by weapon animations, such as when reloading or inspecting.\n\nCould help in reducing (or increasing) motion sickness.\n\nNote: Could potentially break the behavior of some weapon packs."

-- L["settings.vm.vm_camrollstrength.title"] = "Viewmodel Camera Roll Strength"
-- L["settings.vm.vm_camrollstrength.desc"] = "Alters the strength of the camera roll movement used by weapon animations, such as when reloading or inspecting.\n\nCould help in reducing (or increasing) motion sickness"

////////////////////// Crosshair & Scopes
L["settings.tabname.crosshairscopes"] = "Прицелы"
-- L["settings.tabname.crosshairscopes.desc"] = "Adjust settings related to the crosshair and scopes."

////////// Crosshair
-- L["settings.tabname.crosshair"] = "Crosshair"
-- L["settings.tabname.crosshair.desc"] = "Adjust settings related to the crosshair."

-- L["settings.crosshair.cross_enable.title"] = "Enable Crosshair"
-- L["settings.crosshair.cross_enable.desc"] = "Enables the crosshair."

-- L["settings.crosshair.crosshair_force.title"] = "Force-Enable Crosshair"
-- L["settings.crosshair.crosshair_force.desc"] = "Forces the crosshair to remain enabled, even on weapons which have it disabled."

-- L["settings.crosshair.crosshair_static.title"] = "Static Crosshair"
-- L["settings.crosshair.crosshair_static.desc"] = "Ensures that the crosshair does not move while firing.\n\nWarning: Will be inaccurate if used on weapons with non-centered crosshairs."

-- L["settings.crosshair.crosshair_target.title"] = "Red Crosshair on Target"
-- L["settings.crosshair.crosshair_target.desc"] = "Changes the color of the crosshair to red when hovering over a player or NPC."

-- L["settings.crosshair.crosshair_peeking.title"] = "Crosshair when Peeking"
-- L["settings.crosshair.crosshair_peeking.desc"] = "Displays the crosshair when peeking."

-- L["settings.crosshair.crosshair_sgstyle.title"] = "Shotgun Crosshair Style"
-- L["settings.crosshair.crosshair_sgstyle.desc"] = "Change the style of crosshair used when using weapons that fire two or more projectiles at once.\n\nThe last option draws the amount of dots equal to the amount of projectiles fired."

-- L["settings.crosshair.crosshair_sgstyle_fullcircle"] = "Enclosed Circle"
-- L["settings.crosshair.crosshair_sgstyle_four"] = "4 Half-Circles"
-- L["settings.crosshair.crosshair_sgstyle_two"] = "2 Half-Circles"
-- L["settings.crosshair.crosshair_sgstyle_dots"] = "Original Dots"
-- L["settings.crosshair.crosshair_sgstyle_dots_accurate"] = "Proj. Nr. Dots"

-- L["settings.crosshair.cross.title"] = "Crosshair Color"
-- L["settings.crosshair.cross.desc"] = "Which color the crosshair should be."

-- L["settings.crosshair.cross_size_mult.title"] = "Crosshair Size"
-- L["settings.crosshair.cross_size_mult.desc"] = "Multiplies the size of the crosshair by this value."

-- L["settings.crosshair.cross_size_dot.title"] = "Crosshair Dot Size"
-- L["settings.crosshair.cross_size_dot.desc"] = "Multiplies the size of the center dot in the crosshair by this value."

-- L["settings.crosshair.cross_size_prong.title"] = "Crosshair Prong Width"
-- L["settings.crosshair.cross_size_prong.desc"] = "Multiplies the width of the crosshair prongs by this value."

////////// Optics
-- L["settings.tabname.optics"] = "Optics"
-- L["settings.tabname.optics.desc"] = "Adjust settings related to optics and their functionality."

-- L["settings.gameplay.toggleads.title"] = "Toggle ADS"
-- L["settings.gameplay.toggleads.desc"] = "Pressing your aiming button toggles aiming."

-- L["settings.gameplay.cheapscopes.title"] = "Cheap Scopes"
-- L["settings.gameplay.cheapscopes.desc"] = "Cheap RT scope implementation that zooms your whole view when aiming rather than rendering the world through the scope.\n\nCan improve performance depending on map size.\n\nNot compatible with \"Render Weapon Through RT\"."

-- L["settings.gameplay.fx_rtvm.title"] = "Render Weapon Through RT"
-- L["settings.gameplay.fx_rtvm.desc"] = "! EXPERIMENTAL !\n\nRenders the weapon, and its attachments, through RT scopes.\n\nGreatly impacts performance.\n\nNot compatible with \"Cheap Scopes\"."

-- L["settings.gameplay.compensate_sens.title"] = "Dynamic ADS Sensitivity"
-- L["settings.gameplay.compensate_sens.desc"] = "Dynamically adjusts the aiming sensitivity depending on weapon zoom and magnification."

-- L["settings.gameplay.sensmult.title"] = "Multiply ADS Sensitivity"
-- L["settings.gameplay.sensmult.desc"] = "Multiplies the aiming sensitivity globally with this value.\n\nThe lower it is, the slower your sensitivity will be."

-- L["settings.gameplay.color.reflex.title"] = "Reflex Sight Color"
-- L["settings.gameplay.color.reflex.desc"] = "Which color the reticle used on reflex or holographic sights should be.\n\nNot all optics support this."

-- L["settings.gameplay.color.scope.title"] = "Scope Reticle Color"
-- L["settings.gameplay.color.scope.desc"] = "Which color the reticle used on RT scopes should be.\n\nNot all optics support this."

////////////////////// Gameplay
-- L["settings.tabname.gameplay"] = "Gameplay"

////////// General
-- L["settings.tabname.general"] = "General"
-- L["settings.tabname.general.desc"] = "Various general gameplay settings."

-- L["settings.gameplay.dtap_sights.title"] = "Double-Tap USE to Cycle Sights"
-- L["settings.gameplay.dtap_sights.desc"] = "Allows you to double-tap your USE button to cycle through optics."

-- L["settings.gameplay.autoreload.title"] = "Automatic Reload"
-- L["settings.gameplay.autoreload.desc"] = "Automatically reloads your weapon when it is empty."

-- L["settings.server.gameplay.recoilshake.title"] = "Enable Recoil FOV Shake"
-- L["settings.server.gameplay.recoilshake.desc"] = "Snaps the field of view when shooting."

////////// Functionality
-- L["settings.tabname.features"] = "Features"
-- L["settings.tabname.features.desc"] = "Adjust settings related to various ARC9 features."

-- L["settings.server.gameplay.mod_sway.title"] = "Enable Weapon Sway"
-- L["settings.server.gameplay.mod_sway.desc"] = "Enable weapon sway (if the weapon supports it).\n\nWeapons will move around, resulting in the viewmodel and crosshair to move away from the center of the screen."

-- L["settings.server.gameplay.breath_slowmo.title"] = "Enable Slow-Mo when Holding Breath (Singleplayer)"
-- L["settings.server.gameplay.breath_slowmo.desc"] = "! Singleplayer Only !\nHolding your breath slows down time."

-- L["settings.gameplay.togglebreath.title"] = "Toggle Holding Breath"
-- L["settings.gameplay.togglebreath.desc"] = "Pressing your sprint button toggles holding breath."

-- L["settings.centerhint.breath_hud.title"] = "Hold Breath Tooltip"
-- L["settings.centerhint.breath_hud.desc"] = "Displays a bar with your remaining breath when holding your breath."

-- L["settings.centerhint.breath_pp.title"] = "Hold Breath Post-Processing"
-- L["settings.centerhint.breath_pp.desc"] = "Also applies post-processing effects when holding your breath.\n\nRequires either Weapon Sway or Slow-Mo when Holding Breath."

-- L["settings.server.gameplay.mod_peek.title"] = "Enable Peeking"
-- L["settings.server.gameplay.mod_peek.desc"] = "Enable peeking, if the weapon supports it.\n\nAllows the user to lower their weapon while aiming while still having aiming benefits."

-- L["settings.gameplay.togglepeek.title"] = "Toggle Peek"
-- L["settings.gameplay.togglepeek.desc"] = "Pressing your peek button toggles peeking."

-- L["settings.gameplay.togglepeek_reset.title"] = "Reset Peek After Aiming"
-- L["settings.gameplay.togglepeek_reset.desc"] = "Disables peek when you stop aiming."

L["settings.server.aimassist.enable.title"] = "Включить помощь в прицеливании (Сервер)"
-- L["settings.server.aimassist.enable.desc"] = "Enables the ability for users to utilize aiming assistance."

L["settings.aimassist.enable.title"] = "Включить помощь в прицеливании"
-- L["settings.aimassist.enable.desc"] = "Enables aim assist, which moves your camera closer to valid targets if one is detected close to your crosshair."

-- L["settings.aimassist.sensmult.desc"] = "Multiplies the aiming sensitivity by this value when aiming close to valid targets if one is detected close to your crosshair."

-- L["settings.server.aimassist.intensity.title"] = "Aim Assist Intensity"
-- L["settings.server.aimassist.intensity.desc"] = "How intense the aim assistance should be."

-- L["settings.server.aimassist.cone.title"] = "Aim Assist Cone"
-- L["settings.server.aimassist.cone.desc"] = "How large of an area the aim assist should take affect in. The larger, the further away the valid targets can be."

-- L["settings.server.aimassist.heads.title"] = "Lock onto Heads"
-- L["settings.server.aimassist.heads.desc"] = "Enable if the aim assist should target the target's head rather than its chest."

-- L["settings.server.gameplay.manualbolt.title"] = "Require Manual Cycling"
-- L["settings.server.gameplay.manualbolt.desc"] = "Enable if the user should manually cycle manual operated weapons by pressing their reload key."

-- L["settings.server.gameplay.lean.title"] = "Allow Leaning"
-- L["settings.server.gameplay.lean.desc"] = "Allows users to lean left or right. Also applies to Automatic Lean."

-- L["settings.gameplay.autolean.title"] = "Automatic Lean"
-- L["settings.gameplay.autolean.desc"] = "Automatically tries to lean when near cover."

-- L["settings.gameplay.togglelean.title"] = "Toggle Lean"
-- L["settings.gameplay.togglelean.desc"] = "Pressing your left or right lean button toggles leaning."

-- L["settings.server.gameplay.mod_freeaim.title"] = "Enable Free Aim"
-- L["settings.server.gameplay.mod_freeaim.desc"] = "Enable free aim, if the weapon supports it.\n\nAllows the aiming point to be separate from the center of the screen."

-- L["settings.server.gameplay.never_ready.title"] = "Disable Readying Animations"
-- L["settings.server.gameplay.never_ready.desc"] = "Enable to disable weapon readying animations when you first pull out a weapon."

-- L["settings.server.gameplay.infinite_ammo.title"] = "Enable Infinite Ammo"
-- L["settings.server.gameplay.infinite_ammo.desc"] = "Weapons no longer require ammunition when reloading."

-- L["settings.server.gameplay.mult_defaultammo.title"] = "Default Reserve Ammo"
-- L["settings.server.gameplay.mult_defaultammo.desc"] = "How many spare magazines or pieces of equipment the player gets when a weapon is spawned."

-- L["settings.server.gameplay.equipment_generate_ammo.title"] = "Generate Unique Ammo for Equipment"
-- L["settings.server.gameplay.equipment_generate_ammo.desc"] = "The Source engine has a limit of 255 ammo types. Disabling this option could help fix errors if you have many addons installed.\n\nRequires restart."

-- L["settings.server.gameplay.realrecoil.title"] = "Enable Physical Visual Recoil"
-- L["settings.server.gameplay.realrecoil.desc"] = "Various weapons are set up for physical muzzle rise, meaning that they will shoot where their viewmodel points rather than the center of the screen.\n\nVery important for some weapon packs' balancing schemes."

-- L["settings.server.gameplay.mod_bodydamagecancel.title"] = "Body Damage Cancel"
-- L["settings.server.gameplay.mod_bodydamagecancel.desc"] = "Cancel out the default body damage multiplier.\n\nDisable only if another mod provides this sort of functionality."

////////////////////// Customization
-- L["settings.tabname.customization"] = "Customization"

////////// Customization Menu
L["settings.tabname.custmenu"] = "Меню кастомизации"
-- L["settings.tabname.custmenu.desc"] = "Adjust settings related to the customization menu."

-- L["settings.custmenu.hud_color.title"] = "Customization Menu Accent"
-- L["settings.custmenu.hud_color.desc"] = "Alter the accent color for the customization menu."

L["settings.custmenu.hud_lightmode.title"] = "Светлый режим"
-- L["settings.custmenu.hud_lightmode.desc"] = "Changes the color scheme of the customization menu to a lighter one.\n\nThe original ARC9 color scheme."

-- L["settings.custmenu.hud_holiday.title"] = "Festive Mode"
-- L["settings.custmenu.hud_holiday.desc"] = "Changes the color scheme of the customization menu to match certain holidays.\n\nOverrides \"Customization Menu Accent\"."

-- L["settings.custmenu.cust_light.title"] = "Enable Light"
-- L["settings.custmenu.cust_light.desc"] = "Enables a light that makes it easier to see your weapon."

-- L["settings.custmenu.cust_light_brightness.title"] = "Light Brightness"
-- L["settings.custmenu.cust_light_brightness.desc"] = "Adjust the brightness of the light."

-- L["settings.custmenu.cust_hints.title"] = "Enable Control Tips"
-- L["settings.custmenu.cust_hints.desc"] = "Displays control tips in the bottom right of the customization menu."

-- L["settings.custmenu.cust_tips.title"] = "Enable General Hints"
-- L["settings.custmenu.cust_tips.desc"] = "Displays general hints in the bottom left of the customization menu."

-- L["settings.custmenu.cust_exit_reset_sel.title"] = "Reset Active Slot on Close"
-- L["settings.custmenu.cust_exit_reset_sel.desc"] = "If enabled, the active customization slot will be reset when the menu is re-opened."

-- L["settings.custmenu.autosave.title"] = "Auto-Save Attachments"
-- L["settings.custmenu.autosave.desc"] = "Automatically saves equipped attachments when you exit the customization menu. Reloads them automatically when you respawn the weapon."

-- L["settings.server.gameplay.truenames.title"] = "Enable True Names"
-- L["settings.server.gameplay.truenames.desc"] = "Enable to have weapons that utilize fictional names to display their real ones instead.\n\nNot all weapons support this."

L["settings.custmenu.units.title"] = "Единицы измерения"
-- L["settings.custmenu.units.desc"] = "Choose to display either metric or imperial units in the customization menu."
-- L["settings.custmenu.units.metric"] = "Metric"
-- L["settings.custmenu.units.imperial"] = "Imperial"

L["settings.gameplay.controller.title"] = "Включить режим геймпада"
-- L["settings.gameplay.controller.desc"] = "Enables custom controller-friendly elements.\n\nCustom glyphs can be customized via the Spawnmenu (Options > ARC9 > Controller)."

-- L["settings.gameplay.font.title"] = "Custom Font"
-- L["settings.gameplay.font.desc"] = "Write the custom font that should be used on ARC9.\n\nNote 1: The font must be installed on your current machine.\n\nNote 2: The name should be the font name displayed in the TTF file, not the file name of the TTF."

////////////////////// Attachments & NPCs
L["settings.tabname.attachmentsnpcs"] = "Обвесы и NPC"

////////// Customization
-- L["settings.tabname.customization.desc"] = "Adjust settings related to weapon customizing."

-- L["settings.server.custmenu.atts_nocustomize.title"] = "Disable Customizing"
-- L["settings.server.custmenu.atts_nocustomize.desc"] = "Disables the ability for users to open the customization menu.\n\nDoes not affect admins."

-- L["settings.server.custmenu.blacklist.title"] = "Blacklist Menu"
-- L["settings.server.custmenu.blacklist.desc"] = "Opens a menu that allows certain attachments to be completely disabled."
-- L["settings.server.custmenu.blacklist.open"] = "OPEN MENU"

-- L["settings.server.custmenu.atts_max.title"] = "Max Attachments"
-- L["settings.server.custmenu.atts_max.desc"] = "The maximum number of attachments a user can equip onto a weapon, including cosmetic ones."

-- L["settings.server.custmenu.free_atts.title"] = "Free Attachments"
-- L["settings.server.custmenu.free_atts.desc"] = "Attachments can be used without the need of picking them up first."

-- L["settings.server.custmenu.atts_lock.title"] = "Unlimited Attachment Units"
-- L["settings.server.custmenu.atts_lock.desc"] = "If disabled, the user has an attachment and has it equipped onto a weapon, they cannot put it onto another weapon unless they have more than one of that attachment."

-- L["settings.server.custmenu.atts_loseondie.title"] = "Lose Attachments on Death"
-- L["settings.server.custmenu.atts_loseondie.desc"] = "If the user dies, they'll lose all of their attachments."

-- L["settings.server.custmenu.atts_generateentities.title"] = "Generate Attachment Entities"
-- L["settings.server.custmenu.atts_generateentities.desc"] = "Generate entities that can be spawned via the Spawnmenu, allowing you to pick up attachments when \"Free Attachments\" is disabled.\n\nIncreases loading times."

////////// NPC Settings
-- L["settings.tabname.npc"] = "NPC Settings"
-- L["settings.tabname.npc.desc"] = "Adjust settings for interaction with NPC's."

-- L["settings.server.npc.npc_autoreplace.title"] = "Replace NPC Weapons"
-- L["settings.server.npc.npc_autoreplace.desc"] = "NPC's that spawn with HL2 weapons will have them be replaced with ARC9 weapons."

-- L["settings.server.npc.npc_atts.title"] = "Give NPC Weapons Random Attachments"
-- L["settings.server.npc.npc_atts.desc"] = "NPC's with ARC9 weapons will receive a random set of attachments"

-- L["settings.server.npc.replace_spawned.title"] = "Replace Ground Weapons"
-- L["settings.server.npc.replace_spawned.desc"] = "Replace map or spawned HL2 weapons with randomly chosen ARC9 weapons"

-- L["settings.server.npc.ground_atts.title"] = "Give Ground Weapons Random Attachments"
-- L["settings.server.npc.ground_atts.desc"] = "Weapons spawned on the ground will receive a random set of attachments."

-- L["settings.server.npc.npc_give_weapons.title"] = "Allow Weapon Swapping between Players & NPCs"
-- L["settings.server.npc.npc_give_weapons.desc"] = "Allow the players to press their USE key on NPC's to give them or swap their ARC9 weapons."

-- L["settings.server.npc.npc_equality.title"] = "Enable NPC Damage Equality"
-- L["settings.server.npc.npc_equality.desc"] = "NPC's do equal damage with ARC9 weapons as players do."

-- L["settings.server.npc.npc_spread.title"] = "NPC Spread"
-- L["settings.server.npc.npc_spread.desc"] = "Multiply the accuracy for weapons when NPC's are shooting them."

////////////////////// Bullet Physics
-- L["settings.tabname.bulletphysics"] = "Bullet Physics"

////////// Bullet Physics
-- L["settings.tabname.bulletphysics.desc"] = "Adjust settings related to physical bullets."

-- L["settings.server.bulletphysics.bullet_physics.title"] = "Enable Physical Bullets"
-- L["settings.server.bulletphysics.bullet_physics.desc"] = "Weapons that support this shoot physical projectiles which are affected by bullet drop, drag and travel time."

-- L["settings.server.bulletphysics.bullet_gravity.title"] = "Bullet Gravity"
-- L["settings.server.bulletphysics.bullet_gravity.desc"] = "How much physical bullets are affected by gravity."

-- L["settings.server.bulletphysics.bullet_drag.title"] = "Bullet Drag"
-- L["settings.server.bulletphysics.bullet_drag.desc"] = "How much air resistance physical bullets will have."

-- L["settings.server.bulletphysics.bullet_lifetime.title"] = "Bullet Life Time"
-- L["settings.server.bulletphysics.bullet_lifetime.desc"] = "How long, in seconds, it takes for a physical bullet to be removed from existence."

-- L["settings.server.bulletphysics.ricochet.title"] = "Enable Bullet Ricochet"
-- L["settings.server.bulletphysics.ricochet.desc"] = "Allows bullets to bounce off of hard surfaces, potentially striking unsuspecting foes.\n\nEffectiveness depends on the weapon."

-- L["settings.server.bulletphysics.mod_penetration.title"] = "Enable Bullet Penetration"
-- L["settings.server.bulletphysics.mod_penetration.desc"] = "Allows bullets to pierce cover, potentially striking foes hiding behind it.\n\nEffectiveness depends on the weapon."

////////////////////// Modifiers
-- L["settings.tabname.modifiers"] = "Modifiers"

////////// Quick Stat Modifiers
-- L["settings.tabname.quickstat"] = "Quick Stat Modifiers"
-- L["settings.tabname.quickstat.desc"] = "Quickly adjust specific weapon modifiers."

-- L["settings.server.quickstat.mod_damage.title"] = "Damage"

-- L["settings.server.quickstat.mod_malfunction.title"] = "Malfunction Chance"

-- L["settings.server.quickstat.mod_damage.desc"] = "Multiply how much damage weapons deal."
-- L["settings.server.quickstat.mod_spread.desc"] = "Multiply how much spread the weapons have."
-- L["settings.server.quickstat.mod_recoil.desc"] = "Multiply how much recoil the weapon has."
-- L["settings.server.quickstat.mod_visualrecoil.desc"] = "Multiply how much visual recoil the weapon has."
-- L["settings.server.quickstat.mod_adstime.desc"] = "Multiply how quickly the weapon goes in and out of ADS."
-- L["settings.server.quickstat.mod_sprinttime.desc"] = "Multiply how quickly the weapon enters and exits sprint."
-- L["settings.server.quickstat.mod_damagerand.desc"] = "Multiply damage variance, which adds or removes damage at random."
-- L["settings.server.quickstat.mod_muzzlevelocity.desc"] = "Multiply how fast the physical bullets move."
-- L["settings.server.quickstat.mod_rpm.desc"] = "Multiply how quickly the weapon fires."
-- L["settings.server.quickstat.mod_headshotdamage.desc"] = "Multiply how much damage the weapon deals on headshots."
-- L["settings.server.quickstat.mod_malfunction.desc"] = "Multiply how likely it is for the weapon to malfunction."

L["settings.server.gameplay.mod_overheat.title"] = "Включить перегревы"
-- L["settings.server.gameplay.mod_overheat.desc"] = "If the weapon supports it, it can overheat when firing too often, which could lead to a malfunction."

////////////////////// Developer
-- L["settings.tabname.developer"] = "Developer"

////////// Developer Settings
-- L["settings.tabname.developer.settings"] = "Developer Settings"
-- L["settings.tabname.developer.settings.desc"] = "General settings for developers."

-- L["settings.server.developer.reloadlangs.title"] = "Reload Languages"
-- L["settings.server.developer.reloadlangs.desc"] = "Reloads all ARC9 language files."

-- L["settings.server.developer.reloadatts.title"] = "Reload Attachments"
-- L["settings.server.developer.reloadatts.desc"] = "Reloads all ARC9 attachments."

-- L["settings.server.developer.dev_always_ready.title"] = "Always Ready"
-- L["settings.server.developer.dev_always_ready.desc"] = "When enabled, weapons will always play their \"ready\" animation."

-- L["settings.server.developer.dev_benchgun.title"] = "Benchgun"
-- L["settings.server.developer.dev_benchgun.desc"] = "When enabled, the viewmodel will remain in place, independant from where you are standing."

-- L["settings.server.developer.dev_crosshair.title"] = "Developer Crosshair"
-- L["settings.server.developer.dev_crosshair.desc"] = "A funky looking crosshair showing the exact point of aim and some useful variables.\n\nOnly works for administrators; don't even try to get cheaty with this."

-- L["settings.server.developer.dev_show_affectors.title"] = "Display Affectors"
-- L["settings.server.developer.dev_show_affectors.desc"] = "On the \"Developer Crosshair\", displays which current affectors are applied."

-- L["settings.server.developer.dev_show_shield.title"] = "Show Shield"
-- L["settings.server.developer.dev_show_shield.desc"] = "Show the protecting model of the player's shield."

-- L["settings.server.developer.dev_greenscreen.title"] = "Green Screen"
-- L["settings.server.developer.dev_greenscreen.desc"] = "Applies a green screen background when in the customization menu.\n\nUseful for screenshots.\n\nIf you use HDR, don't forget to set \"mat_bloom_scalefactor_scalar\" to 0!"

-- L["settings.server.developer.presets_clear.title"] = "Clear Weapon Data"
-- L["settings.server.developer.presets_clear.desc"] = "Clears presets, icons and default presets for the weapon you are currently holding.\n\nWarning: If used without an ARC9 weapon equipped, it will clear the presets, icons and default presets for all ARC9 weapons."

-- L["settings.server.developer.reload"] = "RELOAD"
-- L["settings.server.developer.clear"] = "CLEAR"

////////// Asset Caching
-- L["settings.tabname.assetcache"] = "Asset Caching"
-- L["settings.tabname.assetcache.desc"] = "Caching certain assets can prevent stutters for more comfortable gameplay.\n\nIf running on an HDD, or with a lot of addons, these options will improve initial loading times."

-- L["settings.server.assetcache.precache_sounds_onfirsttake.title"] = "On Weapon Equip: Cache Sounds"
-- L["settings.server.assetcache.precache_sounds_onfirsttake.desc"] = "Caches the firing sounds for the ARC9 weapon you equip.\n\nCan cause a small game freeze when equipping weapons for the first time."

-- L["settings.server.assetcache.precache_attsmodels_onfirsttake.title"] = "On Weapon Equip: Cache Attachments"
-- L["settings.server.assetcache.precache_attsmodels_onfirsttake.desc"] = "Caches all ARC9 attachment models when any ARC9 weapon is equipped.\n\nCan cause a long game freeze, depending on how many ARC9 weapons you have."

-- L["settings.server.assetcache.precache_wepmodels_onfirsttake.title"] = "On Weapon Equip: Cache Weapon Models"
-- L["settings.server.assetcache.precache_wepmodels_onfirsttake.desc"] = "Caches all ARC9 viewmodels when any ARC9 weapon is equipped.\n\nCan cause a very long game freeze, depending on how many ARC9 weapons you have."

-- L["settings.server.assetcache.precache_allsounds_onstartup.title"] = "On Game Start: Cache Sounds"
-- L["settings.server.assetcache.precache_allsounds_onstartup.desc"] = "Caches all firing sounds for all ARC9 weapons when the server starts up.\n\nCan cause a temporary game freeze."

-- L["settings.server.assetcache.precache_attsmodels_onstartup.title"] = "On Game Start: Cache Attachments"
-- L["settings.server.assetcache.precache_attsmodels_onstartup.desc"] = "Caches all ARC9 attachment models when the server starts up.\n\nCan cause a long game freeze, depending on how many ARC9 weapons you have."

-- L["settings.server.assetcache.precache_wepmodels_onstartup.title"] = "On Game Start: Cache Weapon Models"
-- L["settings.server.assetcache.precache_wepmodels_onstartup.desc"] = "Caches all ARC9 viewmodels when the server starts up.\n\nCan cause a very long game freeze, depending on how many ARC9 weapons you have."

-- L["settings.server.assetcache.precache_allsounds.title"] = "Cache All Sounds"
-- L["settings.server.assetcache.precache_allsounds.desc"] = "Caches all firing sounds on all ARC9 weapons.\n\nCan cause a temporary game freeze."

-- L["settings.server.assetcache.precache_attsmodels.title"] = "Cache All Attachment Models"
-- L["settings.server.assetcache.precache_attsmodels.desc"] = "Caches all ARC9 attachment models.\n\nCan cause a long game freeze, depending on how many ARC9 weapons you have."

-- L["settings.server.assetcache.precache_wepmodels.title"] = "Cache All Weapon Models"
-- L["settings.server.assetcache.precache_wepmodels.desc"] = "Caches all ARC9 viewmodels.\n\nCan cause a very long game freeze, depending on how many ARC9 weapons you have."

-- L["settings.server.assetcache"] = "CACHE"
-- L["settings.server.assetcache.all"] = "CACHE ALL"

////////// Print to Console
-- L["settings.tabname.printconsole"] = "Print to Console"
-- L["settings.tabname.printconsole.desc"] = "Press \"Print\" on any of these and they will print what is requested into your developer console."

-- L["settings.server.printconsole.dev_listmyatts.title"] = "Print My Attachments"
-- L["settings.server.printconsole.dev_listmyatts.desc"] = "Prints the internal names of all currently equipped attachments."

-- L["settings.server.printconsole.dev_listanims.title"] = "Print Animation List"
-- L["settings.server.printconsole.dev_listanims.desc"] = "Prints the full internal animation list, including their animation length."

-- L["settings.server.printconsole.dev_listbones.title"] = "Print Bone List"
-- L["settings.server.printconsole.dev_listbones.desc"] = "Prints the full list of bones from the viewmodel skeleton."

-- L["settings.server.printconsole.dev_listbgs.title"] = "Print Bodygroups"
-- L["settings.server.printconsole.dev_listbgs.desc"] = "Prints the full list of bodygroups for the viewmodel."

-- L["settings.server.printconsole.dev_listatts.title"] = "Print QCAttachments"
-- L["settings.server.printconsole.dev_listatts.desc"] = "Prints all of the QCAttachments for the viewmodel."

-- L["settings.server.printconsole.dev_listmats.title"] = "Print Materials List"
-- L["settings.server.printconsole.dev_listmats.desc"] = "Prints all of the materials used on the viewmodel."

-- L["settings.server.printconsole.dev_export.title"] = "Print Export Code"
-- L["settings.server.printconsole.dev_export.desc"] = "Prints an export code for the weapon's currently equipped attachments.\n\nCan be stored or shared with other users to quickly load a list of attachments."

-- L["settings.server.printconsole.dev_getjson.title"] = "Print Weapon JSON"
-- L["settings.server.printconsole.dev_getjson.desc"] = "Prints a JSON entry for the weapon."

-- L["settings.server.printconsole"] = "PRINT"

////////////////////// ARC9 Premium
L["premium.title"] = "ARC9 Premium"
L["premium.desc"] = "ARC9 Premium дает возможность дополнительной настройки в качестве большой благодарности за финансовую поддержку аддона."

L["premium.requires"] = "Требуется <color=255,106,0>ARC9 Premium</color>."
L["premium.acquire"] = "Подписаться на <color=255,106,0>ARC9 Premium</color>"

L["premium.ownedno"] = "<color=255,106,0>ARC9 Premium</color>: <color=255,100,100>Не принадлежит</color>"
L["premium.owned"] = "<color=255,106,0>ARC9 Premium</color>: <color=255,100,100>Владеет</color>"

L["premium.help"] = "Что такое ARC9 Premium?"
L["premium.help.header"] = "Руководство по ARC9 Premium"
L["premium.help.desc"] = "Создание аддонов требует времени и ресурсов. ARC9 всегда была доступна бесплатно, и так будет и впредь. Однако, если вы хотите поддержать базу финансово, вы можете сделать это и получить за это вознаграждение!"

L["premium.help.ownedbutnoaccess"] = "Вы недавно приобрели ARC9 Premium, но не имеете к нему автоматического доступа? Свяжитесь с нами на сервере Diamond Doves Discord, чтобы получить помощь.\nПрежде чем связаться с нами, убедитесь, что вы можете предоставить доказательства покупки. Просто сказать \"Я купил, теперь дайте\" недостаточно."

L["premium.content"] = "Включено в <color=255,106,0>ARC9 Premium</color>:"
L["premium.content.list"] = [[
- Неограниченное количество слотов кастомизации (увеличено с 32)
- Неограниченное количество слотов предустановок (увеличено с 10 на оружие)
- Доступ к настройкам супермодификатора*
- Доступ к эксклюзивному режиму темного пользовательского интерфейса
- Возможность окрашивать оптические прицелы, пользовательский интерфейс и многое другое
- Эксклюзивные камуфляжи, доступные через базу
- Эксклюзивный канал поддержки в Discord

* Требуется администратор, если вы находитесь на сервере
]]

L["premium.payment.month"] = [[
%s₽
Приобретите ARC9 Premium на 1 месяц.
]]

L["premium.payment.months"] = [[
%s₽
Приобретите ARC9 Premium на 3 месяца и получите <color=100,255,100>скидку %s%%</color>!
]]

L["premium.payment.info"] = [[
Приобретение ARC9 Premium дает немедленный доступ ко всему содержимому, перечисленному ранее, на время покупки.
Время можно продлить, купив любую из опций еще раз, и оно обновится автоматически по истечении первоначального времени.
По истечении времени и при отсутствии дополнительной оплаты доступ к ARC9 Premium будет удален.

Все опции настройки, включая слоты для крепления, пресеты и цветные прицелы, сделанные с помощью ARC9 Premium, останутся доступными, но вы не сможете изменить их или добавить дополнительные.
]]

L["premium.purchased"] = "Вы приобрели <color=255,106,0>ARC9 Premium</color>!"
L["premium.purchased.desc"] = [[
Благодарим вас за покупку ARC9 Premium! Вы сделали птицу очень счастливой!

Квитанция будет отправлена на ваш подключенный Email.

Если вы не сразу получили доступ к бонусам ARC9 Premium, пожалуйста, заново зайдите на сервер или перезапустите игру.

Если у вас все еще возникают проблемы или вы не получили Premium, зайдите на сервер Diamond Doves Discord и предоставьте действительное доказательство покупки, и мы все исправим.
]]
