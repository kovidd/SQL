-- STRING FUNCTIONS --
SELECT POSITION('SQL' IN 'PostgreSQL'); -- Gives starting pos of the string
SELECT POSITION('o' IN LOWER('KOVID'));

SELECT STRPOS('PostgreSQL', 'SQL') AS substring_pos;

SELECT STRPOS('PostgreSQL', 'SQL') AS substring_pos,
	   STRPOS('Kovid', 'id') AS substring_pos,
	   STRPOS('Sydney', 'd') AS substring_pos,
	   STRPOS('Aussie', 'h') AS substring_pos;

SELECT REPLACE('Kovid', 'Kovid', UPPER('Kovid'));

-- Find pos of space in passenger name
SELECT passenger_name, STRPOS(passenger_name, ' ') AS space_pos
FROM tickets
LIMIT 5;

-- Replace space in passenger name with hyphen
SELECT passenger_name, REPLACE(passenger_name, ' ', '-')
FROM tickets
LIMIT 5;

--------------------------------------------------------------

-- LEFT RIGHT
SELECT LEFT('Kovid', 2); -- Ko
SELECT LEFT('Kovid', -2); -- Kov

SELECT RIGHT('Kovid', 2); -- id
SELECT RIGHT('Kovid', -2); -- vid

SELECT LEFT('Kovid', 2), BTRIM(SPLIT_PART('Kovid', 'v', 1)); -- Ko Ko
SELECT LEFT('Kovid', 2), BTRIM(SPLIT_PART('Kovid', 'v', 2)); -- Ko id

SELECT LEFT('Kovid', 2), BTRIM(SPLIT_PART('Kovid', 'v', 1)); -- Ko Ko

SELECT BTRIM('PppPostgresqllllLlL', 'pl'); -- PppPostgresqllllLlL
SELECT BTRIM('PppPostgresqllllLlL', 'PLpl'); -- ostgresq

SELECT CONCAT('Ko'||'v'||'id');
SELECT CONCAT('Postgre'||' '||'SQL');

SELECT INITCAP('kovid');
SELECT INITCAP('KOVID');

-- Questions --
-- 1. Suppose our airline marketers want to know how often 
--    there are different names among the passengers?
SELECT LEFT(passenger_name, STRPOS(passenger_name, ' ') - 1) AS firstname, COUNT (*)
FROM tickets
GROUP BY 1
ORDER BY 2 DESC;

-- 2. Which combinations of first names and last names separately
--    occur most often? What is the ratio of the passengers with 
--    such names to the total number of passengers?
SELECT LEFT(passenger_name, STRPOS(passenger_name, ' ') - 1) AS firstname,
	   LEFT(passenger_name, STRPOS(passenger_name, ' ') - 1) AS lastname
FROM tickets
GROUP BY 1, 2
ORDER BY 1;

WITH p AS (SELECT left(passenger_name, position(' ' IN passenger_name)) AS passenger_name FROM tickets)
SELECT passenger_name, round( 100.0 * cnt / sum(cnt) OVER (), 2) AS percent
FROM (SELECT passenger_name,count(*) cnt FROM p GROUP BY passenger_name) t
ORDER BY percent DESC;


----------------------------------------------------------

-- rpad ( string text, length integer [, fill text ] ) → text
-- Extends the string to length length by appending the characters fill (a space by default). If the string is already longer than length then it is truncated.
-- rpad('hi', 5, 'xy') → hixyx

SELECT RPAD('hi', 5, 'xy'); --→ hixyx
SELECT RPAD('hi', 9, 'xy'); --→ hixyxyxyx

----------------------------------------------------------

-- text || text → text
-- Concatenates the two strings.
-- 'Post' || 'greSQL' → PostgreSQL
SELECT 'Abc' || 'deF'; -- AbcdeF

-- text || anynonarray → text
-- anynonarray || text → text
-- Converts the non-string input to text, then concatenates the two strings. 
-- (The non-string input cannot be of an array type, because that would create 
-- ambiguity with the array || operators. If you want to concatenate an array's 
-- text equivalent, cast it to text explicitly.)
-- 'Value: ' || 42 → Value: 42
SELECT 'Abc' || 123; -- Abc123

