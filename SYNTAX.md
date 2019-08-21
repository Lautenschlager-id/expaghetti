![/!\\](https://i.imgur.com/HQ188PK.png) **The examples used in this documentation are not working yet, because the library is still under development.**

# Summary
- [Magic characters <sub>\(\)\[\]\{\}</sub>](#magic-characters)
- [Sets <sub>\[abc\]</sub>](#sets)
	- [Ranges <sub>\[^abc\]</sub>](#ranges)
- [Character classes <sub>%a</sub>](#character-classes)
- [Groups <sub>\(abc\)</sub>](#groups)
- [Quantifiers <sub>{1,2}</sub>](#quantifiers)
	- [Lazy <sub>x+?</sub>](#lazy)
- [Alternators <sub>a|b|c</sub>](#alternators)
- [Tree](#tree)


---
## Magic characters
Magic characters have a special behavior unless specified that they need to be literal characters.

| Character | Effect                                                                                                                                |
| :-:       | -                                                                                                                                     |
| ^         | Matches the beginning of the string. If set after a `[`, its behavior is changed and negates an entire [set](#sets).                  |
| $         | Matches the end of the string.                                                                                                        |
| [         | Opens a [set](#sets).                                                                                                                 |
| ]         | Closes a [set](#sets).                                                                                                                |
| -         | Delimits a [range](#ranges) and only is special inside [sets](#sets).                                                                 |
| (         | Opens a [group](#groups).                                                                                                             |
| )         | Closes a [group](#groups).                                                                                                            |
| .         | Represents any character but break lines.                                                                                             |
| %         | Escapes magic characters to behave as literal characters or triggers [classes](#character-classes).                                   |
| {         | Opens a [quantifier](#quantifiers).                                                                                                   |
| }         | Closes a [quantifier](#quantifiers).                                                                                                  |
| ,         | Splits the arguments of a [quantifier](#quantifiers) and only is special inside [quantifiers](#quantifiers).                          |
| *         | Matches zero or more occurrences of the preceding expression.                                                                         |
| +         | Matches one or more occurrences of the preceding expression.                                                                          |
| ?         | Matches zero or one occurrences of the preceding expression. If set after `*`, `+`, or `?` its behavior is switched to [lazy](#lazy). |
| \|        | Splits/transforms the whole expression into [alternatives](#alternators), where only one needs to match.                              |

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
| %b       | Matches a boundary between an alphanumeric character and a non-alphanumeric character.                                                                        | 
| %c`X`    | Matches an escaped control character, and the parameter `X` needs to be a letter within `A` and `Z`. <sub>assuming `A`=`\001` and `Z`=`\026`</sub>            |
| %d       | Matches integer numbers, equivalent to `[0-9]`.                                                                                                               |
| %e`FFFF` | Matches an unicode character, and the parameter `FFFF` needs to be (a codepoint) exactly four valid hexadecimal characters. <sub>equivalent of `\uFFFF`</sub> |
| %h or %x | Matches an hexadecial number, equivalent to `[0-9a-fA-F]`.                                                                                                    |
| %l       | Matches lower case letters, equivalent to `[a-z]`.                                                                                                            |
| %s       | Matches any whitespace character, equivalent to `[\f\n\r\t ]`.                                                                                                |
| %u       | Matches upper case letters, equivalent to `[A-Z]`.                                                                                                            |
| %w       | Matches any alphanumeric character, equivalent to `[a-zA-Z0-9_]` or `[%a%d_]`.                                                                                |
| %%       | Represents the literal character '%'.                                                                                                                         |
| %magic   | Represents the [magic character](#magic-characters) as literal.                                                                                               |

## Groups
Groups combine a sequence of expressions to be manipulated together.<br>
They also work like captures, which are returned as data extraction.

- **\(abc\)** → Normal group will agroup `a`, `b` and `c` and return it as a single value.
- **\(?:abc\)** → Non-capturing group will agroup `a`, `b` and `c` but won't return it.
- **\(\)** → Position capture group will return the position of the string where it matches.
- **%n** → Capture group by reference will match exactly what the Nth group has matched. <sub>0 <= n <= 9</sub>

## Quantifiers
Quantifiers will match consecutive expressions in a specified quantity.

- **{2,}** → Matches two or more occurrences of the expression.
- **{,2}** → Matches a maximum of two occurrences of the expression.
- **{2}** → Matches exactly two occurrences of the expression.
- **{1,2}** → Matches one or two occurrences of the expression.
- **\*** → Matches zero or more occurences of the expression. <sub>{0,}</sub>
- **+** → Matches one or more occurences of the expression. <sub>{1,}</sub>
- **?** → Matches zero or one occurences of the expression. <sub>{0,1}</sub>

### Lazy
The lazy operator `?` changes the behavior of the operators `*` <sub>\*?</sub>, `+` <sub>+?</sub>, and `?` <sub>??</sub> which essentially behave to match _as many as possible_ occurences of an expression, to match _as few as possible_ occurrences of an expression.

- **<.+>** @ `<testing> this out>` → Matches `<testing> this out>`.
- **<.+?>** @ `<testing> this out>` → Matches `<testing>`.

## Alternators
Alternators will match one of the alternatives set in the expression. Works like a boolean OR operator.<br>
Use them inside groups to limit their ranges. They will transform the whole expression into alternatives, it's not char-by-char.

- **(a|b|c)** → Matches `a`, `b`, or `c`.
- **hi|b|c** → Matches `hi`, `b`, or `c`.
- **h(i|ey|)** → Matches `hi`, `hey`, and `h`

---
# Tree
The regex is built as a tree in the following format:

```Lua
{ -- Tree
	{ -- Anchor
		type = "anchor", -- Anchor's object name
		anchor = '' -- The anchor character: ^, $, %b or %B
	},
	{ -- Set
		type = "set", -- Set's object name
		_hasValue = false, -- Whether the set is still empty
		_negated = false, -- Whether it's a negated set
		_rangeIndex = 1, -- The number of ranges in the set
		_min = { -- The list of minimum values of the ranges
			[1] = '', -- Minimum value of the first range
		},
		_max = { -- The list of maximum values of the ranges
			[1] = '', -- Maximum value of the first range
		},
		_setIndex = 1, -- The number of sets (character classes) in the set
		_sets = { -- The list of sets (character classes)
			[1] = ... -- The set that represents the first character class
		},
		[c] = true -- Literal character as index
	},
	{ -- Group
		type = "group", -- Group's object name
		_behind = false, -- Whether the ground is a lookbehind
		_effect = "", -- The group effect, if there's any: ':' (non-capturing), '=' (positive lookahead), '!' (negative lookahead)
		_index = 2, -- The number of characters in the group expression
		[1] = '', -- Literal character of the expression
		[2] = { ... }, -- An object, like sets or quantifiers.
	},
	{ -- Quantifier
		type = "quantifier", -- Quantifier's object name
		_index = 1, -- The current index of the quantifer: 1 or 2
		isLazy = false, -- Whether the quantifier is lazy or greedy
		[1] = nil, -- The minimum value of the quantifier, if set
		[2] = nil -- The maximum value of the quantifier, if set
	},
	{ -- Alternate
		type = "alternate", -- Alternate's object name
		exp = { -- A list of alternative expressions, trees
			[1] = { ... }, -- Expression 1
			[2] = { ... } -- Expression 2
		}
	},
	{ -- Position capture
		type = "position_capture", -- Position Capture's object name
	},
	{ -- Capture group by reference
		type = "capture_reference", -- Capture Group's object name
		value = 0 -- The number of the referenced group: from 0 to 9
	},
	[1] = '' -- Literal character
}
```

---
# TODO

##### Character classes
`[\s\S]`
##### Groups
###### Positive lookahead
###### Negative lookahead
###### Positive lookbehind
###### Negative lookbehind
##### Flags
`i`, `g`, `m`, `u`, `y`