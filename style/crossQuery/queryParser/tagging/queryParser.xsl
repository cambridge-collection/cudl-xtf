<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tag="http://cudl.lib.cam.ac.uk/xtf/ns/tagging"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:session="java:org.cdlib.xtf.xslt.Session"
    xmlns:freeformQuery="java:org.cdlib.xtf.xslt.FreeformQuery"
    extension-element-prefixes="session freeformQuery"
    exclude-result-prefixes="#all"
    version="2.0">

    <xsl:import href="../default/queryParser.xsl"/>

    <!-- Controls which tagging fields are included, and at what weight.

          recallScale = 0:
            No tagging fields

          0 < recallScale <= 0.5:
            - OR w/ secondary literature tags @ weight = recallScale * 2

          0.5 < recallScale <= 1:
            - OR w/ secondary literature tags @ weight =
                1 - ((recallScale - 0.5) * 2):
            - OR w/ secondary & crowdsourced tags @ weight =
                (recallScale - 0.5) * 2
        -->
    <xsl:param name="recallScale" select="0" as="xs:decimal"/>

    <xsl:template match="param[@name = 'keyword']">
        <or>
            <and fields="{replace($fieldList, 'text ?', '')}"
                slop="10"
                maxMetaSnippets="all"
                maxContext="60">
                <xsl:apply-templates/>
            </and>
            <and field="text" maxSnippets="3" maxContext="60">
                <xsl:apply-templates/>
            </and>
            <xsl:copy-of select="tag:variable-recall-query(token, $recallScale)"/>
        </or>
    </xsl:template>

    <xsl:function name="tag:variable-recall-query">
        <xsl:param name="keyword-tokens" as="element(token)+"/>
        <xsl:param name="recall-scale" as="xs:double"/>

        <xsl:variable name="scale" select="tag:clamp($recall-scale, 0, 1)"/>

        <xsl:variable name="terms">
            <xsl:apply-templates select="$keyword-tokens"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$scale eq 0"/>
            <xsl:when test="$scale le 0.5">
                <and field="tag-level-1"
                     boost="{$scale * 2}">
                    <xsl:copy-of select="$terms"/>
                </and>
            </xsl:when>
            <xsl:otherwise>
                <!-- 0.5 < $scale <= 1  -->
                <xsl:variable name="weight" select="($scale - 0.5) * 2"/>
                <and field="tag-level-1"
                     boost="{1 - $weight}">
                    <xsl:copy-of select="$terms"/>
                </and>
                <and field="tag-level-2"
                     boost="{$weight}">
                    <xsl:copy-of select="$terms"/>
                </and>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="tag:clamp">
        <xsl:param name="val" as="xs:double"/>
        <xsl:param name="lo" as="xs:double"/>
        <xsl:param name="hi" as="xs:double"/>

        <xsl:choose>
            <xsl:when test="$val lt $lo">
                <xsl:copy-of select="$lo"/>
            </xsl:when>
            <xsl:when test="$val gt $hi">
                <xsl:copy-of select="$hi"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$val"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