-- text IS [NOT] [form] NORMALIZED → boolean
-- Checks whether the string is in the specified Unicode normalization form. 
-- The optional form key word specifies the form: NFC (the default), NFD, NFKC, or NFKD. 
-- This expression can only be used when the server encoding is UTF8. Note that 
-- checking for normalization using this expression is often faster than normalizing 
-- possibly already normalized strings.

-- U&'\0061\0308bc' IS NFD NORMALIZED → t
SELECT 'abc' IS NFD NORMALIZED; -- true

-- bit_length ( text ) → integer
-- Returns number of bits in the string (8 times the octet_length).
-- bit_length('jose') → 32
SELECT BIT_LENGTH('k'); -- 8
SELECT BIT_LENGTH('ab'); -- 16
SELECT BIT_LENGTH('abcd'); -- 24

-- char_length ( text ) → integer
-- character_length ( text ) → integer
-- Returns number of characters in the string.
-- char_length('josé') → 4
SELECT CHAR_LENGTH('abcd123'); -- 7

-- lower ( text ) → text
-- Converts the string to all lower case, according to the rules of the database's locale.
-- lower('TOM') → tom
SELECT LOWER('AbC'); -- abc

-- normalize ( text [, form ] ) → text
-- Converts the string to the specified Unicode normalization form. 
-- The optional form key word specifies the form: NFC (the default), NFD, NFKC, or NFKD. 
-- This function can only be used when the server encoding is UTF8.

-- normalize(U&'\0061\0308bc', NFC) → U&'\00E4bc'
SELECT NORMALIZE(U&'\0061\0308bc', NFC); -- äbc
SELECT NORMALIZE(U&'\0061\0300bc', NFC); -- àbc

-- octet_length ( text ) → integer
-- Returns number of bytes in the string.
-- octet_length('josé') → 5 (if server encoding is UTF8)
SELECT OCTET_LENGTH('Jose'); -- 4
SELECT OCTET_LENGTH('Joseph'); -- 6

-- octet_length ( character ) → integer
-- Returns number of bytes in the string. Since this version of the function 
-- accepts type character directly, it will not strip trailing spaces.
-- octet_length('abc '::character(4)) → 4
SELECT OCTET_LENGTH('Joseph'::character(4)); -- 4
 
-- overlay ( string text PLACING newsubstring text FROM start integer [ FOR count integer ] ) → text
-- Replaces the substring of string that starts at the start'th character and extends for count characters 
-- with newsubstring. If count is omitted, it defaults to the length of newsubstring.
-- overlay('Txxxxas' placing 'hom' from 2 for 4) → Thomas
SELECT OVERLAY('PXXXGGGSSL' PLACING 'ostgreSQ' FROM 2 FOR 8); -- PostgreSQL
SELECT OVERLAY('PXXXGGGSSL' PLACING 'ostgreSQ' FROM 2 FOR 5); -- PostgreSQGSSL

-- position ( substring text IN string text ) → integer
-- Returns starting index of specified substring within string, or zero if it's not present.
-- position('om' in 'Thomas') → 3
SELECT POSITION('gre' IN 'PostgreSQL'); --5

-- substring ( string text [ FROM start integer ] [ FOR count integer ] ) → text
-- Extracts the substring of string starting at the start'th character if that is specified, 
-- and stopping after count characters if that is specified. Provide at least one of start and count.
-- substring('Thomas' from 2 for 3) → hom
SELECT SUBSTRING('PostgreSQL' FROM 5 FOR 3); -- gre

-- substring('Thomas' from 3) → omas
SELECT SUBSTRING('PostgreSQL' FROM 5); -- greSQL

-- substring('Thomas' for 2) → Th
SELECT SUBSTRING('PostgreSQL' FOR 4); -- Post

