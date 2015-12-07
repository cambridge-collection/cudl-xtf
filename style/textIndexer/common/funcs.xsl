<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:util="http://cudl.lib.cam.ac.uk/xtf/ns/util">

    <!-- Hackishly strip out HTML tags from text, leaving the plain text.
         Note: HTML entities are not converted... -->
    <xsl:function name="util:strip-html-tags">
        <xsl:param name="html" />

        <xsl:value-of select="replace($html, '&lt;/?[a-zA-Z][^&gt;]*&gt;', '')"/>
    </xsl:function>


    <!-- Merge extra element(s) into the base tree's root tag. -->
    <xsl:function name="util:merge">
        <xsl:param name="base-tree"/>
        <xsl:param name="extra-content"/>

        <!-- for-each used to estabish the context node -->
        <xsl:for-each select="$base-tree/*">
            <xsl:copy>
               <!-- Copy attributes and all child nodes. -->
                <xsl:copy-of select="@*|node()"/>

                <!-- Insert the extra content after the existing elements. -->
                <xsl:copy-of select="$extra-content"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:function>
</xsl:stylesheet>
