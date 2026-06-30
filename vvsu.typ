// VVSU Report
// Шаблон для оформления ВКР, курсовых работ, проектов,
// рефератов, контрольных работ, отчетов по практикам,
// лабораторных работ
//
// Основано на СК-СТО-ТР-04-1.005-2015
//
// Vladivostok State University
// Mark Vodyanitskiy (@mvodya), Arkadiy Schneider (@thebandik) 2026

#let template-name = "vvsu-report"
#let template-version = version(6, 0)

#let minimum-typst-version = version(0, 14, 0)
#assert(
  sys.version >= minimum-typst-version,
  message: "vvsu-report minimum typst version required: " + repr(minimum-typst-version),
)

// Конвертация межстрочного интервала из MS Word
#let _msword-leading(ratio) = (1.15 * ratio - 0.6625) * 1em

// Проверка если строка пустая
#let _is-empty(value) = {
  if value == none { true } else if type(value) == str { value == "" } else { false }
}

// Название кафедры для шапки
// ИИТАД ИТС:
#let vvsu-depart-its = [Институт информационных технологий и анализа данных\
  Кафедра информационных технологий и систем]

// Буквенный список
#let enum-alpha(body) = {
  let numbering-alpha(n) = {
    let letters = (
      "а",
      "б",
      "в",
      "д",
      "е",
      "ж",
      "и",
      "к",
      "л",
      "м",
      "н",
      "п",
      "р",
      "с",
      "т",
      "у",
      "ф",
      "х",
      "ц",
      "ч",
      "ш",
      "щ",
      "э",
      "ю",
      "я",
    )
    if n < 1 or n > letters.len() {
      panic("Не хватает букв для нумерации списка")
    }
    [#letters.at(n - 1))]
  }
  set enum(numbering: numbering-alpha)
  body
}

// Цифровой список
#let enum-num(body) = {
  set enum(numbering: "1)")
  body
}

// Источник для рисунка
#let figure-source(body) = align(left)[
  #set par(first-line-indent: 0pt, leading: _msword-leading(1), spacing: 0pt, justify: false)
  #v(6pt)
  #text(size: 10pt)[Источник: #body]
]

// Нумерация для рисунков
#let _image-counter = counter("vvsu-image")

// Оформление рисунка
#let _image-block(number, caption, source: none, body) = block(above: 12pt + 6pt, below: 12pt + 6pt, breakable: false)[
  #set par(first-line-indent: 0pt, leading: _msword-leading(1), spacing: 0pt, justify: false)
  #align(center)[#body]
  #v(6pt)
  #align(center)[Рисунок #number – #caption]
  #if source != none {
    figure-source(source)
  }
]

// Рисунок
#let figure-image(
  caption,
  tag: none,
  source: none,
  body,
) = context {
  let number-value = _image-counter.get().first() + 1
  let number = numbering("1", number-value)

  _image-block(number, caption, source: source)[
    // Обновляем счетчик и добавляем метаданные для ссылок
    #_image-counter.update(number-value)
    #metadata((kind: "vvsu-image", number: number))
    #if tag != none { tag }
    #body
  ]
}

// Нумерация для таблиц
#let _table-counter = counter("vvsu-table")

// Таблица
#let figure-table(
  caption,
  tag: none,
  source: none,
  breakable: true,
  body,
) = context {
  let number-value = _table-counter.get().first() + 1
  let number = numbering("1", number-value)
  let start-label = label("vvsu-table-start-" + str(number-value))

  block(above: 12pt + 6pt, below: 12pt + 6pt, breakable: breakable)[
    #set par(first-line-indent: 0pt, leading: _msword-leading(1), spacing: 0pt, justify: false)
    // Обновляем счетчик и добавляем метаданные для ссылок
    #_table-counter.update(number-value)
    #metadata((kind: "vvsu-table", number: number))
    #if tag != none { tag }
    // Метка начала нужна для определения страниц продолжений
    #metadata(none) #start-label
    #block(sticky: true)[
      Таблица #number – #caption
      #v(4pt)
    ]
    #align(center)[
      #set text(size: 10pt)
      #body
    ]
    // Метаданные конца нужны для определения последней страницы таблицы
    #metadata((kind: "vvsu-table-range", number: number, number-value: number-value)) #label("vvsu-table-end-" + str(number-value))
    #if source != none {
      align(left)[
        #set par(first-line-indent: 0pt, leading: _msword-leading(1), spacing: 0pt, justify: false)
        #v(6pt)
        #text(size: 10pt)[Источник: #source]
      ]
    }
  ]
}

