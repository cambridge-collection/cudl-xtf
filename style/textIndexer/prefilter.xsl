<!-- Root CUDL document prefilter stylesheet.
     This stylesheet maps from metadata JSON to fields for XTF to index.
     -->
<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cudl="http://cudl.lib.cam.ac.uk/xtf/"
    exclude-result-prefixes="#all">

    <xsl:param name="mode"/>
    <xsl:param name="cudl:abcd"/>

    <xsl:template match="/">
        <xsl:message>
            ############ normal prefilter
            mode: <xsl:value-of select="$mode"/>
            cudl:abcd: <xsl:value-of select="$cudl:abcd"/>
        </xsl:message>
    </xsl:template>
</xsl:stylesheet>
