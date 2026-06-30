// VVSU Report
// Шаблон для оформления ВКР, курсовых работ, проектов,
// рефератов, контрольных работ, отчетов по практикам,
// лабораторных работ
//
// Основано на СК-СТО-ТР-04-1.005-2015
//
// Vladivostok State University
// Mark Vodyanitskiy (@mvodya) 2026

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
    let letters = ("а", "б", "в", "д", "е", "ж", "и", "к", "л", "м", "н", "п", "р", "с", "т", "у", "ф", "х", "ц", "ч", "ш", "щ", "э", "ю", "я")
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
        hyphenate: false
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
        marker,
        body,
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
          #let role = if type(stamp) == dictionary and "role" in stamp { stamp.role } else { [Должность\ рекомендующего] }
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
              line(length: 100%),
              name
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
    #set par(leading: _msword-leading(1),spacing: _msword-leading(1.5))
    #table(
      columns: (auto, 1fr, auto),
      inset: 0pt,
      stroke: none,
      align: bottom,
      column-gutter: 1em,
      row-gutter: 1em,
      ..authors.map(author => {
        let role = if type(author) == dictionary and "role" in author { author.role } else { [] }
        let name = if type(author) == dictionary and "name" in author { author.name } else { [] }
        ([#role], [#line(length: 100%)], [#name])
      }).flatten(),
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
  body
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
  body
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
    let indent =  1.25cm * (level - 1)
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