// Шапка таблицы
#let table-header(
  columns-count,
  ..children,
) = table.header(
  table.cell(colspan: columns-count, inset: 0pt, align: left, stroke: none)[
    #context {
      let number-value = _table-counter.get().first()
      let number = numbering("1", number-value)
      let start-label = label("vvsu-table-start-" + str(number-value))
      let end-label = label("vvsu-table-end-" + str(number-value))
      let current-page = counter(page).get().first()
      let start-page = counter(page).at(query(start-label).first().location()).first()
      let end-page = counter(page).at(query(end-label).first().location()).first()
      if current-page == start-page {
        []
      } else if current-page == end-page {
        [#text(size: 12pt)[Окончание таблицы #number]#v(4pt)]
      } else {
        [#text(size: 12pt)[Продолжение таблицы #number]#v(4pt)]
      }
    }
  ],
  ..children,
)

// Расшифровка формулы (после "где", каждый символ – с новой строки)
// items: массив content вида [$x$ – значение икс] без завершающей пунктуации
#let decoding(items) = context {
  let prefix-width = measure([где]).width
  set par(first-line-indent: 0pt, leading: _msword-leading(1.5))
  grid(
    columns: (prefix-width, 1fr),
    column-gutter: 0.3em,
    row-gutter: _msword-leading(1.5),
    ..items
      .enumerate()
      .map(((i, item)) => {
        let label = if i == 0 { [где] } else { [] }
        let punct = if i == items.len() - 1 { [.] } else { [;] }
        (label, item + punct)
      })
      .flatten()
  )
}

// Ссылка на формулу в тексте (обязательна, в скобках: «…в формуле (1)»)
#let eq-ref(eq-label) = [в формуле #ref(eq-label)]

// Пример использования одной величины в тексте (поясняется одна величина)
#let inline-value(name, symbol, unit, description) = {
  [#name #symbol, #unit, #description]
}


