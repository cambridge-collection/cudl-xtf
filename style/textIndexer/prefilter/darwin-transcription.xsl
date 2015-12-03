<!-- This stylesheet formats Darwin transcriptions for inclusion in the
     index.

     The input is XHTML, for example:
        http://cudl.lib.cam.ac.uk:3000/v1/transcription/dcp/diplomatic/internal/MS-DAR-00115-00281
-->
<xsl:stylesheet
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xtf="http://cdlib.org/xtf">

    <!-- Strip HTML head element -->
    <xsl:template match="xhtml:head" mode="darwin-transcription"/>

    <!-- Strip the "View letter on ..." heading -->
    <xsl:template match="*[@class='header']" mode="darwin-transcription"/>

    <!-- Strip out footnote superscripts -->
    <xsl:template match="xhtml:sup/xhtml:a" mode="darwin-transcription"/>

    <!-- Strip footnotes heading -->
    <xsl:template match="xhtml:h4[normalize-space() = 'Footnotes']" mode="darwin-transcription"/>

    <!-- Strip the footnotes list -->
    <xsl:template match="xhtml:ul[preceding-sibling::*[position() = 1 and self::xhtml:h4 and normalize-space() = 'Footnotes']]" mode="darwin-transcription"/>

    <!-- Replace non-breaking spaces with normal spaces
         FIXME: Is this required? Surely XTF knows about NBSP... -->
    <xsl:template match="text()" mode="darwin-transcription">
        <xsl:value-of select="translate(., '&#xa0;', ' ')"/>
    </xsl:template>

    <!-- Retain everything else by default -->
    <xsl:template match="@*|node()" priority="-1"
                  mode="darwin-transcription">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"
                                 mode="darwin-transcription"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
