![/!\\](https://i.imgur.com/HQ188PK.png) **The examples used in this documentation are not working yet, because the library is still under development.**

# Summary
- [Sets <sub>\[abc\]</sub>](#sets)
	- [Ranges <sub>\[^abc\]</sub>](#ranges)
- [Character classes <sub>%a</sub>](#character-classes)
- [Groups <sub>\(abc\)</sub>](#groups)
- [Quantifiers <sub>{1,2}</sub>](#quantifiers)

---

## Sets
Sets delimit a range of unique characters for the regular expression.

- **\[abc\]** → Normal set will check whether the character is `a`, `b` or `c`.
- **\[^abc\]** → Negated set will check whether the character is NOT `a`, `b` and `c`.

### Ranges
Ranges delimit a wider set of unique characters based on their bytes and can only be used inside sets.

- **\[0-9\]** → Normal range will check whether the character is `0`, `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8` or `9`, or more precisely, if its byte is within the values `48` and `57`.
- **\[abc0-9\]** → Range can be mixed with normal set, performing a check to determine whether the character is `a`, `b`, `c`, or if its byte is withing `48` and `57`.

## Character classes
Character classes delimit specific sets without the need of typing them directly.<br>
By using an upper case class, the expected behavior will be exactly the opposite of the real effect, reading `%A` as `anything but %a`.

| Class    | Effect                                                                                                                                                        |
| :-:      | -                                                                                                                                                             |  
| %a       | Matches insensitive case letters, equivalent to `[a-zA-Z]`.                                                                                                   |
| %c`X`    | Matches an escaped control character, and the parameter `X` needs to be a letter within `A` and `Z`. <sub>assuming `A`=`\001` and `Z`=`\026`</sub>            |
| %d       | Matches integer numbers, equivalent to `[0-9]`.                                                                                                               |
| %e`FFFF` | Matches an unicode character, and the parameter `FFFF` needs to be (a codepoint) exactly four valid hexadecimal characters. <sub>equivalent of `\uFFFF`</sub> |
| %h or %x | Matches an hexadecial number, equivalent to `[0-9a-fA-F]`.                                                                                                    |
| %l       | Matches lower case letters, equivalent to `[a-z]`.                                                                                                            |
| %s       | Matches any whitespace character, equivalent to `[\f\n\r\t ]`.                                                                                                |
| %u       | Matches upper case letters, equivalent to `[A-Z]`.                                                                                                            |
| %w       | Matches any alphanumeric character, equivalent to `[a-zA-Z0-9_]` or `[%a%d_]`.                                                                                |

## Groups
Groups combine a sequence of expressions to be manipulated together.<br>
They also work like captures, which are returned as data extraction.

- **\(abc\)** → Normal group will agroup `a`, `b` and `c` and return it as a single value.
- **\(?:abc\)** → Non-capturing group will agroup `a`, `b` and `c` but won't return it.

## Quantifiers
Quantifiers will match consecutive expressions in a specified quantity.

- **{2,}** → Matches two or more occurrences of the expression.
- **{,2}** → Matches a maximum of two occurrences of the expression.
- **{2}** → Matches exactly two occurrences of the expression.
- **{1,2}** → Matches one or two occurrences of the expression.

---

# TODO

##### Magic characters
~~^, +, -, \*, \[, \], \(, \), \{, \}, ?, ., %, \|, $~~
##### Character classes
`[\s\S]`, `\b`, `\B`, ~~`%u{FFFF}`~~
##### Groups
###### Position
###### Numeric reference
###### Positive lookahead
###### Negative lookahead
###### Positive lookbehind
###### Negative lookbehind
##### Flags
`i`, `g`, `m`, `u`, `y`