//// Оформление документа
#let vvsu(
  body,
) = {
  // Добавляем метаданные
  set document(
    description: template-name + " / " + str(template-version),
  )

  // Настройки страницы и нумерации страниц
  set page(
    paper: "a4",
    margin: (left: 30mm, right: 10mm, top: 20mm, bottom: 20mm),
    numbering: "1",
    number-align: top + right,
  )

  // Основной шрифт
  set text(lang: "ru", font: "Times New Roman", size: 12pt)
  // Абзацный отступ и 1.5 интервал
  set par(
    justify: true,
    first-line-indent: (amount: 1.25cm, all: true),
    leading: _msword-leading(1.5),
    spacing: _msword-leading(1.5),
  )

  // Настройка нумерации заголовков
  set heading(numbering: "1.1.1")

  // Заголовоки
  show heading: it => {
    if it.level > 3 {
      panic("Разрешены только заголовки 1, 2 и 3 уровней")
    }
    // Стиль заголовка
    let style = if it.level == 1 {
      (font: "Arial", size: 14pt, weight: "regular", before: 0pt, after: 12pt + 6pt)
    } else if it.level == 2 {
      (font: "Arial", size: 13pt, weight: "regular", before: 12pt + 6pt, after: 6pt + 6pt)
    } else {
      (font: "Times New Roman", size: 12pt, weight: "bold", before: 12pt + 2pt, after: 12pt)
    }
    // Первый уровень - на новой странице
    if it.level == 1 {
      pagebreak(weak: true)
    }
    // Блок заголовка
    block(above: style.before, below: style.after)[
      #text(
        font: style.font,
        size: style.size,
        weight: style.weight,
        hyphenate: false,
      )[
        #context {
          // Расчет размера нумерации для выравнивания переноса
          let prefix = if it.numbering == none { [] } else { [#h(1.25cm)#counter(heading).display()~] }
          let prefix-width = measure(prefix).width
          par(
            first-line-indent: 0pt,
            hanging-indent: prefix-width,
            leading: _msword-leading(1),
            justify: false,
          )[
            #box(width: prefix-width)[#prefix]#it.body
          ]
        }
      ]
    ]
  }

  // Списки
  set list(marker: ([–], [–], [–]), indent: 0pt, body-indent: 0pt, spacing: 0pt)
  set enum(numbering: "1)", indent: 0pt, body-indent: 0pt, spacing: 0pt)
  let list-render(kind, level: 1, items) = {
    if level > 3 {
      panic("Разрешены только списки 1, 2 и 3 уровней")
    }
    for (i, item) in items.children.enumerate() {
      let marker = if kind == "enum" {
        if type(items.numbering) == function { (items.numbering)(i + 1) } else { numbering(items.numbering, i + 1) }
      } else { [–] }
      let body = {
        set par(first-line-indent: 0pt)
        show list: it => list-render("list", level: level + 1, it)
        show enum: it => list-render("enum", level: level + 1, it)
        item.body
      }
      grid(
        columns: (1.25cm, 1fr),
        marker, body,
      )
    }
  }
  show list: it => list-render("list", it)
  show enum: it => list-render("enum", it)

  // Рисунки
  set figure(numbering: "1", supplement: [Рисунок], gap: 0pt)
  show figure.where(kind: image): it => {
    if it.caption == none {
      panic("У рисунка должна быть подпись")
    }
    _image-block(it.counter.display(it.numbering), it.caption.body, body: it.body)
  }

  // Формулы
  // Настройка нумерации формул (сквозная по работе)
  set math.equation(
    numbering: "(1)",
    number-align: bottom + right,
  )

  // Показ формул с правильным расположением:
  // отдельной строкой по центру, по одной свободной строке выше и ниже
  show math.equation.where(block: true): it => {
    block(
      above: 12pt + 6pt,
      below: 12pt + 6pt,
      breakable: false,
      it,
    )
  }

  // Настройка ссылок на элементы
  show ref: it => {
    if it.element != none and it.element.func() == metadata and type(it.element.value) == dictionary and "kind" in it.element.value and it.element.value.kind == "vvsu-image" {
      // Ссылки на рисунки
      link(it.target)[#it.element.value.number]
    } else if it.element != none and it.element.func() == figure and it.element.kind == image {
      // Ссылки на рисунки (ванильный figure)
      context {
        let number = numbering(it.element.numbering, ..it.element.counter.at(it.element.location()))
        link(it.target)[#number]
      }
    } else if it.element != none and it.element.func() == metadata and type(it.element.value) == dictionary and "kind" in it.element.value and it.element.value.kind == "vvsu-table" {
      // Ссылки на таблицы
      link(it.target)[#it.element.value.number]
    } else if it.element != none and it.element.func() == math.equation {
      // Ссылки на формулы – только номер в скобках
      context {
        let number = numbering(it.element.numbering, ..counter(math.equation).at(it.element.location()))
        link(it.target)[#number]
      }
    } else {
      // Прочее
      it
    }
  }

  body
}



//// Титульный лист
#let title-page(
  department: none, // Кафедра в шапке (реквизит 4)
  title: "БЕЗ НАЗВАНИЯ", // Название документа (реквизит 6)
  title2: none, // Описание работы (реквизит 7)
  title3: none, // Название работы (реквизит 8)
  code: none, // Код работы
  stamp: none, // Гриф допуска к защите (реквизит 5)
  authors: (), // Список авторов (реквизит 9-14)
  year: datetime.today().year(), // Год выполнения работы (реквизит 15)
) = context {
  // Добавляем метаданные
  set document(
    title: title + " " + title2 + " " + title3,
  )

  // Отключаем нумерацию
  set page(numbering: none)

  // Шапка
  align(center)[
    #set par(leading: _msword-leading(1), spacing: _msword-leading(1.5))
    #set text(size: 14pt)
    #upper[Минобрнауки России]

    Федеральное государственное бюджетное образовательное учреждение\
    высшего образования\

    «#upper[Владивостокский Государственный Университет]»\
    (ФГБОУ ВО «ВВГУ»)\

    #if not _is-empty(department) [
      Институт информационных технологий и анализа данных\
      Кафедра информационных технологий и систем
    ]
  ]

  // Реквизит 5
  if not _is-empty(stamp) {
    v(1fr)
    align(right)[
      #if type(stamp) == content {
        // Кастомный реквизит
        stamp
      } else {
        // Стандартный реквизит
        block()[
          #let title = if type(stamp) == dictionary and "title" in stamp { stamp.title } else { [Рекомендовано] }
          #let title2 = if type(stamp) == dictionary and "title2" in stamp { stamp.title2 } else { [к защите] }
          #let role = if type(stamp) == dictionary and "role" in stamp { stamp.role } else {
            [Должность\ рекомендующего]
          }
          #let name = if type(stamp) == dictionary and "name" in stamp { stamp.name } else { [А.И. Рекомендатор] }
          #align(center)[
            #set par(leading: _msword-leading(1.5))
            #set text(size: 12pt)
            #upper(title)\
            #title2\
            #role\
            #grid(
              columns: (5em, auto),
              column-gutter: 0.4em,
              align: bottom,
              line(length: 100%), name,
            )
          ]
        ]
      }
    ]
  }

  v(1fr)
  // Реквизит 6
  if not _is-empty(title) {
    align(center)[
      #set par(leading: _msword-leading(1), spacing: _msword-leading(1.5), justify: false)
      #text(size: 24pt, hyphenate: false)[
        #upper(title)
      ]
    ]
  }
  // Реквизит 7
  if not _is-empty(title2) {
    align(center)[
      #set par(leading: _msword-leading(1), spacing: _msword-leading(1.5), justify: false)
      #text(size: 18pt, hyphenate: false)[
        #title2
      ]
    ]
  }
  // Реквизит 8
  if not _is-empty(title3) {
    align(center)[
      #set par(leading: _msword-leading(1), spacing: _msword-leading(1.5), justify: false)
      #text(size: 20pt, hyphenate: false)[
        #title3
      ]
    ]
  }
  // Реквизит 8.5 (код работы)
  if not _is-empty(code) {
    align(center)[
      #set par(leading: _msword-leading(1), spacing: _msword-leading(1.5), justify: false)
      #text(size: 20pt, hyphenate: false)[
        #code
      ]
    ]
  }
  v(1fr)
  // Реквизиты 9-14 (авторы)
  block[
    #set par(leading: _msword-leading(1), spacing: _msword-leading(1.5))
    #table(
      columns: (auto, 1fr, auto),
      inset: 0pt,
      stroke: none,
      align: bottom,
      column-gutter: 1em,
      row-gutter: 1em,
      ..authors
        .map(author => {
          let role = if type(author) == dictionary and "role" in author { author.role } else { [] }
          let name = if type(author) == dictionary and "name" in author { author.name } else { [] }
          ([#role], [#line(length: 100%)], [#name])
        })
        .flatten(),
    )
  ]
  v(1fr)
  align(center)[Владивосток #year]
  pagebreak(weak: true)
}



//// Страницы, не включенные в содержание
// Задание, Аннотация, Реферат
#let front-matter-page(
  title: none,
  body,
) = context {
  // Сохраняем страницу для пропуска нумерации
  let saved-page = counter(page).get().first()

  // На новой странице
  pagebreak(weak: true)
  // Без нумерации
  set page(numbering: none)

  // Заголовок страницы
  if not _is-empty(title) {
    align(center)[
      #set par(
        first-line-indent: 0pt,
        leading: _msword-leading(1),
        spacing: 0pt,
        justify: false,
      )
      #text(font: "Arial", size: 14pt, hyphenate: false)[
        #title
      ]
    ]
    v(6pt)
  }

  body

  pagebreak(weak: true)
  // Восстанавливаем номер страницы для пропуска нумерации
  counter(page).update(saved-page)
}



