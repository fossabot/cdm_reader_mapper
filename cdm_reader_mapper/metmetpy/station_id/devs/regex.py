#!/usr/bin/env python3
"""
Created on Thu Jul  4 07:40:38 2019

See https://docs.python.org/2/howto/regex.html

METACHARACTERS

meta = . ^ $ * + ? { } [ ] \\ | ( )

    - []: character class, including ranges. ie:
        1. [abc] : match a, b or c
        2. [a-c] : match a, b or c
        3. [a-z] : any lowercase letter
        Metacharacters inside classes are not active. i.e.:
        4. [akm$] :match 'a', 'k', 'm', or '$'
        Making the complementary by adding caret at the beginning.i.e:
        5. [^5] : any character except '5'
        6. [5^] : match '5' or ^

    - \\: to signal various special sequences and to escape metacharacters.
        Special sequences:
        1. \\d : any decimal digit -> class [0-9]
        2. \\D : any non-digit -> class [^0-9]
        3. \\s : any whitespace character -> class [ \t\n\r\f\v]
        4. \\S : any non-whitespace character -> class [^ \t\n\r\f\v]
        5. \\w : any alphanumeric character -> class [a-zA-Z0-9_]
        6. \\W : any non-alphanumeric character -> class [^a-zA-Z0-9_]
        Sequences can be included in classes:
        7. [\\s,.] : class that will match any whitespace character, ',' or '.'

    - .: matches anything except newline character (see re.DOTALL for newline)

    - *: previous character can be matched zero or more times. i.e.
        1. ca*t : matches ct (0 'a'), cat (1 'a'), caaat (3 'a'),....
        2. a[bcd]*b : matches 'a', zero or more letters from class [bcd] and 'b'

    - +: previous character can be matched one or more times. i.e.

    - ?: matches either once or zero times. i.e.
        1. home-?brew : either homebrew or home-brew

    - {m,n}: at least m repetitions, and at most n. i.e.
        1. a/{1,3}b: matches a/b, a//b, and a///b
        Omitting either: {,}
            m: 0
            n: infinity (2-billion limit)
        2. {0,} : same as *
        3. {1,} : same as +
        4. {0,1} : same as ?

    - |: or

    - ^: match at the beginning of lines

    - $: match at the end of the line

    - \\A: match at the start of the string (same as ^ if not MULTILINE mode)

    - \\Z: match at the end of the string

    - \b: word boundary

    - \\B: not a word boundary

COMPILING REGULAR EXPRESSIONS AND HOW TO PASS THEM TO THE COMPILER IN PYTHON

REs are compiled into pattern objects, which have methods for various operations
such as searching for pattern matches or performing string substitutions.

p = re.compile('ab*')

re.compile() accepts a flags argument, to enable special features and
syntax variations

To pass the RE string to the compiler, we need to keep in mind how python
strings litterals work.

Backslashes: to match a literal backslash, one has to write '\\\\' as the RE
string to compile, because the regular expression must be \\,
and each backslash must be expressed as \\ inside a regular Python
string literal

Solution: python raw string notation for regular expressions.i.e.
    1. r"\n" : two-character string containing '\' and 'n'
    2. "\n" : one-character string containing a newline
    3. r"ab*" : "ab*"
    4. r"\\section" : to match \\section, without r"" would need to pass to
    compiler as "\\\\section"
    5. r"\\w+\\s+\1" : without r"" would need to pass to
    compiler as "\\w+\\s+\\1"





@author: iregon
"""

