# now


A Quarto extension for inserting the current or last modified date and
time in the format of your choosing.

## Installing

``` bash
quarto add gadenbuie/quarto-now
```

This will install the **now** extension under the `_extensions`
subdirectory. If you’re using version control, you will want to check in
this directory.

## Get Started

The **now** extension provides two shortcodes: `now` and `modified`.
Both take an optional additional argument specifying the desired format
of the date and/or time.

### Last rendered time

Use the `{{< now >}}` shortcode anywhere you want to include the current
date and/or time in your document.

``` markdown
Document last rendered: {{< now >}}.
```

> Document last rendered: 2024-03-28 20:49:34.

> [!TIP]
>
> ### What does “last rendered” mean?
>
> “Last rendered” means the date and time when you called
> `quarto render` or when the document was rendered by `quarto preview`.
>
> Because `now` is a shortcode, its value is re-calculated every time
> the document renders, even if you’ve frozen the document with
> `freeze: true`. Frozen documents don’t re-run computed code chunks,
> but their shortcodes are still re-evaluated.
>
> So `{{< now >}}` is best for things like copyright notices in footers
> – try `{{< now year >}}` for that one – or other places where you know
> that `quarto render` is synonymous with “last updated”.

### Last modified time

Alternatively, you can use the `{{< modified >}}` shortcode to include
the last modified date and/or time of the document. This shortcode uses
the `modified` metadata field to determine the last modified date and
time of the document. On macOS and Linux, the modified timestamp can be
automatically determined from the source file.

``` markdown
---
modified: "2006-05-04 12:34:56"
---

Document last modified: {{< modified >}}.
```

> Document last modified: 2006-05-04 12:34:56.

> [!CAUTION]
>
> ### Automatic file-modified detection
>
> Automatic file-modified detection is only available on macOS and
> Linux, since it relies the `stat` command to determine the last
> modified time of the input document.
>
> If you’re on Windows, or if your system doesn’t support `stat`, you
> can add `modified: "YYYY-MM-DD HH:MM:SS"` to the document metadata to
> specify the last modified date and time.

## Format Aliases

Both `{{< now >}}` and `{{< modified >}}` shortcodes accept an optional
argument specifying the desired format of the date and/or time. You can
use one of the predefined format aliases in the table below.

| Shortcode                 | Result                   | Format String |
|:--------------------------|:-------------------------|:-------------:|
| `{{< now >}}`             | 2024-03-28 20:49:34      |   `"%F %T"`   |
| `{{< now year >}}`        | 2024                     |    `"%Y"`     |
| `{{< now month >}}`       | March                    |    `"%B"`     |
| `{{< now day >}}`         | 28                       |    `"%d"`     |
| `{{< now weekday >}}`     | Thursday                 |    `"%A"`     |
| `{{< now hour >}}`        | 08                       |    `"%I"`     |
| `{{< now minute >}}`      | 49                       |    `"%M"`     |
| `{{< now ampm >}}`        | PM                       |    `"%p"`     |
| `{{< now date >}}`        | 03/28/24                 |    `"%x"`     |
| `{{< now time >}}`        | 20:49:34                 |    `"%X"`     |
| `{{< now datetime >}}`    | Thu Mar 28 20:49:34 2024 |    `"%c"`     |
| `{{< now isodate >}}`     | 2024-03-28               |    `"%F"`     |
| `{{< now isotime >}}`     | 20:49:34                 |    `"%T"`     |
| `{{< now isodatetime >}}` | 2024-03-28T20:49:34-0400 |  `"%FT%T%z"`  |
| `{{< now timestamp >}}`   | 2024-03-28 20:49:34      |   `"%F %T"`   |

Alternatively, you can specify the specific format using the format
strings known to [the Lua `os.date()`
function](https://www.lua.org/pil/22.1.html).

| Value | Description                                  |
|:------|:---------------------------------------------|
| `%a`  | abbreviated weekday name (e.g., `Wed`)       |
| `%A`  | full weekday name (e.g., `Wednesday`)        |
| `%b`  | abbreviated month name (e.g., `Sep`)         |
| `%B`  | full month name (e.g., `September`)          |
| `%c`  | date and time (e.g., `09/16/98 23:48:10`)    |
| `%d`  | day of the month (`16`) \[01-31\]            |
| `%H`  | hour, using a 24-hour clock (`23`) \[00-23\] |
| `%I`  | hour, using a 12-hour clock (`11`) \[01-12\] |
| `%M`  | minute (`48`) \[00-59\]                      |
| `%m`  | month (`09`) \[01-12\]                       |
| `%p`  | either `"am"` or `"pm"` (`pm`)               |
| `%S`  | second (`10`) \[00-61\]                      |
| `%w`  | weekday (`3`) \[0-6 = Sunday-Saturday\]      |
| `%x`  | date (e.g., `09/16/98`)                      |
| `%X`  | time (e.g., `23:48:10`)                      |
| `%Y`  | full year (`1998`)                           |
| `%y`  | two-digit year (`98`) \[00-99\]              |
| `%%`  | the character `%`                            |

When using a custom format string, you can include any additional text
you want. If your format string includes a space, be sure to wrap the
format string in quotes.

``` markdown
Modified {{< modified "on %A, %B %d of %Y" >}}.
```

> Modified on Thursday, May 04 of 2006.
