<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:FileUtils="java:org.cdlib.xtf.xslt.FileUtils" 
   xmlns:local="http://cdlib.org/local"
   xmlns:mets="http://www.loc.gov/METS/" 
   xmlns:mods="http://www.loc.gov/mods/"
   xmlns:parse="http://cdlib.org/xtf/parse" 
   xmlns:saxon="http://saxon.sf.net/"
   xmlns:scribe="http://archive.org/scribe/xml" 
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" 
   xmlns:xtf="http://cdlib.org/xtf"
   xmlns:cudl="http://cudl.lib.cam.ac.uk/xtf/" 
   exclude-result-prefixes="#all">

   <!-- ====================================================================== -->
   <!-- Import DCP Templates and Functions.                                    -->
   <!-- ====================================================================== -->

   <xsl:import href="../../dcp/dcpPreFilter.xsl"/>

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

      <xsl:for-each select="$meta/*">
         <xsl:choose>
            <xsl:when test="name()='descriptiveMetadata'">

               <!-- add extra into descriptivemetadata -->
               <xsl:apply-templates select=".">
                  <xsl:with-param name="extra" select="$extra"/>
               </xsl:apply-templates>

            </xsl:when>
            <xsl:otherwise>
               <xsl:copy-of select="."/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:template>

   <xsl:template match="descriptiveMetadata">
      <xsl:param name="extra"/>

      <!-- single part -->
      <xsl:copy>
         <xsl:choose>
            <xsl:when test="count(part) = 1">

               <xsl:apply-templates select="./part">
                  <xsl:with-param name="extra" select="$extra"/>
               </xsl:apply-templates>

            </xsl:when>
            <xsl:otherwise/>
         </xsl:choose>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="part">
      <xsl:param name="extra"/>

      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:for-each select="*">
            <xsl:copy-of select="."/>
         </xsl:for-each>
         <xsl:copy-of select="$extra"/>
      </xsl:copy>
   </xsl:template>

   <!-- ====================================================================== -->
   <!-- Metadata Indexing                                                      -->
   <!-- ====================================================================== -->

   <!-- 
      override template in modsPreFilter.xml, get rid of 'add-fields' part, or
      it will run twice.
   -->
   <xsl:template name="get-meta">
      
      <xsl:variable name="meta">

         <descriptiveMetadata>
            <xsl:apply-templates select="//data"/>
         </descriptiveMetadata>

         <xsl:call-template name="get-numberOfPages"/>
         <xsl:call-template name="get-embeddable"/>
         <xsl:call-template name="get-transcription-flag"/>
         <xsl:call-template name="get-pages"/>
         <xsl:call-template name="get-logical-structures"/>

         <xsl:if test="//transcription/p and not($hideTranscription='true')">
            <xsl:call-template name="make-transcription-pages"/>
         </xsl:if>
         
      </xsl:variable>

      <xsl:copy-of select="$meta"/>

   </xsl:template>

</xsl:stylesheet>