# homebrew-kiln

Homebrew tap for kiln, a template compiler for [GFI-like](https://github.com/haoxins/gulp-file-include) syntax.

## Install

```bash
brew install teehemkay/kiln/kiln
```

---

Build static website prototypes from small, reusable HTML pieces — no build config, no `gulpfile.js`, no framework. Kiln is a command-line **template compiler for [GFI-like (gulp-file-include)](https://www.npmjs.com/package/gulp-file-include) syntax**: you write plain HTML sprinkled with `@@` directives — includes, variables, conditionals, loops — and kiln resolves them into finished HTML you can open in a browser or hand to a client.


## Your first prototype in five minutes

We'll build a tiny two-page site — a home page and a programme page — that share a `<head>` and a nav bar, with the programme built by repeating one session card over a list of sessions. Then we'll preview it live. Create this layout:

```
site/
├── index.html              ← a page
├── program.html            ← a page
└── components/             ← partials (never built on their own)
    ├── head.html
    ├── nav.html
    └── session-card.html
```

The rule that makes this work: **top-level files are pages; anything in a subfolder is a partial.** Kiln only builds the `.html` files sitting directly in the folder you point it at — partials in `components/` are pulled in by `@@include` and never rendered on their own.

### The pages

**`site/index.html`** — composes partials and hands each one some data:

```html
<!doctype html>
<html lang="en">
@@include('components/head.html', {title: 'Global Entrepreneurship Week'})
<body>
  @@include('components/nav.html', {active: 'home'})

  <main>
    <h1>One week. Thousands of events. Everywhere.</h1>
    <p>Welcome to GEW.</p>
  </main>
</body>
</html>
```

**`site/program.html`** — reuses the *same* partials, then repeats a card for every session via `@@loop`:

```html
<!doctype html>
<html lang="en">
@@include('components/head.html', {title: 'Programme'})
<body>
  @@include('components/nav.html', {active: 'program'})

  <main>
    <h1>Full programme</h1>
    <ul class="sessions">
      @@loop('components/session-card.html', [
        {name: 'Founder AMA',    from: '18:00', to: '18:45', online: true},
        {name: 'Pitch Night',    from: '19:30', to: '21:00', online: false},
        {name: 'Investor Panel', from: '17:00', to: '18:00', online: true}
      ])
    </ul>
  </main>
</body>
</html>
```

### The partials

**`site/components/head.html`** — uses the `title` it was handed:

```html
<head>
  <meta charset="utf-8">
  <title>@@title — GEW</title>
  <link rel="stylesheet" href="/assets/site.css">
</head>
```

**`site/components/nav.html`** — drops the `active` value into an attribute so CSS can highlight the current page:

```html
<nav data-active="@@active">
  <a href="/index.html">Home</a>
  <a href="/program.html">Programme</a>
</nav>
```

**`site/components/session-card.html`** — rendered once per object in the loop. Each object's keys (`name`, `from`, `to`, `online`) become that iteration's variables, and `@@when` / `@@unless` branch on them:

```html
<li class="session">
  <h3>@@name</h3>
  <p class="time">@@from – @@to</p>
  @@when(online)
    <span class="tag">Online</span>
  @@end-when
  @@unless(online)
    <span class="tag tag-venue">In person</span>
  @@end-unless
</li>
```

### See it live

```bash
kiln dev -o build site/
```

Kiln renders the pages into `build/`, opens them in your browser, and **re-renders on every save** with live-reload — edit a partial, watch every page that uses it update. This is the loop you'll spend most of your time in.

`program.html`'s loop compiles to plain HTML — no `@@` left behind:

```html
<ul class="sessions">
  <li class="session"><h3>Founder AMA</h3><p class="time">18:00 – 18:45</p><span class="tag">Online</span></li>
  <li class="session"><h3>Pitch Night</h3><p class="time">19:30 – 21:00</p><span class="tag tag-venue">In person</span></li>
  <li class="session"><h3>Investor Panel</h3><p class="time">17:00 – 18:00</p><span class="tag">Online</span></li>
</ul>
```

That's the whole idea: write a piece once, reuse it everywhere, feed it data.

---

## The directives

Everything above is built from six `@@` directives. All of them start with `@@`, are case-sensitive, and take **no space** before `(`.

### Include a partial — `@@include('path')`

Splices another file in place. Paths are relative to the file doing the including, in single or double quotes.

```html
@@include('components/nav.html')
```

### Pass data into an include — `@@include('path', {…})`

The object becomes the partial's variables. This is how one partial serves many pages:

```html
@@include('components/head.html', {title: 'Programme', year: 2026})
```

Inside `head.html`, `@@title` resolves to `Programme` and `@@year` to `2026`.

### Substitute a variable — `@@name`

A variable is `@@` + a lowercase name (letters, digits, interior hyphens — `@@page-title` is one name). It's filled from the data the partial was given, or from the current loop item.

```html
<title>@@title</title>
<body class="@@theme">
```

A variable with no value left to fill is reported as a warning when you build — so missing data never silently vanishes (add `--strict` to turn that warning into a failed build).

**Brace form — `@@{name}`** disambiguates where a name runs into literal text. Because hyphens are part of a name, `@@slug-thumb` reads as *one* variable; braces mark where the name ends:

```html
<img src="/img/@@{slug}-thumb.jpg">
<!-- slug = "founder-ama"  →  /img/founder-ama-thumb.jpg -->
```

### Show something conditionally — `@@when` / `@@unless`

Wrap content between the directive and its `@@end-…`. `@@when` keeps the block when the value is truthy; `@@unless` keeps it when falsy. (Falsy = `false`, `null`, `0`, `""`; everything else is truthy.) Condition names are letters/digits only — **no hyphens** here.

```html
@@when(online)
  <span class="tag">Online</span>
@@end-when

@@unless(soldout)
  <a href="/register">Register</a>
@@end-unless
```

They nest:

```html
@@when(featured)
  <article class="hero">
    @@unless(online)
      <p>In-person only</p>
    @@end-unless
  </article>
@@end-when
```

### Repeat a template — `@@loop('path', [ … ])`

Renders a partial once per object in an array (at least one object). Each object's keys become that iteration's variables. Keys are unquoted and strings single-quoted — the JavaScript-object style gulp-file-include uses; double-quoted JSON (`{"name": "Founder AMA"}`) works too.

```html
<ul>
  @@loop('components/session-card.html', [
    {name: 'Founder AMA', from: '18:00', to: '18:45', online: true},
    {name: 'Pitch Night', from: '19:30', to: '21:00', online: false}
  ])
</ul>
```

### Two kiln extras

HTML won't let you put `@@` in a tag name or a bare attribute, so kiln adds:

- **`<kiln-tag kiln-tag="@@name">…</kiln-tag>`** — a tag name chosen by a variable (renders as `<ul>`, `<section>`, …).
- **`<a kiln-attr-aria-current="@@current">`** — an attribute emitted only when its value is truthy (great for `checked`, `aria-current`, etc.).

---

## Everyday commands, by example

You met `kiln dev` above. The rest, as you'll actually use them:

```bash
# Build the site once into ./build (the pages, not the partials)
kiln render -o build site/

# About to share a draft? Confirm every include resolves and no partial
# is missing — writes nothing, just checks.
kiln preflight site/

# Serve a folder you already built, with live-reload
kiln serve -o build
```

Run **`kiln help`** (or just `kiln`) for the full list of commands and every flag.

---

## License

[MIT](https://spdx.org/licenses/MIT.html) (`MIT`). The full license text ships in the package's `LICENSE` file.