//// Страницы, включенные в содержание
// Введение, Заключение
#let outline-page(
  title: none,
  body,
) = context {
  // На новой странице
  pagebreak(weak: true)

  // Заголовок страницы
  if not _is-empty(title) {
    align(center)[
      #set par(
        first-line-indent: 0pt,
        leading: _msword-leading(1),
        spacing: 0pt,
        justify: false,
      )
      #text(font: "Arial", size: 14pt, hyphenate: false)[
        #heading(level: 1, numbering: none)[#title]
      ]
    ]
    v(6pt)
  }

  body
}
// Введение
#let introduction(body) = outline-page(title: [Введение])[#body]
// Заключение
#let conclusion(body) = outline-page(title: [Заключение])[#body]

//// Список использованных источников (на основе .bib-файла)

// Простой парсер BibTeX: поддерживает записи вида
// @type{key, field = {value}, field = {value}, }
// Строки, начинающиеся с "%" (комментарии BibTeX), игнорируются
#let _parse-bib(text) = {
  let text = text.split("\n").filter(line => not line.trim().starts-with("%")).join("\n")
  let entries = (:)
  for raw in text.split("@").slice(1) {
    let header = raw.match(regex("^(\w+)\s*\{\s*([^,]+),"))
    if header == none { continue }
    let entry-type = lower(header.captures.at(0))
    let key = header.captures.at(1).trim()
    let fields = (:)
    // Значение поля – допускается один уровень вложенных {} (например {REST API} для защиты регистра)
    for fm in raw.matches(regex("(\w+)\s*=\s*\{((?:[^{}]|\{[^{}]*\})*)\}")) {
      let value = fm.captures.at(1).trim()
      // Скобки-протекторы регистра в значении не выводятся
      value = value.replace(regex("\{([^{}]*)\}"), m => m.captures.at(0))
      fields.insert(lower(fm.captures.at(0)), value)
    }
    fields.insert("type", entry-type)
    fields.insert("key", key)
    entries.insert(key, fields)
  }
  entries
}

