<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xtf="http://cdlib.org/xtf"
    xmlns:util="http://cudl.lib.cam.ac.uk/xtf/ns/util">

    <!-- Hackishly strip out HTML tags from text, leaving the plain text.
         Note: HTML entities are not converted... -->
    <xsl:function name="util:strip-html-tags">
        <xsl:param name="html" />

        <xsl:value-of select="replace($html, '&lt;/?[a-zA-Z][^&gt;]*&gt;', '')"/>
    </xsl:function>

    <xsl:function name="util:root" as="element()">
        <xsl:param name="el" as="element()"/>

        <xsl:copy-of select="($el/ancestor-or-self::*)[1]"/>
    </xsl:function>

    <xsl:function name="util:doc" as="document-node()">
        <xsl:param name="node" as="node()"/>

        <xsl:copy-of select="$node/ancestor-or-self::document-node()"/>
    </xsl:function>


    <!-- Merge extra element(s) into the base tree's root tag. -->
    <xsl:function name="util:merge" as="element()">
        <xsl:param name="base-tree" as="element()"/>
        <xsl:param name="extra-content" as="node()*"/>

        <!-- for-each used to estabish the context node -->
        <xsl:for-each select="$base-tree">
            <xsl:copy>
               <!-- Copy attributes and all child nodes. -->
                <xsl:copy-of select="@*|node()"/>

                <!-- Insert the extra content after the existing elements. -->
                <xsl:copy-of select="$extra-content"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:function>

    <!-- Post-process the index-input tree by appending elements to the dmd1
         (primary, document-level) subdocument.
         -->
    <xsl:function name="util:dmd1-append">
        <xsl:param name="index-input"/>
        <xsl:param name="elements"/>

        <xsl:apply-templates select="$index-input" mode="util:dmd1-append">
            <xsl:with-param name="elements" select="$elements"/>
        </xsl:apply-templates>
    </xsl:function>

    <xsl:template
        match="descriptiveMetadata/part[position() = 1 and @xtf:subDocument]"
        mode="util:dmd1-append">
        <xsl:param name="elements"/>

        <xsl:copy>
            <!-- No need to pass on elements as we've already inserting them here and there's only one 'first' part subdoc. -->
            <xsl:apply-templates select="@*|node()" mode="util:dmd1-append"/>

            <xsl:copy-of select="$elements"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()" mode="util:dmd1-append">
        <xsl:param name="elements"/>

        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="util:dmd1-append">
                <xsl:with-param name="elements" select="$elements"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:function name="util:doc-id" as="xs:string">
        <xsl:param name="json-meta-element" as="node()"/>
        <xsl:variable name="filename"
                      select="tokenize(document-uri(util:doc($json-meta-element)), '/')[last()]"/>

        <xsl:value-of select="substring-before($filename, '.json')"/>
    </xsl:function>

    <!-- Load the local.conf config file. The param xtf-root needs to be a path
         to the root of the XTF dir. -->
    <xsl:function name="util:get-config">
        <xsl:param name="xtf-root"/>

        <xsl:variable name="config-url" select="resolve-uri('./conf/local.conf', $xtf-root)"/>
        <xsl:variable name="config" select="document($config-url)"/>

        <xsl:if test="not($config/local-config)">
            <xsl:message terminate="yes">
                Config URL does not point to an XML doc rooted @ &lt;local-config&gt;:
                    <xsl:value-of select="$config-url"/>
                Is this the right path to XTF's root?:
                    <xsl:value-of select="$xtf-root"/>
            </xsl:message>
        </xsl:if>

        <xsl:copy-of select="$config"/>
    </xsl:function>

    <xsl:function name="util:get-config">
        <xsl:copy-of select="util:get-config('../../../')"/>
    </xsl:function>

    <xsl:function name="util:config-get-services-url">
        <xsl:param name="config"/>

        <xsl:value-of select="$config/local-config/services/@path"/>
    </xsl:function>

    <xsl:function name="util:config-get-services-url">
        <xsl:value-of select="util:config-get-services-url(util:get-config())"/>
    </xsl:function>

    <xsl:function name="util:set-url-query" as="xs:string">
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="query" as="xs:string"/>

        <xsl:value-of select="concat(replace($url, '[?].*$', ''), $query)"/>
    </xsl:function>
</xsl:stylesheet>
