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

   <xsl:import href="../../nlm/nlmPreFilter.xsl"/>

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
      
      <!-- If no Dublin Core present, then extract meta-data from the NLM -->
      <xsl:variable name="meta">
         <xsl:choose>
            <xsl:when test="$dcMeta/*">
               <xsl:copy-of select="$dcMeta"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:call-template name="get-nlm-title"/>
               <xsl:call-template name="get-nlm-creator"/>
               <xsl:call-template name="get-nlm-subject"/>
               <xsl:call-template name="get-nlm-description"/>
               <xsl:call-template name="get-nlm-publisher"/>
               <xsl:call-template name="get-nlm-contributor"/>
               <xsl:call-template name="get-nlm-date"/>
               <xsl:call-template name="get-nlm-type"/>
               <xsl:call-template name="get-nlm-format"/>
               <xsl:call-template name="get-nlm-identifier"/>
               <xsl:call-template name="get-nlm-source"/>
               <xsl:call-template name="get-nlm-language"/>
               <xsl:call-template name="get-nlm-relation"/>
               <xsl:call-template name="get-nlm-coverage"/>
               <xsl:call-template name="get-nlm-rights"/>
               <!-- special values for OAI -->
               <xsl:call-template name="oai-datestamp"/>
               <xsl:call-template name="oai-set"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:copy-of select="$meta"/>

   </xsl:template>
   
</xsl:stylesheet>