// Загрузка и разбор .bib-файла с источниками
// Пример: #let sources = read-sources("sources.bib")
#let read-sources(path) = _parse-bib(read(path))

// "Фамилия, И. О." -> "И. О. Фамилия"
#let _swap-name(name) = {
  let parts = name.split(",")
  if parts.len() != 2 { name } else {
    parts.at(1).trim() + " " + parts.at(0).trim()
  }
}

// Список авторов записи (поле author, авторы разделены "and")
#let _bib-authors(f) = {
  let raw = f.at("author", default: none)
  if raw in (none, "") { () } else { raw.split(" and ").map(a => a.trim()) }
}

// "12--18" -> "12–18"
#let _bib-dash(s) = s.replace("--", "–")

// Книга: Фамилия, И.О. Название : подзаголовок / И.О. Фамилия. – Город : Издательство, год. – с. с.
// Город, издательство и год – необязательны по отдельности (пропускаются, если не заданы в .bib)
#let _fmt-bib-book(f) = {
  let authors = _bib-authors(f)
  // Под именем автора – если 1–2 автора, при 3 и более – сразу под заглавием
  let lead = if authors.len() in (1, 2) { authors.at(0) + " " } else { "" }
  let title = f.at("title", default: "")
  let subtitle = f.at("subtitle", default: none)
  let title-part = title + (if subtitle not in (none, "") { " : " + subtitle } else { "" })
  let by = if authors.len() > 0 { " / " + authors.map(_swap-name).join(", ") } else { "" }
  let address = f.at("address", default: none)
  let publisher = f.at("publisher", default: none)
  let year = f.at("year", default: none)
  let pages = f.at("pages", default: none)

  let loc-pub = (
    if address not in (none, "") { (address,) } else { () }
      + if publisher not in (none, "") { (publisher,) } else { () }
  ).join(" : ", default: "")
  let imprint = (
    if loc-pub != "" { (loc-pub,) } else { () }
      + if year not in (none, "") { (year,) } else { () }
  ).join(", ", default: "")

  let out = lead + title-part + by + "."
  if imprint != "" { out += " – " + imprint + "." }
  if pages not in (none, "") { out += " – " + _bib-dash(pages) + " с." }
  out
}

// Статья: Фамилия, И.О. Название [/ соавторы] // Журнал. – год. – Т. N, № N. – С. с.
#let _fmt-bib-article(f) = {
  let authors = _bib-authors(f)
  let lead = if authors.len() == 1 { authors.at(0) + " " } else { "" }
  let title = f.at("title", default: "")
  let journal = f.at("journal", default: none)
  let year = f.at("year", default: none)
  let volume = f.at("volume", default: none)
  let number = f.at("number", default: none)
  let pages = f.at("pages", default: none)
  let by = if authors.len() > 1 { " / " + authors.map(_swap-name).join(", ") } else { "" }
  let out = lead + title + by
  if journal not in (none, "") { out += " // " + journal }
  out += "."
  if year not in (none, "") { out += " – " + year + "." }
  if volume not in (none, "") {
    out += " – Т. " + volume
    if number not in (none, "") { out += ", № " + number }
    out += "."
  } else if number not in (none, "") {
    out += " – № " + number + "."
  }
  if pages not in (none, "") { out += " – С. " + _bib-dash(pages) + "." }
  out
}

