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
   <!-- Import Common Templates and Functions                                  -->
   <!-- ====================================================================== -->

   <xsl:import href="../common/preFilterCommon.xsl"/>

   <!-- ====================================================================== -->
   <!-- Output parameters                                                      -->
   <!-- ====================================================================== -->

   <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

   <!-- ====================================================================== -->
   <!-- Root Template                                                          -->
   <!-- ====================================================================== -->

   <!-- override template in preFilterCommon.xsl -->
   <xsl:template match="/">

      <!-- <xtf-converted>
         <xsl:namespace name="xtf" select="'http://cdlib.org/xtf'"/>
         <xsl:call-template name="get-docterms"/>
      </xtf-converted> -->
      
      <!-- for debugging, output temp xml -->
      <xsl:variable name="tempxml">
         <xtf-converted>
            <xsl:namespace name="xtf" select="'http://cdlib.org/xtf'"/>
            <xsl:call-template name="get-docterms"/>
         </xtf-converted>
      </xsl:variable>
      <xsl:copy-of select="$tempxml" />
      <xsl:result-document href="{concat('./xtf/tmp/', $fileID, '.xml')}" method="xml">
         <xsl:copy-of select="$tempxml" />
      </xsl:result-document>

   </xsl:template>

   <!-- ====================================================================== -->
   <!-- Indexing                                                               -->
   <!-- ====================================================================== -->

   <xsl:template name="get-docterms">

      <xsl:variable name="docterms">

         <document-terms>
            <xsl:attribute name="display" select="'true'" />

            <title><xsl:value-of select="$fileID"/></title>
            <fileID><xsl:value-of select="$fileID"/></fileID>
            <xsl:call-template name="get-term-type"/>
            <xsl:call-template name="get-term-identifier"/>
            <xsl:call-template name="get-terms"/>
         </document-terms>

      </xsl:variable>

      <xsl:call-template name="add-fields">
         <xsl:with-param name="display" select="'dynaxml'"/>
         <xsl:with-param name="meta" select="$docterms"/>
      </xsl:call-template>

   </xsl:template>

   <!-- type -->
   <xsl:template name="get-term-type">
      <type xtf:meta="true">term</type>
   </xsl:template>

   <!-- identifier --> 
   <xsl:template name="get-term-identifier">
      <identifier xtf:meta="true" xtf:tokenize="no">
         <xsl:value-of select="$fileID" />
      </identifier>
   </xsl:template>
   
   <!-- terms -->
   <xsl:template name="get-terms">
      <xsl:variable name="docterms" select="//*:documentTerms" />
        
         <docID><xsl:value-of select="$docterms/docId" /></docID>
         <total><xsl:value-of select="$docterms/total" /></total>

         <!-- list of terms -->
         <terms>
            <xsl:for-each select="$docterms/terms/term">

               <term>
                  <xsl:variable name="raw">
                     <xsl:value-of select="./raw" />
                  </xsl:variable>

                  <!-- To boost the relevance of text in a tag, set the BoostValue parameter to a 
                  floating-point number greater than 1.0. To de-emphasis the relevance of a tag's text, 
                  set the BoostValue parameter to a floating-point number between 0.0 and 1.0. -->
                  <xsl:attribute name="xtf:wordboost" select="number($raw)"/>
                  
                  <name><xsl:value-of select="./name" /></name>
                  <raw><xsl:value-of select="$raw" /></raw>
                  <value><xsl:value-of select="./value" /></value>
               </term>
              
            </xsl:for-each>
         </terms>

    </xsl:template>

</xsl:stylesheet>