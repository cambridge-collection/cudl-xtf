<!-- This stylesheet generates fields for document-level tags obtained from
     the cudl-services tag endpoint.

     The tags are obtained from different sources and merged together. Currently
     the sources are:

     * 3rd-party: Text mining literature related to an item.
     * annotations: Annotations that users have added using cudl-viewer's
           tagging UI
     * user-removes: Down-weighting and potentially removal of tags using data
           from cudl-viewer tagging users striking out tags in the wordcloud.

     We have a requirement to be able to select from a continuous sliding scale
     of reliability/guaranteed provenance, allowing searching against only the
     high quality metadata, through to searching metadata & text mined tags and
     finally those plus user annotations and removes.

     In order to implement this sliding scale of reliability we index two sets
     of tags with different field names:

     * Just 3rd-party tags
     * All tags: 3rd-party, annotations and user-removes

     Each tags has a positive value which indicates its importance. Indexed tags
     are boosted using these values.

     In order to get a continuous scale between the three levels of reliability
     we query in one of two ways. Imagine the slider is set out as follows:
        [a.....b.....c]
         1  2  3    4
     a, b and c are the three levels of reliability.

     At position 1 we can just query a. At 3 we just query b and so on.
     At position 2 we include a and b in the query using a boolean OR. Scoring
     values from a and b are scaled according to the position on the scale, so
     at position 2 a and b would contribute 50% of their full score. At position
     4 we'd query b and c, with approx 20% to 80% weighting for b and c
     respectively.
     -->
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

    <!-- -->
    <xsl:variable name="tag:TAG_SOURCE_3RD" select="('3rd-party')"/>

    <!-- Not providing a tagsource results in all sources being selected.
         At the time of writing that is 3rd-party, annotations and user-removes
         -->
    <xsl:variable name="tag:TAG_SOURCE_ALL" select="()"/>

    <xsl:variable name="tag:FIELDS">
        <tag:tag-field name="tag-level-1" sources="3rd-party"/>
        <tag:tag-field name="tag-level-2" sources="3rd-party,annotations,user-removes"/>
    </xsl:variable>

    <!-- Fetch merged tag data from the specified sources and mark for indexing
         against the provided field-name. -->
    <xsl:function name="tag:tagging-fields">
        <xsl:param name="docId" as="xs:string"/>
        <xsl:param name="sources" as="element(tag:tag-field)+"/>

        <tags>
            <xsl:for-each select="$sources">
                <xsl:apply-templates
                    select="tag:get-tag-data($docId,
                                             tokenize(@sources, ','))"
                    mode="tag:generate-index-fields">
                    <xsl:with-param name="tag-field-name" select="@name"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </tags>
    </xsl:function>

    <xsl:function name="tag:tagging-fields">
        <xsl:param name="docId" as="xs:string"/>

        <xsl:copy-of select="tag:tagging-fields($docId, $tag:FIELDS/tag:tag-field)"/>
    </xsl:function>

    <xsl:template match="/" mode="tag:generate-index-fields">
        <xsl:param name="tag-field-name" as="xs:string"/>

        <xsl:apply-templates select="/tags/tag" mode="tag:generate-index-fields">
            <xsl:with-param name="tag-field-name" select="$tag-field-name"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="tag" mode="tag:generate-index-fields">
        <xsl:param name="tag-field-name" as="xs:string"/>

        <xsl:element name="{$tag-field-name}">
            <xsl:attribute name="xtf:meta">true</xsl:attribute>
            <xsl:attribute name="xtf:store">false</xsl:attribute>
            <xsl:attribute name="xtf:wordBoost">
                <xsl:value-of select="@value"/>
            </xsl:attribute>

            <xsl:value-of select="normalize-space()"/>
        </xsl:element>
    </xsl:template>

    <!-- Generate tagging fields and insert them into the root descriptive
         metadata subdocument. -->
    <xsl:function name="tag:insert-tag-fields">
        <xsl:param name="json-meta-root"/>
        <xsl:param name="index-input"/>

        <xsl:copy-of select="util:dmd1-append(
                                 $index-input,
                                 tag:tagging-fields(util:doc-id($json-meta-root)))"/>
    </xsl:function>

    <!-- Fetch the tag data for a document ID. -->
    <xsl:function name="tag:get-tag-data" as="document-node()">
        <xsl:param name="doc-id" as="xs:string"/>
        <xsl:param name="sources" as="xs:string*"/>

        <xsl:copy-of select="document(tag:get-tag-data-url($doc-id, $sources))"/>
    </xsl:function>

    <!-- Get the URL of the endpoint providing tag data for a document ID. -->
    <xsl:function name="tag:get-tag-data-url" as="xs:anyURI">
        <xsl:param name="doc-id" as="xs:string"/>
        <xsl:param name="sources" as="xs:string*"/>

        <!-- Note that resolve-uri('?foo', '/bar/baz') = /bar/?foo
             in XTF's version of Saxon. This is incorrect (at least, according
             to RFC 3986, not sure about RFC 2396 which the XPath spec allows
             compatability with).
            -->
        <xsl:value-of select="
            concat(
                resolve-uri(concat($doc-id, '.xml'),
                    resolve-uri('/v1/tags/', util:config-get-services-url())
                ),
                if (count($sources) != 0)
                    then concat('?sources=', encode-for-uri(string-join($sources, ',')))
                    else ''
            )"/>
    </xsl:function>
</xsl:stylesheet>
