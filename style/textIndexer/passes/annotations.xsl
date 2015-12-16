<!-- This stylesheet generates fields for document-level tags obtained from
     text mining literature related to an item. -->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xtf="http://cdlib.org/xtf"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:sim="http://cudl.lib.cam.ac.uk/xtf/ns/similarity"
    xmlns:annotation="http://cudl.lib.cam.ac.uk/xtf/ns/annotation"
    xmlns:util="http://cudl.lib.cam.ac.uk/xtf/ns/util"
    exclude-result-prefixes="#all">

    <xsl:import href="../common/funcs.xsl"/>

    <xsl:key name="annotation:annotation-by-page"
             match="/annotations/*[@page]"
             use="xs:integer(@page)"/>

    <!--=====================================================================-->

    <xsl:function name="annotation:annotation-fields" as="element()*">
        <xsl:param name="json-meta-root" as="document-node()"/>
        <xsl:param name="page" as="xs:integer"/>

        <xsl:message>
            page: <xsl:value-of select="$page"/>
            root: <xsl:copy-of select="$json-meta-root"/>
        </xsl:message>

        <xsl:apply-templates select="$json-meta-root" mode="annotation:annotations">
            <xsl:with-param name="page" select="$page"/>
        </xsl:apply-templates>
    </xsl:function>

    <xsl:template match="root" mode="annotation:annotations">
        <xsl:param name="page" as="xs:integer"/>
        <xsl:variable name="doc-id" select="util:doc-id(.)"/>

        <xsl:apply-templates
            select="annotation:get-annotation-data(util:doc-id(.))"
            mode="annotation:create-fields">
            <xsl:with-param name="page" select="$page"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="text()" mode="annotation:annotations">
        <xsl:message terminate="yes">Unexpected text() node encountered</xsl:message>
    </xsl:template>

    <!--=====================================================================-->

    <xsl:template match="/annotations" mode="annotation:create-fields">
        <xsl:param name="page" as="xs:integer"/>

        <xsl:variable name="annotations"
                      select="key('annotation:annotation-by-page', $page)"/>

        <xsl:message>
            annotation:create-fields -
                annotations: <xsl:copy-of select="$annotations"/>
        </xsl:message>

        <xsl:if test="$annotations">
            <annotations>
                <xsl:apply-templates
                    select="$annotations"
                    mode="annotation:create-fields"/>
            </annotations>
        </xsl:if>
    </xsl:template>

    <xsl:template match="about|person|place" mode="annotation:create-fields">
        <xsl:element name="annotation-{local-name()}">
            <xsl:attribute name="xtf:meta">true</xsl:attribute>
            <xsl:attribute name="xtf:store">false</xsl:attribute>

            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <!-- Ignore dates for now. Currently dates are stored in the database as
         ranges, with endpoints rounded to 50 year blocks. The permitted range
         is 0-2050. This gives us 41 possible buckets to index items against.
         We need to do some scoring on these buckets based on the number of
         people that have marked items aginst a given date bucket.
         -->
    <xsl:template match="date" mode="annotation:create-fields"/>

    <xsl:template match="text()" mode="annotation:create-fields"/>

    <!--=====================================================================-->

    <!-- Generate an XTF subdocument for each page in the JSON metadata which
         has associated annotations. -->
    <xsl:function name="annotation:generate-per-page-subdocs" as="element()">
        <xsl:param name="json-meta-root" as="document-node()"/>

        <xsl:apply-templates select="$json-meta-root"
                             mode="annotation:gen-subdocs"/>
    </xsl:function>

    <xsl:template match="/" mode="annotation:gen-subdocs">
        <xsl:variable name="annotations">
            <xsl:apply-templates select="/root/pages"
                                 mode="annotation:gen-subdocs"/>
        </xsl:variable>

        <xsl:if test="$annotations">
            <per-page-annotations>
                <xsl:copy-of select="$annotations"/>
            </per-page-annotations>
        </xsl:if>
    </xsl:template>

    <xsl:template match="pages" mode="annotation:gen-subdocs">
        <xsl:variable name="annotations"
                      select="annotation:annotation-fields(./ancestor::document-node(),
                                                           xs:integer(sequence))"/>

        <xsl:if test="$annotations">
            <page-annotations xtf:subDocument="page-annotations-{sequence}">
                <xsl:copy-of select="$annotations"/>
            </page-annotations>
        </xsl:if>
    </xsl:template>

    <!--=====================================================================-->

    <xsl:function name="annotation:insert-annotation-fields" as="element()">
        <xsl:param name="json-meta-root" as="document-node()"/>
        <xsl:param name="index-input" as="element()"/>

        <xsl:copy-of
            select="util:merge($index-input,
                               annotation:generate-per-page-subdocs($json-meta-root))"/>
    </xsl:function>

    <!-- Get the annotation data for doc-id. -->
    <xsl:function name="annotation:get-annotation-data" as="document-node()">
        <xsl:param name="doc-id" as="xs:string"/>

        <xsl:copy-of select="document(annotation:get-annotation-data-url($doc-id))"/>
    </xsl:function>

    <!-- Get the URL of the endpoint providing annotation data for a document
         ID. -->
    <xsl:function name="annotation:get-annotation-data-url" as="xs:anyURI">
        <xsl:param name="doc-id" as="xs:string"/>

        <xsl:value-of select="
            resolve-uri(concat($doc-id, '.xml'),
                resolve-uri('/v1/annotations/', util:config-get-services-url()))"/>
    </xsl:function>
</xsl:stylesheet>

