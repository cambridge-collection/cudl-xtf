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
   <!-- Import NLM Templates and Functions.                                  -->
   <!-- ====================================================================== -->

   <xsl:import href="../../tei/teiPreFilter.xsl"/>

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

   <!-- ====================================================================== -->
   <!-- Metadata Indexing                                                      -->
   <!-- ====================================================================== -->

   <!-- 
      override template in modsPreFilter.xml, get rid of 'add-fields' part, or
      it will run twice.
   -->
   <xsl:template name="get-meta">
      <!-- Access Dublin Core Record (if present) -->
      <xsl:variable name="dcMeta">
         <xsl:call-template name="get-dc-meta"/>
      </xsl:variable>
      
      <!-- If no Dublin Core present, then extract meta-data from the TEI -->
      <xsl:variable name="meta">
         <xsl:choose>
            <xsl:when test="$dcMeta/*">
               <xsl:copy-of select="$dcMeta"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:call-template name="get-tei-title"/>
               <xsl:call-template name="get-tei-creator"/>
               <xsl:call-template name="get-tei-subject"/>
               <xsl:call-template name="get-tei-description"/>
               <xsl:call-template name="get-tei-publisher"/>
               <xsl:call-template name="get-tei-contributor"/>
               <xsl:call-template name="get-tei-date"/>
               <xsl:call-template name="get-tei-type"/>
               <xsl:call-template name="get-tei-format"/>
               <xsl:call-template name="get-tei-identifier"/>
               <xsl:call-template name="get-tei-source"/>
               <xsl:call-template name="get-tei-language"/>
               <xsl:call-template name="get-tei-relation"/>
               <xsl:call-template name="get-tei-coverage"/>
               <xsl:call-template name="get-tei-rights"/>
               <!-- special values for OAI -->
               <xsl:call-template name="oai-datestamp"/>
               <xsl:call-template name="oai-set"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:copy-of select="$meta"/>
      
   </xsl:template>

</xsl:stylesheet>