:: Batch file to call XTF textIndexer then run Perl script to generate JSON on Windows

:: Parameter 1 = scheme/post/port/path to /xtf e.g. http://localhost:8080

REM Path to JSON output * change as required *

SET jsonpath="C:/Apache/apache-2.2/htdocs/cudl/test-json/"

REM Call textIndexer and write console output to output.txt

CALL textIndexer -index default > output.txt
type output.txt

REM From output.txt file, extract names of indexed XML docs

If EXIST xmlnames.txt del xmlnames.txt

FOR /F "tokens=2 delims=[]" %%x in ('find "Indexing" output.txt') DO echo %%x >> xmlnames.txt

If EXIST xmlnames.txt perl newGenerateJson %1 "xmlnames.txt" %jsonpath%
