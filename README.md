<p align="center"><img src="https://i.imgur.com/Pc4Rzwe.png" height="300" /></p>

The library `expaghetti` is under heavy development.

It aims towards allowing Lua developers to use Regular Expressions without the need of bothering in using thousands of matches with patterns or even lpeg.<br>
It currently works on Lua 5.2 and 5.3, a bitwise wrapper might be needed for 5.1 support.

---

## Done
- [x] Create UTF8 structure
- [x] Create Set `[abc]`
- [x] Create Negated Set `[^abc]`
- [x] Create Range `[a-z]`
- [x] Allow mixing Set and Range `[a-z0-9@_!]`

---

Match
`[abc]`
`[^abc]`
`[a-z]`
`.`
`[\s\S]`
`\identifier`
`\IDENTIFIER`
`^`
`$`
`\special`
`\000`
`\xFF`
`\uFFFF`
`\u{FFFF}`
`\cZ`
`\t`
`\n`
`\v`
`\r`
`\f`
`\0`
`(abc)`
`\1`
`(?:abc)`
`(?=abc)`
`(?!abc)`
`+`
`*`
`{1,3}`
`{3}`
`{3,}`
`?`
`special?`
`|`
Substitution
`$&`
`$1`
`$\``
`$'`
`$$`
`\n`
Flags
`i`
`g`
`m`
`u`
`y`