<!-- The CUDL doc selector.
     This stylesheet is responsible for mapping source files to prefilters.
     Unlike standard XTF we only really have one main codepath for prefilters,
     which is the JSON prefilter.

     We do have an additional codepath for the tagging index which uses the
     normal JSON prefilter and adds some extra fields for tagging.

     For more on XTF doc selectors see:
     http://xtf.cdlib.org/documentation/programming-guide/index.html#text_doc
     -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- Whether we're creating the normal index or the tagging index. -->
    <xsl:param name="cudlIndexMode"/>

    <xsl:template match="/directory">
        <indexFiles>
            <xsl:apply-templates/>
        </indexFiles>
    </xsl:template>

    <xsl:template match="/directory/file">
            <!--JSON files -->
        <xsl:if test="ends-with(@fileName, 'PR-CHINESE-RUBBINGS-00001.json')">
            <indexFile
                fileName="{@fileName}"
                type="JSON"
                preFilter="{if ($cudlIndexMode = 'tagging')
                            then 'style/textIndexer/prefilter-tagging.xsl'
                            else 'style/textIndexer/prefilter/xmlprefilter.xsl'}"
                displayStyle="style/dynaXML/docFormatter/general/generalDocFormatter.xsl"/>
        </xsl:if>
    </xsl:template>

    <!-- Strip unnecessary whitespace to reduce output length when debugging. -->
    <xsl:template match="text()">
      <xsl:value-of select="normalize-space()"/>
    </xsl:template>
</xsl:stylesheet>
