<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:util="http://cudl.lib.cam.ac.uk/xtf/ns/util"
    version="2.0">

    <xsl:key name="util:indexer-conf-by-name"
             match="/textIndexer-config/index[@name]"
             use="@name"/>

    <!-- Get the configuration <index> element of the specified index. -->
    <xsl:function name="util:get-index-conf" as="element(index)?">
        <xsl:param name="name" as="xs:string"/>

        <xsl:copy-of select="key('util:indexer-conf-by-name', $name, 
                                 document('../../conf/textIndexer.conf'))[1]"/>
    </xsl:function>

    <!-- Get the filesystem path of the give index's database -->
    <xsl:function name="util:get-index-path" as="xs:string?">
        <xsl:param name="name" as="xs:string"/>

        <xsl:copy-of select="util:get-index-conf($name)/db/@path"/>
    </xsl:function>
</xsl:stylesheet>