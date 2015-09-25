<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:xtf="http://cdlib.org/xtf"
   exclude-result-prefixes="#all">

   <!-- ====================================================================== -->
   <!-- Import Default Templates and Functions                                 -->
   <!-- ====================================================================== -->

   <xsl:import href="../../default/defaultPreFilter.xsl"/>

   <!-- ====================================================================== -->
   <!-- Import Combined PreFilter Common.                                      -->
   <!-- ====================================================================== -->

   <xsl:import href="./combinedPreFilterCommon.xsl"/>

   <!-- ====================================================================== -->
   <!-- Output parameters                                                      -->
   <!-- ====================================================================== -->

   <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

   <!-- ====================================================================== -->
   <!-- Processes fields                                                       -->
   <!-- ====================================================================== -->

   <!-- append extra in metadata -->
   <xsl:template name="make-meta-extra">
      <xsl:param name="meta"/>
      <xsl:param name="extra"/>

      <xsl:for-each select="$meta/xtf:meta/*">
         <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:copy-of select="$extra"/>

   </xsl:template>

   <!-- type -->
   <xsl:template name="get-default-type">
      <type xtf:meta="true">default</type>
   </xsl:template>

   <!-- identifier -->
   <xsl:template name="get-default-identifier">
      <identifier xtf:meta="true" xtf:tokenize="no">
         <xsl:value-of select="$fileID" />
      </identifier>
   </xsl:template>

</xsl:stylesheet>