-- substring ( string text FROM pattern text ) → text
-- Extracts substring matching POSIX regular expression;
-- substring('Thomas' from '...$') → mas
SELECT SUBSTRING('PostgreSQL' FROM '...$'); -- SQL (REGEX $ matches end, . matches any char except line breaks)

SELECT REGEXP_SPLIT_TO_ARRAY('PostgreSQL', '[(?:gre)]') AS arr; -- Post,,,SQL
SELECT REGEXP_SPLIT_TO_ARRAY('PostgreSQL', '[^(?:gre)]') AS arr; -- ,,,,gre,,,
SELECT REGEXP_SPLIT_TO_ARRAY('This is a whitespace sentence', E'\\s+') AS arr;

SELECT REGEXP_SPLIT_TO_TABLE('fname lname', '\s+') AS split_Table; 
SELECT REGEXP_SPLIT_TO_TABLE('3,2,1,6,5,4,7,9,8', ',') AS number ORDER BY 1; 

-- substring ( string text FROM pattern text FOR escape text ) → text
-- Extracts substring matching SQL regular expression; see Section 9.7.2.
-- substring('Thomas' from '%#"o_a#"_' for '#') → oma
SELECT SUBSTRING('Thomas' from '%#"o_a#"_' for '#'); -- oma
SELECT SUBSTRING('PostgreSQL' from '%#"g__#"___' for '#'); -- gre


-- trim ( [ LEADING | TRAILING | BOTH ] [ characters text ] FROM string text ) → text
-- Removes the longest string containing only characters in characters (a space by default) 
-- from the start, end, or both ends (BOTH is the default) of string.
-- trim(both 'xyz' from 'yxTomxx') → Tom
SELECT TRIM(BOTH 'pl' FROM 'PppPostgresqllllLlL'); -- PppPostgresqllllLlL
SELECT TRIM(BOTH 'PLpl' FROM 'PppPostgresqllllLlL'); -- ostgresq

-- trim ( [ LEADING | TRAILING | BOTH ] [ FROM ] string text [, characters text ] ) → text
-- This is a non-standard syntax for trim().
-- trim(both from 'yxTomxx', 'xyz') → Tom
SELECT TRIM(BOTH 'pl' FROM 'ppPostgresqllllLl'); -- PostgresqllllL
SELECT TRIM(BOTH 'PLpl' FROM 'PppPostgresqllllLlL'); -- ostgresq

-- upper ( text ) → text
-- Converts the string to all upper case, according to the rules of the database's locale.
-- upper('tom') → TOM
SELECT UPPER('aBcDeF');

----------------------------------------------------------

-- ascii ( text ) → integer
-- Returns the numeric code of the first character of the argument. In UTF8 encoding,
-- returns the Unicode code point of the character. In other multibyte encodings, the argument must be an ASCII character.
-- ascii('x') → 120
SELECT ASCII('K'); -- 75

-- btrim ( string text [, characters text ] ) → text
-- Removes the longest string containing only characters in characters (a space by default) from the start and end of string.
-- btrim('xyxtrimyyx', 'xyz') → trim
SELECT BTRIM('abcABCPostgresSQLabcABC', 'AaBbCc');

