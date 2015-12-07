<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xtf="http://cdlib.org/xtf"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:sim="http://cudl.lib.cam.ac.uk/xtf/ns/similarity"
    xmlns:util="http://cudl.lib.cam.ac.uk/xtf/ns/util"
    exclude-result-prefixes="#all">

    <xsl:import href="./funcs.xsl"/>

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

    <!-- Index descriptive metadata sections by their ID -->
    <xsl:key
        name="sim:dmd-sections"
        match="/root/descriptiveMetadata"
        use="ID"/>

    <!-- Index structure nodes by the individual page numbers they cover -->
    <xsl:key
        name="sim:structure-by-page"
        match="/root/logicalStructures|/root/logicalStructures//children"
        use="xs:integer(startPagePosition) to xs:integer(endPagePosition)"/>

    <!-- Index pages by the metadata sections that reference them
         (via logical strucures) -->
    <xsl:key
        name="sim:pages-by-dmd"
        match="/root/pages"
        use="key('sim:structure-by-page', xs:integer(sequence))/descriptiveMetadataID"/>

    <xsl:function name="sim:similarity-candidates">
        <xsl:param name="json-meta-root"/>

        <xsl:apply-templates select="$json-meta-root" mode="sim:candidates"/>
    </xsl:function>


    <!-- Keep everything as-is unless we explicitly change anything -->
    <xsl:template match="@*|node()" mode="sim:candidates">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="sim:candidates"/>
        </xsl:copy>
    </xsl:template>

    <!-- Add our new similarity subdocuments to the meta block alongside the
         other data. -->
    <xsl:template match="/" mode="sim:candidates">
        <similarity-match-candidates>
            <!-- Introduce a new set of subdocuments to index similarity
                 info. We'll need to exclude these from the regular search
                 results... -->
            <xsl:apply-templates select=".//logicalStructures|.//logicalStructures//children" mode="sim:candidate"/>
        </similarity-match-candidates>
    </xsl:template>

    <!-- Each logical structure node is indexed for similarity.
         When querying for similarity, the index of the most specific structure
         (narowest & deepest) node for a given page is used to obtain the
         similarity ID for a page.
          -->
    <xsl:template match="logicalStructures|children" mode="sim:candidate">
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
            <xsl:for-each select="reverse(ancestor-or-self::*[self::logicalStructures or self::children])">
                <!-- TODO: Could modify the xtf:wordBoost value for similarity
                     fields from different depths in the logical structure tree.
                     e.g. boost deeper (more specific) fields or unboost less
                     specific fields (closer to the top). -->
                <xsl:apply-templates
                    select="key('sim:dmd-sections', descriptiveMetadataID)"
                    mode="sim:candidate"/>
            </xsl:for-each>

        </similarity-match-candidate>
    </xsl:template>

    <!-- Add similarity fields to descriptive metadata.  -->
    <xsl:template match="descriptiveMetadata" mode="sim:candidate">

        <similarity-fields for="descriptive-metadata {ID}">

            <xsl:apply-templates select="title/displayForm" mode="sim:field"/>

            <xsl:apply-templates
                select="authors|recipients|associated|donors"
                mode="sim:field"/>

            <xsl:apply-templates select="abstract|content" mode="sim:field"/>

            <xsl:if test="$sim:INDEX_TRANSCRIPTIONS">

                <xsl:apply-templates
                    select="key('sim:pages-by-dmd', ID)"
                    mode="sim:field"/>
            </xsl:if>

            <xsl:apply-templates
                select="subjects" mode="sim:field"/>

            <xsl:apply-templates
                select="creations/value/places"
                mode="sim:field"/>

        </similarity-fields>
    </xsl:template>

    <!-- These are the possible similarity fields which can be created: -->

    <!-- similarity-title contains the title of the subdocument -->
    <xsl:template match="title/displayForm[normalize-space()]" mode="sim:field">
        <similarity-title xtf:meta="true" xtf:index="true" xtf:store="{$sim:STORE_SIMILARITY}">
            <xsl:value-of select="normalize-space()"/>
        </similarity-title>
    </xsl:template>

    <!-- similarity-name contains any names of people associated with the
         subDocument. -->
    <xsl:template match="*[self::authors or self::recipients or self::associated or self::donors]/value/displayForm[normalize-space()]" mode="sim:field">
        <similarity-name xtf:meta="true" xtf:index="true" xtf:store="{$sim:STORE_SIMILARITY}">
            <!-- FIXME: strip date ranges from names -->
            <xsl:value-of select="normalize-space()"/>
        </similarity-name>
    </xsl:template>

    <!-- similarity-text contains any available full-text fields -->
    <xsl:template match="*[self::abstract or self::content]/displayForm[normalize-space()]" mode="sim:field">
        <similarity-text xtf:meta="true" xtf:index="true" xtf:store="{$sim:STORE_SIMILARITY}">
            <xsl:value-of select="normalize-space(util:strip-html-tags(.))"/>
        </similarity-text>
    </xsl:template>

    <!-- If sim:INDEX_TRANSCRIPTIONS is enabled, similarity-text nodes will be
         generated containing the transcription text from each page referenced
         by a metadata section's logical structure.  -->
    <xsl:template match="pages[transcriptionNormalisedURL|
                               transcriptionDiplomaticURL]"
                  mode="sim:field">
        <xsl:variable name="url"
                      select="(transcriptionNormalisedURL|transcriptionDiplomaticURL)[1]"/>

        <similarity-text xtf:meta="true" xtf:index="true" xtf:store="{$sim:STORE_SIMILARITY}" source="page {sequence} transcription">
            <xsl:value-of select="normalize-space(document(resolve-uri($url, $servicesURI))/xhtml:html/xhtml:body)"/>
        </similarity-text>
    </xsl:template>

    <!-- Ignore pages w/o transcriptions -->
    <xsl:template match="pages" mode="sim:field"/>

    <!-- similarity-subject contains a subject/topic associated with the
         item -->
    <xsl:template match="subjects/value/displayForm[normalize-space()]" mode="sim:field">
        <similarity-subject xtf:meta="true" xtf:index="true" xtf:store="{$sim:STORE_SIMILARITY}">
            <xsl:value-of select="normalize-space()"/>
        </similarity-subject>
    </xsl:template>

    <!-- similarity-place contains the name of a location associated with the
         item -->
    <xsl:template match="places/value/displayForm[normalize-space()]" mode="sim:field">
        <similarity-place xtf:meta="true" xtf:index="true" xtf:store="{$sim:STORE_SIMILARITY}">
            <xsl:value-of select="normalize-space()"/>
        </similarity-place>
    </xsl:template>

    <!-- Keep looking for matches in children while processing fields -->
    <xsl:template match="*" mode="sim:field">
        <xsl:apply-templates select="*" mode="sim:field"/>
    </xsl:template>

    <!-- Ignore everything by default while processing fields -->
    <xsl:template match="@*|node()" priority="-1" mode="sim:field"/>
</xsl:stylesheet>