# import re
# Let's try to match Liz's generics with RE
# upto4dig <- c('N','NN','NNN','NNNN')
# upto5dig <- c('N','NN','NNN','NNNN','NNNNN')
# upto6dig <- c('N','NN','NNN','NNNN','NNNNN','NNNNNN')
# upto7dig <- c('N','NN','NNN','NNNN','NNNNN','NNNNNN','NNNNNNN')
# form_name <- c('CCCC','CCCCC','CCCCCC','CCCCCCC','CCCCCCCC','CCCCCCCCC')
# form_call <- c('CCCC','CNCC','NCCC','CCNC','CCCN','CNCN','CNNC','NCNC','NCC','CCCCN','CNCCN','NCCCN')
# form_call_lc: same list but with lc characters. Depending on how this is used,
# we modifiy the REGEX below or create lowercase ones: create separated, not always allowed
# form call 3 characters:
#   - 1 number: NCC: \d[A-Z][A-Z]
# form call 4 characters:
#   - No number: CCCC
#   - 1 number: NCCC, CNCC, CCNC, CCCN
#   - 2 numers: CNCN, CNNC, NCNC: [A-Z]\d[A-Z]\d,[A-Z]\d\d[A-Z],\d[A-Z]\d[A-Z]
# form call 5 characters:
#   - 1 number: CCCCN: [A-Z]{4,4}\d
#   - 2 numbers: CNCCN, NCCCN: [A-Z]\d[A-Z][A-Z]\d,\d[A-Z][A-Z][A-Z]\d
form_generic = [
    "SHIP",
    "BUOY",
    "PLAT",
    "RIGG",
    "ship",
    "MASKSTID",
    "buoy",
    "BBXX_SHIP",
    "BBXX-SHIP",
    "AAAA",
    "XXXX",
    "TEST",
]
ship_names = [
    "AVERY",
    "ALEXAN",
    "WILLIA",
    "GULF G",
    "SIR JA",
    "AGAWAC",
    "ARCTIC",
    "GORDON",
    "LOUISR",
    "HILDA",
    "R BRUC",
    "STADAC",
    "STANLE",
    "BLACK",
    "WHEATK",
    "FRANK",
    "ENGLIS",
    "YANKCA",
    "GRIFFO",
    "ALGOCE",
    "JEAN P",
    "TADOUS",
    "ALGORA",
    "KENOKI",
    "SPUME",
    "REDWIN",
    "JUDITH",
    "VEREND",
    "WOLVER",
    "SILVER",
    "SAGUEN",
    "SPINDR",
    "RICHEL",
    "ALGOWA",
    "TARANT",
    "AGAWA",
    "FRONTE",
    "JAMES",
    "QUEBEC",
    "HOWARD",
    "LOUIS",
    "MONTRE",
    "NORTHE",
    "SPRAY",
    "ALGOLA",
    "ALGOSO",
    "CAROL",
    "MANITO",
    "QUETIC",
    "SIMCOE",
    "LIMNOS",
    "CANADI",
    "BAYFIE",
    "RAPID",
    "NANTUC",
]

id_regex = dict()
id_regex["upto4dig"] = r"^\d{1,4}$"
id_regex["upto5dig"] = r"^\d{1,5}$"
id_regex["upto6dig"] = r"^\d{1,6}$"
id_regex["upto7dig"] = r"^\d{1,7}$"
id_regex["form_name"] = "^[A-Z]{4,9}$"
id_regex["form_call"] = [
    r"^\d[A-Z][A-Z]$",
    r"^(?=.*\d?)(?=.*[A-A])[0-9A-Z]{4,4}$",
    r"^[A-Z]\d[A-Z]\d",
    r"^[A-Z]\d\d[A-Z]$",
    r"^\d[A-Z]\d[A-Z]$",
    r"^[A-Z]{4,4}\d$",
    r"^[A-Z]\d[A-Z][A-Z]\d$",
    r"^\d[A-Z][A-Z][A-Z]\d$",
]
id_regex["form_call_lc"] = [
    r"^\d[a-z][a-z]$",
    r"^(?=.*\d?)(?=.*[A-A])[0-9a-z]{4,4}$",
    r"^[a-z]\d[a-z]\d",
    r"^[a-z]\d\d[a-z]$",
    r"^\d[a-z]\d[a-z]$",
    r"^[a-z]{4,4}\d$",
    r"^[a-z]\d[a-z][a-z]\d$",
    r"^\d[a-z][a-z][a-z]\d$",
]
form_generic = ["^" + x + "$" for x in form_generic]
id_regex["form_generic"] = form_generic
id_regex["form_cman"] = r"^[A-Z]{4,4}\d$"
ship_names = ["^" + x + "$" for x in ship_names]
id_regex["ship_names"] = ship_names


# regexes = [ [v] if not isinstance(v,list) else v for k,v in generic_regexs.items() ]
# regexes = [val for sublist in regexes for val in sublist]
#
# combined_compiled = re.compile('|'.join(regexes))
