<p align="center"><img src="https://i.imgur.com/Pc4Rzwe.png" height="300" /></p>

**The library `expaghetti` is under heavy development.**

It aims towards allowing Lua developers to use (bizarre) Regular Expressions without the need of bothering in using thousands of matches with patterns or even lpeg.

It currently works on any Lua 5.x version, and is intended to be released with this support.

Please read [SYNTAX](SYNTAX.md) to learn more about the syntax used in expaghetti.

And last, but not less important,
<p align="center"><i>"Premature optimization is the root of all evil."</i></p>
<p align="right">- Donald Knuth</p>

---

## Done
- [x] Create UTF8 structure
- [x] Create Set `[abc]`
- [x] Create Negated Set `[^abc]`
- [x] Create Range `[a-z]`
- [x] Allow mixing Set and Range `[a-z0-9@_!]`
- [x] Create character class
- [x] Syntax documentation
- [x] Create Group `(abc)`
- [x] Create Non-capturing group `(?:abc)`
- [x] Create Positive lookahead group `(?=abc)`
- [x] Create Negative lookahead group `(?!abc)`
- [x] Create the special character class `%cX`
- [x] Create Queue (pattern root to create the sequence tree)
- [x] Create the special character class `.`
- [x] Create Positive lookbehind group `(?<=abc)`
- [x] Create Negative lookbehind group `(?<!abc)`
- [x] Create Quantifier `{x,y}`
- [x] Create 1,N operator `a+`
- [x] Create 0,N operator `a*`
- [x] Create 0,1 operator `a?`
- [x] Create lazy operator `a+?`
- [x] Create %h's alias `%x`
- [x] Create the codepoint character class `%eFFFF`
- [x] Create the punctuation character class `%p`
- [x] Create boundaries `^` and `$`
- [x] Create or operator `|`
- [x] Make or operator OOP
- [x] Allow empty string in or structure (empty table)
- [ ] Create `%b` (not %W)
- [ ] Create `%B` (missing !)
- [x] Create position capture `()`
- [x] Create capture reference `%1`
- [x] Make operators become quantifiers
- [x] Rename OR to ALTERNATE