-- chr ( integer ) → text
-- Returns the character with the given code. In UTF8 encoding the argument is treated as a Unicode code point.
-- In other multibyte encodings the argument must designate an ASCII character. 
-- chr(0) is disallowed because text data types cannot store that character.
-- chr(65) → A
SELECT CHR(123); -- {
SELECT CHR(121); -- y

-- concat ( val1 "any" [, val2 "any" [, ...] ] ) → text
-- Concatenates the text representations of all the arguments. NULL arguments are ignored.
-- concat('abcde', 2, NULL, 22) → abcde222
SELECT CONCAT('abc', '2', NULL, '3', NULL, 'def'); -- abc23def
 
-- concat_ws ( sep text, val1 "any" [, val2 "any" [, ...] ] ) → text
-- Concatenates all but the first argument, with separators. The first argument is used as
-- the separator string, and should not be NULL. Other NULL arguments are ignored.
-- concat_ws(',', 'abcde', 2, NULL, 22) → abcde,2,22
SELECT CONCAT_WS('_', 'abc', '2', NULL, '3', NULL, 'def'); -- abc_2_3_def

-- format ( formatstr text [, formatarg "any" [, ...] ] ) → text
-- Formats arguments according to a format string; see Section 9.4.1. This function is similar to the C function sprintf.
-- format('Hello %s, %1$s', 'World') → Hello World, World
SELECT FORMAT('Hey %2$s, %s', 'hru', 'there');

-- initcap ( text ) → text
-- Converts the first letter of each word to upper case and the rest to lower case.
-- Words are sequences of alphanumeric characters separated by non-alphanumeric characters.
-- initcap('hi THOMAS') → Hi Thomas
SELECT INITCAP('hI ThIs iS AN ExAmPlE');

-- left ( string text, n integer ) → text
-- Returns first n characters in the string, or when n is negative, returns all but last |n| characters.
-- left('abcde', 2) → ab

-- length ( text ) → integer
-- Returns the number of characters in the string.
-- length('jose') → 4
SELECT LENGTH('123abc789'); --9

-- lpad ( string text, length integer [, fill text ] ) → text
-- Extends the string to length length by prepending the characters fill (a space by default). 
--  If the string is already longer than length then it is truncated (on the right).
-- lpad('hi', 5, 'xy') → xyxhi

-- ltrim ( string text [, characters text ] ) → text
-- Removes the longest string containing only characters in characters (a space by default) from the start of string.
-- ltrim('zzzytest', 'xyz') → test

-- md5 ( text ) → text
-- Computes the MD5 hash of the argument, with the result written in hexadecimal.
-- md5('abc') → 900150983cd24fb0​d6963f7d28e17f72
SELECT MD5('k'); -- 8ce4b16b22b58894aa86c421e8759df3

-- parse_ident ( qualified_identifier text [, strict_mode boolean DEFAULT true ] ) → text[]
-- Splits qualified_identifier into an array of identifiers, removing any quoting of individual identifiers. 
-- By default, extra characters after the last identifier are considered an error; but if the second parameter is false, 
-- then such extra characters are ignored. (This behavior is useful for parsing names for objects like functions.) 
-- Note that this function does not truncate over-length identifiers. If you want truncation you can cast the result to name[].
-- parse_ident('"SomeSchema".someTable') → {SomeSchema,sometable}

-- pg_client_encoding ( ) → name
-- Returns current client encoding name.
-- pg_client_encoding() → UTF8

-- quote_ident ( text ) → text
-- Returns the given string suitably quoted to be used as an identifier in an SQL statement string.
-- Quotes are added only if necessary (i.e., if the string contains non-identifier characters or would
-- be case-folded). Embedded quotes are properly doubled. See also Example 42.1.
-- quote_ident('Foo bar') → "Foo bar"
SELECT QUOTE_NULLABLE('Foo bar');

-- quote_literal ( text ) → text
-- Returns the given string suitably quoted to be used as a string literal in an SQL statement string.
-- Embedded single-quotes and backslashes are properly doubled. Note that quote_literal returns
-- null on null input; if the argument might be null, quote_nullable is often more suitable.
-- quote_literal(E'O\'Reilly') → 'O''Reilly'
SELECT QUOTE_NULLABLE(E'He\'len');

-- quote_literal ( anyelement ) → text
-- Converts the given value to text and then quotes it as a literal. Embedded single-quotes and backslashes are properly doubled.
-- quote_literal(42.5) → '42.5'
SELECT QUOTE_LITERAL(33.6);

-- quote_nullable ( text ) → text
-- Returns the given string suitably quoted to be used as a string literal in an SQL statement string;
-- or, if the argument is null, returns NULL. Embedded single-quotes and backslashes are properly doubled. See also Example 42.1.
-- quote_nullable(NULL) → NULL
SELECT QUOTE_NULLABLE(NULL);
SELECT QUOTE_NULLABLE('hey');

-- quote_nullable ( anyelement ) → text
-- Converts the given value to text and then quotes it as a literal; or, if the argument is null, 
-- returns NULL. Embedded single-quotes and backslashes are properly doubled.
-- quote_nullable(42.5) → '42.5'
SELECT QUOTE_NULLABLE(33.6);

-- regexp_match ( string text, pattern text [, flags text ] ) → text[]
-- Returns captured substring(s) resulting from the first match of a POSIX regular expression to the string;
-- regexp_match('foobarbequebaz', '(bar)(beque)') → {bar,beque}

-- regexp_matches ( string text, pattern text [, flags text ] ) → setof text[]
-- Returns captured substring(s) resulting from matching a POSIX regular expression to the string;
-- regexp_matches('foobarbequebaz', 'ba.', 'g') →
--  {bar}
--  {baz}

-- regexp_replace ( string text, pattern text, replacement text [, flags text ] ) → text
-- Replaces substring(s) matching a POSIX regular expression;
-- regexp_replace('Thomas', '.[mN]a.', 'M') → ThM
SELECT REGEXP_REPLACE('To the new beginings', '\s+', '_');

-- regexp_split_to_array ( string text, pattern text [, flags text ] ) → text[]
-- Splits string using a POSIX regular expression as the delimiter;
-- regexp_split_to_array('hello world', '\s+') → {hello,world}
SELECT REGEXP_SPLIT_TO_ARRAY('To the new beginings', '\s+');

-- regexp_split_to_table ( string text, pattern text [, flags text ] ) → setof text
-- Splits string using a POSIX regular expression as the delimiter;
-- regexp_split_to_table('hello world', '\s+') →
--  hello
--  world
SELECT REGEXP_SPLIT_TO_TABLE('To the new beginings', '\s+');

-- repeat ( string text, number integer ) → text
-- Repeats string the specified number of times.
-- repeat('Pg', 4) → PgPgPgPg
SELECT REPEAT('123', 3);

-- replace ( string text, from text, to text ) → text
-- Replaces all occurrences in string of substring from with substring to.
-- replace('abcdefabcdef', 'cd', 'XX') → abXXefabXXef
SELECT REPLACE('PostgreSQL', 'o', 'e'); -- PestgreSQL

-- reverse ( text ) → text
-- Reverses the order of the characters in the string.
-- reverse('abcde') → edcba
SELECT REVERSE('abcde');

-- right ( string text, n integer ) → text
-- Returns last n characters in the string, or when n is negative, returns all but first |n| characters.
-- right('abcde', 2) → de
SELECT RIGHT('abcde', 2);

-- rpad ( string text, length integer [, fill text ] ) → text
-- Extends the string to length length by appending the characters fill (a space by default).
-- If the string is already longer than length then it is truncated.
-- rpad('hi', 5, 'xy') → hixyx
SELECT RPAD('He', 5, 'y'); -- Heyyy

-- rtrim ( string text [, characters text ] ) → text
-- Removes the longest string containing only characters in characters (a space by default) from the end of string.
-- rtrim('testxxzx', 'xyz') → test
SELECT RTRIM('PppPostgresqllllLlL', 'pl'); -- PppPostgresqllllLlL
SELECT RTRIM('PppPostgresqllllLlL', 'PLpl'); -- PppPostgresq

-- split_part ( string text, delimiter text, n integer ) → text
-- Splits string at occurrences of delimiter and returns the n'th field (counting from one).
-- split_part('abc~@~def~@~ghi', '~@~', 2) → def
SELECT SPLIT_PART('Post-@-gre-@-SQL-@-', '-@-', 1); -- Post
SELECT SPLIT_PART('Post-@-gre-@-SQL-@-', '-@-', 2); -- gre
SELECT SPLIT_PART('Post-@-gre-@-SQL-@-', '-@-', 3); -- SQL
SELECT SPLIT_PART('Post-@-gre-@-SQL-@-', '-@-', 4); --   

-- strpos ( string text, substring text ) → integer
-- Returns starting index of specified substring within string, or zero if it's not present.
-- (Same as position(substring in string), but note the reversed argument order.)
-- strpos('high', 'ig') → 2
SELECT STRPOS('PostgreSQL', 'SQL'); -- 8

-- substr ( string text, start integer [, count integer ] ) → text
-- Extracts the substring of string starting at the start'th character, and extending for 
-- count characters if that is specified. (Same as substring(string from start for count).)
-- substr('alphabet', 3) → phabet
-- substr('alphabet', 3, 2) → ph
SELECT SUBSTR('PostgreSQL', 1, 4); -- Post
SELECT SUBSTR('PostgreSQL', 8, 3); -- SQL
SELECT SUBSTR('PostgreSQL', 8, 5); -- SQL

-- starts_with ( string text, prefix text ) → boolean
-- Returns true if string starts with prefix.
-- starts_with('alphabet', 'alph') → t
SELECT STARTS_WITH('PostgreSQL', 'p'); -- F
SELECT STARTS_WITH('PostgreSQL', 'P'); -- T

-- to_ascii ( string text ) → text
-- to_ascii ( string text, encoding name ) → text
-- to_ascii ( string text, encoding integer ) → text
-- Converts string to ASCII from another encoding, which may be identified by name or number. 
-- If encoding is omitted the database encoding is assumed (which in practice is the only useful case). 
-- The conversion consists primarily of dropping accents. Conversion is only supported from LATIN1,
-- LATIN2, LATIN9, and WIN1250 encodings.
-- to_ascii('Karél') → Karel
SELECT TO_ASCII('Karél', 8);
SELECT TO_ASCII('Karel', 8);

-- to_hex ( integer ) → text
-- to_hex ( bigint ) → text
-- Converts the number to its equivalent hexadecimal representation.
-- to_hex(2147483647) → 7fffffff
SELECT TO_HEX(2147483647);

-- translate ( string text, from text, to text ) → text
-- Replaces each character in string that matches a character in the from set 
-- with the corresponding character in the to set. If from is longer than to, 
-- occurrences of the extra characters in from are deleted.
-- translate('12345', '143', 'ax') → a2x5
SELECT TRANSLATE('12345', '143', 'ax');
SELECT TRANSLATE('12345678', '275', 'ABC');
----------------------------------------------------------

SELECT format('Hello %s', 'World');
-- Result: Hello World

SELECT format('Testing %s, %s, %s, %%', 'one', 'two', 'three');
-- Result: Testing one, two, three, %

SELECT format('INSERT INTO %I VALUES(%L)', 'Foo bar', E'O\'Reilly');
-- Result: INSERT INTO "Foo bar" VALUES('O''Reilly')

SELECT format('INSERT INTO %I VALUES(%L)', 'locations', 'C:\Program Files');
-- Result: INSERT INTO locations VALUES('C:\Program Files')

SELECT format('|%10s|', 'foo');
-- Result: |       foo|

SELECT format('|%-10s|', 'foo');
-- Result: |foo       |

SELECT format('|%*s|', 10, 'foo');
-- Result: |       foo|

SELECT format('|%*s|', -10, 'foo');
-- Result: |foo       |

SELECT format('|%-*s|', 10, 'foo');
-- Result: |foo       |

SELECT format('|%-*s|', -10, 'foo');
-- Result: |foo       |


-- SELECT format('Testing %3$s, %2$s, %1$s', 'one', 'two', 'three');
-- Result: Testing three, two, one

SELECT format('|%*2$s|', 'foo', 10, 'bar');
-- Result: |       bar|

SELECT format('|%1$*2$s|', 'foo', 10, 'bar');
-- Result: |       foo|

-- --  PostgreSQL's format function allows format specifiers with and without position 
-- -- 	fields to be mixed in the same format string. 
-- -- 	A format specifier without a position field always uses the next argument 
-- -- 	after the last argument consumed.

SELECT format('Testing %3$s, %2$s, %s, %1$s', 'one', 'two', 'three');
-- -- Result: Testing three, two, three, one
																		   
----------------------------------------------------------
