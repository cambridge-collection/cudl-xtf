<!-- This stylesheet generates fields for document-level tags obtained from
     text mining literature related to an item. -->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xtf="http://cdlib.org/xtf"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:sim="http://cudl.lib.cam.ac.uk/xtf/ns/similarity"
    xmlns:tag="http://cudl.lib.cam.ac.uk/xtf/ns/tagging"
    xmlns:util="http://cudl.lib.cam.ac.uk/xtf/ns/util"
    exclude-result-prefixes="#all">

    <xsl:import href="../common/funcs.xsl"/>

    <!-- Generate the tagging fields -->
    <xsl:function name="tag:tagging-fields">
        <xsl:param name="json-meta-root"/>

        <xsl:apply-templates select="$json-meta-root" mode="tag:tagging"/>
    </xsl:function>

    <!-- Generate tagging fields and insert them into the root descriptive
         metadata subdocument. -->
    <xsl:function name="tag:insert-tag-fields">
        <xsl:param name="json-meta-root"/>
        <xsl:param name="index-input"/>

        <xsl:copy-of select="util:dmd1-append(
                                 $index-input, 
                                 tag:tagging-fields($json-meta-root))"/>
    </xsl:function>

    <xsl:template match="/" mode="tag:tagging">
        <xsl:variable name="doc-id" select="util:doc-id(.)"/>

        <xsl:apply-templates
            select="tag:get-tag-data(util:doc-id(.))"
            mode="tag:create-fields"/>
    </xsl:template>

    <xsl:template match="/tags[tag]" mode="tag:create-fields">
        <tags>
            <xsl:apply-templates mode="tag:create-fields"/>
        </tags>
    </xsl:template>

    <!-- Create fields for the tags that exist against this document.
         
         We store each tag twice. Once with the basic score value, which is
         currently just the frequency of the word from the source data.

         The second copy has its score adjusted by crowd-sourced data.-->
    <xsl:template match="tag" mode="tag:create-fields">
        <!-- The raw score is just the frequency, so it's always greater than
             zero. -->
        <xsl:copy-of select="tag:create-tag-field('tagRaw', normalize-space(.), @frequency)"/>

        <!-- Store the tag in a field with boost value adjusted by crowd-sourced
             down votes. If enough users vote against a tag it'll be scored at 0
             and ignored. -->
        <xsl:if test="xs:double(@adjusted-frequency) gt 0">
            <xsl:copy-of select="tag:create-tag-field('tagAdjusted', normalize-space(.),
                                                @adjusted-frequency)"/>
        </xsl:if>
    </xsl:template>

    <!-- Insert a tag value into the XTF index against the specified index field
         name, using the specified wordBoost value. -->
    <xsl:function name="tag:create-tag-field">
        <xsl:param name="field-name"/>
        <xsl:param name="tag-value"/>
        <xsl:param name="boost"/>

        <xsl:element name="{$field-name}">
            <xsl:attribute name="xtf:meta">true</xsl:attribute>
            <xsl:attribute name="xtf:store">false</xsl:attribute>
            <xsl:attribute name="xtf:wordBoost"><xsl:value-of select="$boost"/></xsl:attribute>

            <xsl:value-of select="$tag-value"/>
        </xsl:element>
    </xsl:function>

    <!-- Fetch the tag data for a document ID. -->
    <xsl:function name="tag:get-tag-data">
        <xsl:param name="doc-id"/>

        <xsl:copy-of select="document(tag:get-tag-data-url($doc-id))"/>
    </xsl:function>

    <!-- Get the URL of the endpoint providing tag data for a document ID. -->
    <xsl:function name="tag:get-tag-data-url">
        <xsl:param name="doc-id"/>

        <xsl:value-of select="
            resolve-uri(concat($doc-id, '.xml'),
                resolve-uri('/v1/tags/', util:config-get-services-url())
            )"/>
    </xsl:function>
</xsl:stylesheet>
