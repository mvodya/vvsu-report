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
#let template-version = version(6, 0, 0)

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

// Оформление документа
#let vvsu(
  body,
) = {
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
      (font: "Arial", size: 13pt, weight: "regular", before: 12pt, after: 6pt + 6pt)
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
          let prefix = [#h(1.25cm)#counter(heading).display()~]
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

  body
}

// Титульный лист
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
  pagebreak()
}
