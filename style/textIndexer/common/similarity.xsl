<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xtf="http://cdlib.org/xtf"
    xmlns:sim="http://cudl.lib.cam.ac.uk/xtf/ns/similarity"
    exclude-result-prefixes="#all">

    <!-- This stylesheet is responsible for generating fields used by the CUDL
         similarity sugestions. We use XTF's moreLike query to get results
         similar other items in the index.

         There are many possible ways of doing similarity search. After playing
         with a few possibilities (per-document, per-dmd section, per-page) I've
         decided to perform similarity matches at the per-logical-structure
         level.

         Each logical structure node in the tree is indexed as a subdocument
         with similarity fields derived from the dmd section it's linked with.
         Additionally, each logical structure node gets similarity fields from
         the dmd sections of its ancestor logical structure nodes, so that each
         node gets indexed with fields from its context. This is useful because
         deep nodes tend to have just a title or very limited fields. However
         they'll inherit the dmd sectino of the root structure which typically
         has plenty of metadata.

         In this way we are performing per-document similarity search, except
         taking into account extra fields from the context/current location in
         the document. It should also allow sensible results both for documents
         with very regular metadata over the whole document, and documents with
         very varied metadata in subsections (e.g. collections of distinct
         essays/letters such as those in the logitude collection).
          -->

    <!-- Debugging:
         Turn on the -trace debug flag to debug the textIndexer. e.g the output
         of a single item can be viewed as follows:
             $ bin/textIndexer -clean -trace debug -dir mods/MS-ADD-03958 -index index-dbg | subl
         -->

    <!-- Currently transcriptions are not indexed as XTF runs out of memory
         while indexing. They'll get duplicated quite a bit for nested
         documents... -->
    <xsl:variable name="sim:INDEX_TRANSCRIPTIONS" select="false()"/>

    <!-- If false, similarity-* fields will be marked xtf:store="false"
         It appears that moreLike queries don't work unless the similarity
         fields are stored as well as indexed, which is annoying because they
         never need to be fetched... -->
    <xsl:variable name="sim:STORE_SIMILARITY" select="true()"/>

    <!-- Index transcriptionPage elements by dmdID -->
    <xsl:key
        name="sim:transcription-pages-by-dmd"
        match="/xtf-converted/xtf:meta/transcriptionPage"
        use="dmdID"/>

    <!-- Index descriptive metadat sections by their ID -->
    <xsl:key
        name="sim:dmd-sections"
        match="/xtf-converted/xtf:meta/descriptiveMetadata/part"
        use="ID"/>

    <!-- Keep everything as-is unless we explicitly change anything -->
    <xsl:template match="@*|node()" mode="similarity">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="similarity"/>
        </xsl:copy>
    </xsl:template>

    <!-- Add our new similarity subdocuments to the meta block alongside the
         other data. -->
    <xsl:template match="xtf:meta" mode="similarity">
        <xsl:call-template name="sim:copy-with-extra-content">
            <xsl:with-param name="extra-content">

                <!-- Introduce a new set of subdocuments to index similarity
                     info. We'll need to exclude these from the regular search
                     results... -->
                <xsl:apply-templates select=".//logicalStructure" mode="similarity-subdoc"/>

            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- Each logical structure node is indexed for similarity.
         When querying for similarity, the index of the most specific structure
         (narowest & deepest) node for a given page is used to obtain the
         similarity ID for a page.
          -->
    <xsl:template match="logicalStructure" mode="similarity-subdoc">
        <!-- The 0-based position of the logical structure item is the
             similarity ID. -->
        <xsl:variable name="similarityID" select="position() - 1"/>
        <!-- $fileID is defined in preFilterCommon.xsl -->
        <xsl:variable name="qualifiedSimID" select="concat($fileID, '/', $similarityID)"/>

        <similarity-match-candidate xtf:subDocument="similarity-{$similarityID}">

            <!-- The identifier field is used by XTF to identify the starting
                 point for similarity (moreLike) queries. -->
            <identifier xtf:meta="true" xtf:tokenize="no">
                <xsl:value-of select="$qualifiedSimID"/>
            </identifier>

            <itemId xtf:meta="true" xtf:index="true" xtf:tokenize="no" xtf:store="true">
                <xsl:value-of select="$fileID"/>
            </itemId>

            <structureNodeId xtf:meta="true" xtf:index="false" xtf:store="true">
                <xsl:value-of select="$similarityID"/>
            </structureNodeId>

            <!-- Generate similarity fields for each dmd section associated with
                 this logical structure. e.g. this structure node and its
                 ancestors. -->
            <xsl:for-each select="reverse(ancestor-or-self::logicalStructure)">
                <!-- TODO: Could modify the xtf:wordBoost value for similarity
                     fields from different depths in the logical structure tree.
                     e.g. boost deeper (more specific) fields or unboost less
                     specific fields (closer to the top). -->
                <xsl:apply-templates
                    select="key('sim:dmd-sections', descriptiveMetadataID)"
                    mode="similarity-subdoc"/>
            </xsl:for-each>

        </similarity-match-candidate>
    </xsl:template>

    <!-- Add similarity fields to descriptive metadata.  -->
    <xsl:template match="descriptiveMetadata/part" mode="similarity-subdoc">

        <similarity-fields for="descriptive-metadata {ID}">

            <xsl:apply-templates select="title" mode="similarity-field"/>

            <xsl:apply-templates
                select="authors/name|recipients/name|associated/name"
                mode="similarity-field"/>

            <xsl:apply-templates select="abstract|content" mode="similarity-field"/>

            <xsl:if test="$sim:INDEX_TRANSCRIPTIONS">
                <xsl:apply-templates
                    select="key('sim:transcription-pages-by-dmd', ID)"
                    mode="similarity-field"/>
            </xsl:if>

            <xsl:apply-templates
                select="subjects/subject" mode="similarity-field"/>

            <xsl:apply-templates
                select="creations/event/places/place"
                mode="similarity-field"/>

        </similarity-fields>
    </xsl:template>

    <!-- These are the possible similarity fields which can be created: -->

    <!-- similarity-titile contains the title of the subdocument -->
    <xsl:template match="title[normalize-space()]" mode="similarity-field">
        <similarity-title xtf:meta="true" xtf:index="true" xtf:store="{$sim:STORE_SIMILARITY}">
            <xsl:value-of select="normalize-space()"/>
        </similarity-title>
    </xsl:template>

    <!-- similarity-name contains any names of people associated with the
         subDocument. -->
    <xsl:template match="name[@displayForm]" mode="similarity-field">
        <similarity-name xtf:meta="true" xtf:index="true" xtf:store="{$sim:STORE_SIMILARITY}">
            <!-- FIXME: strip date ranges from names -->
            <xsl:value-of select="@displayForm"/>
        </similarity-name>
    </xsl:template>

    <!-- similarity-text contains any available full-text fields -->
    <xsl:template match="abstract|content" mode="similarity-field">
        <similarity-text xtf:meta="true" xtf:index="true" xtf:store="{$sim:STORE_SIMILARITY}">
            <xsl:value-of select="normalize-space()"/>
        </similarity-text>
    </xsl:template>

    <xsl:template match="transcriptionPage[normalize-space(transcriptionText)]"
                  mode="similarity-field">
        <similarity-text xtf:meta="true" xtf:index="true" xtf:store="{$sim:STORE_SIMILARITY}">
            <xsl:value-of select="normalize-space(transcriptionText)"/>
        </similarity-text>
    </xsl:template>

    <!-- similarity-subject contains a subject/topic associated with the
         item -->
    <xsl:template match="subject[@displayForm]" mode="similarity-field">
        <similarity-subject xtf:meta="true" xtf:index="true" xtf:store="{$sim:STORE_SIMILARITY}">
            <xsl:value-of select="@displayForm"/>
        </similarity-subject>
    </xsl:template>

    <!-- similarity-place contains the name of a location associated with the
         item -->
    <xsl:template match="place[@displayForm]" mode="similarity-field">
        <similarity-place xtf:meta="true" xtf:index="true" xtf:store="{$sim:STORE_SIMILARITY}">
            <xsl:value-of select="@displayForm"/>
        </similarity-place>
    </xsl:template>

    <!-- Utilities -->
    <xsl:template name="sim:copy-with-extra-content">
        <xsl:param name="extra-content"/>

        <xsl:copy>
            <!-- Copy attributes unchanged -->
            <xsl:apply-templates select="@*" mode="similarity"/>

            <!-- Insert the extra content before the existing elements. -->
            <xsl:copy-of select="$extra-content"/>

            <!-- Copy all the other nodes -->
            <xsl:apply-templates select="node()" mode="similarity"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
