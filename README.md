# Nokolexbor

A high performance HTML5 parser for Ruby based on [Lexbor](https://github.com/lexbor/lexbor/), with support for both CSS selectors and XPath. It's API is designed to be compatible with [Nokogiri](https://github.com/sparklemotion/nokogiri).

## Installation

Nokolexbor contains C extensions and requires `cmake` to compile the source, check it before installing the gem.

```
gem install nokolexbor
```

## Quick start

```ruby
require 'nokolexbor'

html = <<-HTML
<html>
  <body>
    <ul class='menu'>
      <li><a href='http://example1.com'>Example 1</a></li>
      <li><a href='http://example2.com'>Example 2</a></li>
      <li><a href='http://example3.com'>Example 3</a></li>
    </ul>
    <div>
      <article>
        <h1>Title</h1>
        Text content 1
        <h2>Sub title</h2>
        Text content 2
      </article>
    </div>
  </body>
</html>
HTML

# Parse HTML document
doc = Nokolexbor::HTML(html)

# Search for nodes by css
doc.css('ul.menu li a', 'article h2').each do |link|
  puts link.content
end

# Search for text nodes by css
doc.css('article > ::text').each do |text|
  puts text.content
end

# Search for nodes by xpath
doc.xpath('//ul//li/a', '//article//h2').each do |link|
  puts link.content
end
```


## Features
* A subset of Nokogiri compatible API.
* High performance HTML parsing, DOM manipulation and CSS selectors engine.
* XPath search engine (the algorithm is ported from libxml2).
* Selecting text nodes with CSS selectors using `::text`.

## Limitations
* Mixed expression of CSS selectors and XPath is not supported in Nokolexbor. Selectors like `div > a[last()]` won't work, use `div > a:last-of-type` instead.

## Different behaviors from Nokogiri
* For selector `:nth-of-type(n)`, `n` is not affected by prior filter. For example, if we want to select the 3rd `div` excluding class `a` and class `b`, which will be the last `div` in the following HTML:
  ```
  <body>
    <div></div>
    <div class="a"></div>
    <div class="b"></div>
    <div></div>
    <div></div>
  </body>
  ```
  In Nokogiri, the selector should be `div:not(.a):not(.b):nth-of-type(3)`

  In Nokolexbor, `:not` does affect the place of the last `div` (same in browsers), the selector should be `div:not(.a):not(.b):nth-of-type(5)`, but this losts the purpose of filtering though.

## Benchmarks

Benchmark parsing google result page (368 KB) and selecting nodes using CSS and XPath. Run on MacBook Pro (2019) 2.3 GHz 8-Core Intel Core i9.

Run with: `ruby bench/bench.rb`

|            | Nokolexbor (iters/s) | Nokogiri (iters/s) | Diff |
| ---------- | ------------- | ----------- | -------------- |
| parsing    | 487.6         | 93.5        | 5.22x faster   |
| at_css     | 50798.8       | 50.9        | 997.87x faster |
| css        | 7437.6        | 52.3        | 142.11x faster |
| at_xpath   | 57.077        | 53.176      | same-ish       |
| xpath      | 51.523        | 58.438      | same-ish       |

<details>
<summary>Raw data</summary>

```
Warming up --------------------------------------
    Nokolexbor parse    56.000  i/100ms
      Nokogiri parse     8.000  i/100ms
Calculating -------------------------------------
    Nokolexbor parse    487.564  (±10.9%) i/s -      9.688k in  20.117173s
      Nokogiri parse     93.470  (±21.4%) i/s -      1.736k in  20.024163s

Comparison:
    Nokolexbor parse:      487.6 i/s
      Nokogiri parse:       93.5 i/s - 5.22x  (± 0.00) slower

Warming up --------------------------------------
   Nokolexbor at_css     5.548k i/100ms
     Nokogiri at_css     6.000  i/100ms
Calculating -------------------------------------
   Nokolexbor at_css     50.799k (±13.8%) i/s -    987.544k in  20.018481s
     Nokogiri at_css     50.907  (±35.4%) i/s -    828.000  in  20.666258s

Comparison:
   Nokolexbor at_css:    50798.8 i/s
     Nokogiri at_css:       50.9 i/s - 997.87x  (± 0.00) slower

Warming up --------------------------------------
      Nokolexbor css   709.000  i/100ms
        Nokogiri css     4.000  i/100ms
Calculating -------------------------------------
      Nokolexbor css      7.438k (±14.7%) i/s -    145.345k in  20.083833s
        Nokogiri css     52.338  (±36.3%) i/s -    816.000  in  20.042053s

Comparison:
      Nokolexbor css:     7437.6 i/s
        Nokogiri css:       52.3 i/s - 142.11x  (± 0.00) slower

Warming up --------------------------------------
 Nokolexbor at_xpath     2.000  i/100ms
   Nokogiri at_xpath     4.000  i/100ms
Calculating -------------------------------------
 Nokolexbor at_xpath     57.077  (±31.5%) i/s -    920.000  in  20.156393s
   Nokogiri at_xpath     53.176  (±35.7%) i/s -    876.000  in  20.036717s

Comparison:
 Nokolexbor at_xpath:       57.1 i/s
   Nokogiri at_xpath:       53.2 i/s - same-ish: difference falls within error

Warming up --------------------------------------
    Nokolexbor xpath     3.000  i/100ms
      Nokogiri xpath     3.000  i/100ms
Calculating -------------------------------------
    Nokolexbor xpath     51.523  (±31.1%) i/s -    903.000  in  20.102568s
      Nokogiri xpath     58.438  (±35.9%) i/s -    852.000  in  20.001408s

Comparison:
      Nokogiri xpath:       58.4 i/s
    Nokolexbor xpath:       51.5 i/s - same-ish: difference falls within error
```
</details>