// Электронный ресурс / стандарт / прочее: используется howpublished (или url), либо note целиком
#let _fmt-bib-misc(f) = {
  let title = f.at("title", default: none)
  let url = f.at("howpublished", default: f.at("url", default: none))
  let note = f.at("note", default: none)
  if title in (none, "") and url in (none, "") and note in (none, "") {
    panic("Источник «" + f.at("key", default: "?") + "» не содержит данных (нужно поле title, note или howpublished/url)")
  }
  if url not in (none, "") {
    title + " [Электронный ресурс]. – Режим доступа: " + url + (if note not in (none, "") { " (" + note + ")" } else { "" }) + "."
  } else if note not in (none, "") {
    note
  } else {
    title
  }
}

// Форматирование записи источника по ГОСТ в зависимости от @type{...}
#let _fmt-bib-entry(f) = {
  if f.type == "book" { _fmt-bib-book(f) }
  else if f.type == "article" { _fmt-bib-article(f) }
  else { _fmt-bib-misc(f) }
}

// Метка-маркер упоминания источника в тексте (для query)
#let _cite-marker = <vvsu-cite>

// Порядок ключей по первому упоминанию в тексте (вычисляется из всех маркеров документа)
#let _cite-order() = {
  let order = ()
  for it in query(_cite-marker) {
    if it.value not in order {
      order += (it.value,)
    }
  }
  order
}

// Метка записи источника в списке (для кликабельной ссылки)
#let _ref-label(key) = label("vvsu-ref-" + key)

// Ссылка на источник в тексте: «…технологии [1]» – кликабельна, ведет на запись в списке
// key – метка источника, например #cite-ref(<ivanov2024>)
// Нумерация – по порядку первого упоминания в тексте
#let cite-ref(key) = {
  let key = str(key)
  [#metadata(key)#_cite-marker]
  context {
    let order = _cite-order()
    link(_ref-label(key))[[#(order.position(k => k == key) + 1)]]
  }
}

// Список использованных источников (выводится в порядке упоминания в тексте)
// sources – словарь, полученный через #read-sources("sources.bib")
#let references(sources) = context {
  let order = _cite-order()
  outline-page(title: [Список использованных источников])[
    #set text(size: 12pt)
    #for (i, key) in order.enumerate() {
      if i > 0 { parbreak() }
      if key not in sources {
        panic("Источник «" + key + "» упомянут в тексте, но отсутствует в списке источников (.bib)")
      }
      [#(i + 1) #_fmt-bib-entry(sources.at(key))#_ref-label(key)]
    }
  ]
}



//// Содержание
#let toc(title: [Содержание]) = context {
  // На новой странице
  pagebreak(weak: true)
  // Без нумерации
  set page(numbering: none)

  // Заголовок страницы
  align(center)[
    #set par(
      first-line-indent: 0pt,
      leading: _msword-leading(1),
      spacing: 0pt,
      justify: false,
    )
    #text(font: "Arial", size: 14pt, hyphenate: false)[
      #title
    ]
  ]
  v(6pt)

  // Настройка интервалов
  set par(
    first-line-indent: 0pt,
    leading: _msword-leading(1),
    spacing: _msword-leading(1.5),
    justify: false,
  )

  // Настройка TOC
  show outline.entry: it => {
    let level = it.level
    // Расчет отступа в зависимости от уровня заголовка
    let indent = 1.25cm * (level - 1)
    let number = if it.element.numbering == none {
      []
    } else {
      numbering(it.element.numbering, ..counter(heading).at(it.element.location()))
    }
    // Префикс заголовка (номер, если есть)
    let prefix = if number == [] { [] } else { [#number#h(0.25em)] }

    context {
      // Номер страницы
      let page = counter(page).at(it.element.location()).first()
      // Расчет длинны префикса (для отступа)
      let prefix-width = measure([#h(indent)#prefix]).width
      par(hanging-indent: prefix-width)[
        // Номер и заголовок
        #h(indent)#prefix#link(it.element.location(), it.element.body)
        // Точки
        #box(width: 1fr, repeat[.])
        // Страница
        #link(it.element.location(), str(page))
      ]
    }
  }

  outline(title: none, indent: auto)
  pagebreak()
}
