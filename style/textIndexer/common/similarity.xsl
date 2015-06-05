<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xtf="http://cdlib.org/xtf"
    xmlns:sim="http://cudl.lib.cam.ac.uk/xtf/ns/similarity"
    exclude-result-prefixes="#all">

    <!-- This stylesheet augments the pre-built metadata/index tree with
         additional fields use for XTF similarity search.

         It's run as a post-processing step once the preFilter has done its
         work.

         All the templates defined here are in mode "similarity", so they
         only have any effect when explicitly applying templates with mode
         similarity.

         Presently we only add similarity search fields on descriptive metadata
         subDocuments.

         Another possible strategy would be to do similarity search for pages
         with full-text transcriptions, falling back to per-section similarity
         for untranscribed pages. -->


    <!-- Index transcriptionPage elements by dmdID -->
    <xsl:key
        name="sim:transcription-pages-by-dmd"
        match="/xtf-converted/xtf:meta/transcriptionPage"
        use="dmdID"/>

    <!-- Keep everything as-is unless we explicitly change anything -->
    <xsl:template match="@*|node()" mode="similarity">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="similarity"/>
        </xsl:copy>
    </xsl:template>

    <!-- Add similarity fields to descriptive metadata.  -->
    <xsl:template match="descriptiveMetadata/part[@xtf:subDocument]" mode="similarity">
        <xsl:call-template name="sim:copy-with-extra-content">
            <xsl:with-param name="extra-content">

                <!-- TODO: could inherit certain metadata from the first dmd
                     section. e.g. subjects which seem to be only defined on
                     the first. -->

                <!-- Insert the identifier for the subdocument so that moreLike
                     queries return results related to this subDocument rather
                     than the parent document. -->
                <identifier xtf:meta="true" xtf:tokenize="no">
                    <!-- $fileID is defined in preFilterCommon.xsl -->
                    <xsl:value-of select="concat($fileID, '/', ID)"/>
                </identifier>

                <xsl:apply-templates select="title" mode="similarity-field"/>

                <xsl:apply-templates
                    select="authors/name|recipients/name|associated/name"
                    mode="similarity-field"/>

                <xsl:apply-templates select="abstract|content" mode="similarity-field"/>

                <xsl:apply-templates
                    select="key('sim:transcription-pages-by-dmd', ID)"
                    mode="similarity-field"/>

                <xsl:apply-templates
                    select="subjects/subject" mode="similarity-field"/>

                <xsl:apply-templates
                    select="creations/event/places/place"
                    mode="similarity-field"/>

            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- These are the possible similarity fields which can be created: -->

    <!-- similarity-titile contains the title of the subdocument -->
    <xsl:template match="title[normalize-space()]" mode="similarity-field">
        <similarity-title xtf:meta="true">
            <xsl:value-of select="normalize-space()"/>
        </similarity-title>
    </xsl:template>

    <!-- similarity-name contains any names of people associated with the
         subDocument. -->
    <xsl:template match="name[@displayForm]" mode="similarity-field">
        <similarity-name xtf:meta="true">
            <!-- FIXME: strip date ranges from names -->
            <xsl:value-of select="@displayForm"/>
        </similarity-name>
    </xsl:template>

    <!-- similarity-text contains any available full-text fields -->
    <xsl:template match="abstract|content" mode="similarity-field">
        <similarity-text xtf:meta="true">
            <xsl:value-of select="normalize-space()"/>
        </similarity-text>
    </xsl:template>

    <xsl:template match="transcriptionPage[normalize-space(transcriptionText)]"
                  mode="similarity-field">
        <similarity-text xtf:meta="true">
            <xsl:value-of select="normalize-space(transcriptionText)"/>
        </similarity-text>
    </xsl:template>

    <!-- similarity-subject contains a subject/topic associated with the
         item -->
    <xsl:template match="subject[@displayForm]" mode="similarity-field">
        <similarity-subject xtf:meta="true">
            <xsl:value-of select="@displayForm"/>
        </similarity-subject>
    </xsl:template>

    <!-- similarity-place contains the name of a location associated with the
         item -->
    <xsl:template match="place[@displayForm]" mode="similarity-field">
        <similarity-place xtf:meta="true">
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
