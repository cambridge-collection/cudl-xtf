There are a number of places in the /xtf/conf directory where server or path settings need to be changed for local, dev or live use:

1. local.conf - uri element path attribute
(used by preFilters for transcription indexing)

2. textIndexer.conf - src element path attribute
(path to data directory)

3. indexValidation.xml - crossquery
(sample search on xtf tomcat)

The versions in svn are all set to the live environment. These will need to be changed for local or dev use