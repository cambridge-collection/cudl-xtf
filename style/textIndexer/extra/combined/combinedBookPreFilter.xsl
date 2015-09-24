<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:date="http://exslt.org/dates-and-times" 
   xmlns:parse="http://cdlib.org/xtf/parse"
   xmlns:xtf="http://cdlib.org/xtf" 
   xmlns:tei="http://www.tei-c.org/ns/1.0"
   xmlns:cudl="http://cudl.lib.cam.ac.uk/xtf/"
   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
   extension-element-prefixes="date" 
   exclude-result-prefixes="#all">

   <!-- ====================================================================== -->
   <!-- Import Bookreader Templates and Functions.                             -->
   <!-- ====================================================================== -->

   <xsl:import href="../../bookreader/bookPreFilter.xsl"/>

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
         <!-- remove duplicate display attribute -->
         <xsl:if test="name(.)!='display'">
            <xsl:copy-of select="."/>
         </xsl:if>
      </xsl:for-each>
      <xsl:copy-of select="$extra"/>

   </xsl:template>

</xsl:stylesheet>
