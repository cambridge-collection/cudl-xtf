<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:dc="http://purl.org/dc/elements/1.1/" 
   xmlns:expand="http://cdlib.org/xtf/expand"
   xmlns:parse="http://cdlib.org/xtf/parse" 
   xmlns:xtf="http://cdlib.org/xtf"
   xmlns:saxon="http://saxon.sf.net/" 
   xmlns:FileUtils="java:org.cdlib.xtf.xslt.FileUtils"
   xmlns:CharUtils="java:org.cdlib.xtf.xslt.CharUtils" 
   xmlns:cudl="http://cudl.lib.cam.ac.uk/xtf/"
   xmlns:my="blah"
   extension-element-prefixes="saxon FileUtils" 
   exclude-result-prefixes="#all">

   <!-- ====================================================================== -->
   <!-- Root Template                                                          -->
   <!-- ====================================================================== -->

   <!-- override template in preFilterCommon.xsl -->
   <xsl:template match="/">
      
      <!-- <xtf-converted>
         <xsl:namespace name="xtf" select="'http://cdlib.org/xtf'"/>
         <xsl:call-template name="get-combined"/>
      </xtf-converted> -->

      <!-- for debugging, output temp xml -->
      <xsl:variable name="tree">
         <xtf-converted>
            <xsl:namespace name="xtf" select="'http://cdlib.org/xtf'"/>
            <xsl:call-template name="get-combined"/>
         </xtf-converted>
      </xsl:variable>
      <xsl:copy-of select="$tree" />
      <xsl:result-document href="{concat('../tmp/combined/', $fileID, '.xml')}" method="xml">
         <xsl:copy-of select="$tree" />
      </xsl:result-document>

   </xsl:template>

   <!-- ====================================================================== -->
   <!-- Processes fields                                                       -->
   <!-- ====================================================================== -->

   <xsl:template name="get-combined">

      <xsl:variable name="meta-extra">
         <xsl:variable name="extradata">
            <xsl:call-template name="get-extra"/>
         </xsl:variable>

         <!-- combine filtered metadata and extra -->
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

         <!-- list of terms -->
         <terms>
            <xsl:for-each select="$docextra/terms/term">

               <term>
                  <xsl:variable name="raw">
                     <xsl:value-of select="./raw" />
                  </xsl:variable>
                  
                  <!-- disable wordboost by setting it to zero if it is less then 1, or it 
                  will reduce the weight of the word in metadata -->
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
   </xsl:template>

</xsl:stylesheet>