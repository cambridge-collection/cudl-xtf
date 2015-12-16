<!-- Root CUDL document prefilter stylesheet.
     This stylesheet maps from metadata JSON to fields for XTF to index.
     -->
<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cudl="http://cudl.lib.cam.ac.uk/xtf/"
    xmlns:tag="http://cudl.lib.cam.ac.uk/xtf/ns/tagging"
    xmlns:util="http://cudl.lib.cam.ac.uk/xtf/ns/util"
    xmlns:annotation="http://cudl.lib.cam.ac.uk/xtf/ns/annotation"
    exclude-result-prefixes="#all">

    <xsl:import href="./prefilter/xmlprefilter.xsl"/>
    <xsl:import href="./common/funcs.xsl"/>
    <xsl:import href="./passes/tagging.xsl"/>
    <xsl:import href="./passes/annotations.xsl"/>


    <xsl:template match="/">
        <!-- Perform the exact same prefiltering operations that the non-tagging
             prefilter does. -->
        <xsl:variable name="prefiltered">
            <!-- Invoke the root template provided by prefilterCommon -->
            <xsl:next-match/>
        </xsl:variable>

        <!-- Insert tagging fields into the prefiltered tree at first/primary
             descriptive metadata section which represents the entire document.
             -->
        <xsl:variable name="with-tags" 
                      select="tag:insert-tag-fields(/root, $prefiltered)"/>


        <xsl:message>
            @ root:
                doc uri: <xsl:value-of select="document-uri(/)"/>
                doc: <xsl:value-of select="document-uri(/root/pages[1]/ancestor::document-node())"/>
                doc: <xsl:value-of select="document-uri(util:doc(/root/pages[1]))"/>
                doc uri: <xsl:value-of select="document-uri(/root/pages[1])"/>
        </xsl:message>

        <!-- Insert per-page annotations in a sub document for each page which
             has annotations. -->
        <xsl:copy-of select="annotation:insert-annotation-fields(/, $with-tags)"/>
    </xsl:template>
</xsl:stylesheet>
