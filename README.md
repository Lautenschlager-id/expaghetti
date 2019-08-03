<p align="center"><img src="https://i.imgur.com/Pc4Rzwe.png" height="300" /></p>

**The library `expaghetti` is under heavy development.**

It aims towards allowing Lua developers to use Regular Expressions without the need of bothering in using thousands of matches with patterns or even lpeg.<br>
It currently works on any 5.x version.

Please read [SYNTAX](SYNTAX.md) to learn more about the syntax used in expaghetti. 

---

## Done
- [x] Create UTF8 structure
- [x] Create Set `[abc]`
- [x] Create Negated Set `[^abc]`
- [x] Create Range `[a-z]`
- [x] Allow mixing Set and Range `[a-z0-9@_!]`
- [x] Syntax documentation
- [x] Create Group `(abc)`
- [x] Create Non-capturing group `(?:abc)`
- [x] Create Positive lookahead group `(?=abc)`
- [x] Create Negative lookahead group `(?!abc)`
- [x] Create the special character class `%cX`
- [x] Create Queue (pattern root to create the sequence tree)
- [x] Create the special character class `.`
- [x] Logical improvements
- [x] Create Positive lookbehind group `(?<=abc)`
- [x] Create Negative lookbehind group `(?<!abc)`
