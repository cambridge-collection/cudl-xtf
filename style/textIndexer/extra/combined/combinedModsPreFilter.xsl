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
   <!-- Import Mods Templates and Functions.                                   -->
   <!-- ====================================================================== -->

   <xsl:import href="../../mods/modsPreFilter.xsl"/>

   <!-- ====================================================================== -->
   <!-- Import Combined PreFilter Common.                                      -->
   <!-- ====================================================================== -->

   <xsl:import href="./combinedPreFilterCommon.xsl"/>

   <!-- ====================================================================== -->
   <!-- Output parameters                                                      -->
   <!-- ====================================================================== -->

   <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

   <!-- ====================================================================== -->
   <!-- Root Template                                                          -->
   <!-- ====================================================================== -->

   <!-- override template in preFilterCommon.xsl -->
   <!-- <xsl:template match="/">
      <xsl:variable name="tempxml">
         <xtf-converted>
            <xsl:namespace name="xtf" select="'http://cdlib.org/xtf'"/>
            <xsl:call-template name="get-combined"/>
         </xtf-converted>
      </xsl:variable>
      <xsl:copy-of select="$tempxml" />
      <xsl:result-document href="{concat('../tmp/combined/mods/', $fileID, '.xml')}" method="xml">
         <xsl:copy-of select="$tempxml" />
      </xsl:result-document>

   </xsl:template> -->


   <!-- ====================================================================== -->
   <!-- Combined Indexing                                                      -->
   <!-- ====================================================================== -->

   <!-- <xsl:template name="get-combined">

      <xsl:variable name="meta-extra">
         <xsl:variable name="extradata">
            <xsl:call-template name="get-extra"/>
         </xsl:variable>

         <xsl:apply-templates select="//*:combined/*:metadata">
            <xsl:with-param name="extradata" select="$extradata"/>
         </xsl:apply-templates>
      </xsl:variable>

      <xsl:call-template name="add-fields">
         <xsl:with-param name="display" select="'dynaxml'"/>
         <xsl:with-param name="meta" select="$meta-extra"/>
      </xsl:call-template>

   </xsl:template>

   <xsl:template name="get-extra">
      <xsl:variable name="docextra" select="//*:combined/extra/documentTerms"/>

      <extra>
         <xsl:attribute name="display" select="'true'" />

         <docID><xsl:value-of select="$docextra/docId" /></docID>
         <total><xsl:value-of select="$docextra/total" /></total>

         <terms>
            <xsl:for-each select="$docextra/terms/term">

               <term>
                  <xsl:variable name="raw">
                     <xsl:value-of select="./raw" />
                  </xsl:variable>
                  
                  <xsl:choose>
                     <xsl:when test="number($raw)>=1">
                        <xsl:attribute name="xtf:wordboost" select="floor(number($raw) div 1)"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:attribute name="xtf:wordboost" select="0"/>
                     </xsl:otherwise>
                  </xsl:choose>

                  <name><xsl:value-of select="./name" /></name>
                  <raw><xsl:value-of select="$raw" /></raw>
                  <value><xsl:value-of select="./value" /></value>
               </term>

            </xsl:for-each>
         </terms>

      </extra>

   </xsl:template>

   <xsl:template match="//*:combined/*:metadata">
      <xsl:param name="extradata"/>

      <xsl:variable name="metadata">
         <xsl:call-template name="get-meta"/>
      </xsl:variable>

      <xsl:call-template name="make-meta-extra">
         <xsl:with-param name="meta" select="$metadata"/>
         <xsl:with-param name="extra" select="$extradata"/>
      </xsl:call-template>
   </xsl:template> -->

   <!-- combine metadata and extra -->
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

   <!-- append 'extra' to the first item of descriptiveMetadata -->
   <xsl:template match="descriptiveMetadata">
      <xsl:param name="extra"/>

      <!-- handling multiple parts -->
      <xsl:copy>
         <xsl:choose>
            <xsl:when test="count(part) = 1">

               <xsl:apply-templates select="./part">
                  <xsl:with-param name="extra" select="$extra"/>
               </xsl:apply-templates>

            </xsl:when>
            <xsl:when test="count(part) > 1">

               <xsl:for-each select="./part">
                  <xsl:choose>
                     <xsl:when test="boolean(@xtf:subDocument='DOCUMENT')">

                        <xsl:apply-templates select=".">
                           <xsl:with-param name="extra" select="$extra"/>
                        </xsl:apply-templates> 

                     </xsl:when>
                     <xsl:otherwise>

                        <xsl:if test="position()=1">
                           <xsl:apply-templates select=".">
                              <xsl:with-param name="extra" select="$extra"/>
                           </xsl:apply-templates> 
                        </xsl:if>
                        <xsl:if test="position()>1">
                           <xsl:copy-of select="."/>
                        </xsl:if>

                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>

               <xsl:copy>
                  <xsl:copy-of select="."/>
                  <xsl:copy-of select="$extra"/>
               </xsl:copy>

            </xsl:otherwise>
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

         <xsl:call-template name="get-mods-type"/>
         <xsl:call-template name="get-mods-identifier"/>

         <descriptiveMetadata>
            <!--goes through the descriptive metadata parts-->
            <xsl:apply-templates select="//mets:dmdSec"/>
         </descriptiveMetadata>
         
         <!--these are to do with the document as a whole-->
         <xsl:call-template name="get-numberOfPages"/>
         <xsl:call-template name="get-embeddable"/>
         <xsl:call-template name="get-transcription-flag"/>
         
         <xsl:if test=".//*:note[@type='completeness']">
               <xsl:apply-templates select=".//*:note[@type='completeness']"/>
         </xsl:if>
         
         <!--these are to do with the structure-->
         <xsl:call-template name="get-pages"/>
         <xsl:call-template name="get-logical-structures"/>
         
         <!--transcription-->
         <xsl:choose>
            <xsl:when test="//mets:file[@USE='NORM-PAGE']">
               <xsl:apply-templates select="//mets:file[@USE='NORM-PAGE']"/>
            </xsl:when>
            <xsl:when test="//mets:file[@USE='DIPL-PAGE']">
               <xsl:apply-templates select="//mets:file[@USE='DIPL-PAGE']"/>
            </xsl:when>
         </xsl:choose>
         
      </xsl:variable>

      <xsl:copy-of select="$meta"/>

   </xsl:template>

    <!-- type -->
   <xsl:template name="get-mods-type">
      <type xtf:meta="true">mods</type>
   </xsl:template>

   <!-- identifier --> 
   <xsl:template name="get-mods-identifier">
      <identifier xtf:meta="true" xtf:tokenize="no">
         <xsl:value-of select="$fileID"/>
      </identifier>
   </xsl:template>

</xsl:stylesheet>