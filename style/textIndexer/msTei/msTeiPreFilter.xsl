<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:date="http://exslt.org/dates-and-times" 
   xmlns:parse="http://cdlib.org/xtf/parse"
   xmlns:xtf="http://cdlib.org/xtf" 
   xmlns:tei="http://www.tei-c.org/ns/1.0"
   xmlns:cudl="http://cudl.lib.cam.ac.uk/xtf/"
   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
   extension-element-prefixes="date" 
   exclude-result-prefixes="#all">

   <!--
      Copyright (c) 2008, Regents of the University of California
      All rights reserved.
      
      Redistribution and use in source and binary forms, with or without 
      modification, are permitted provided that the following conditions are 
      met:
      
      - Redistributions of source code must retain the above copyright notice, 
      this list of conditions and the following disclaimer.
      - Redistributions in binary form must reproduce the above copyright 
      notice, this list of conditions and the following disclaimer in the 
      documentation and/or other materials provided with the distribution.
      - Neither the name of the University of California nor the names of its
      contributors may be used to endorse or promote products derived from 
      this software without specific prior written permission.
      
      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
      AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
      IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
      ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
      LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
      CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
      SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
      INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
      CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
      ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
      POSSIBILITY OF SUCH DAMAGE.
   -->
   
   <!--comprehensively rejigged at Cambridge University Library to produce xml to be transformed into json
   for Enrich TEI and its cousins-->

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

   <xsl:template match="/">
      <xtf-converted>
         <xsl:namespace name="xtf" select="'http://cdlib.org/xtf'"/>
         <xsl:call-template name="get-meta"/>
      </xtf-converted>
   </xsl:template>

   <!--filename-->
   <xsl:variable name="fileID" select="substring-before(tokenize(document-uri(/), '/')[last()], '.xml')"/>        
   
   <!-- ====================================================================== -->
   <!-- Metadata Indexing                                                      -->
   <!-- ====================================================================== -->

   <xsl:template name="get-meta">

      <!-- extract metadata from the TEI -->
      <xsl:variable name="meta">

         <!--descriptive stuff-->
         <descriptiveMetadata>
            
            <xsl:call-template name="make-dmd-parts"/>
            
         </descriptiveMetadata>
         
         
         <xsl:call-template name="get-numberOfPages"/>
         
         <xsl:call-template name="get-embeddable"/>
         
         <xsl:if test=".//*:note[@type='completeness']">
            <xsl:apply-templates select=".//*:note[@type='completeness']"/>
         </xsl:if>
         
         
         
         <!--structural stuff-->
         <xsl:call-template name="make-pages" />
         <xsl:call-template name="make-logical-structure" />
         
         <xsl:call-template name="make-index-pages" />
         
      </xsl:variable>

      <!-- Add doc kind and sort fields to the data, and output the result. -->
      <xsl:call-template name="add-fields">
         <xsl:with-param name="display" select="'dynaxml'"/>
         <xsl:with-param name="meta" select="$meta"/>
      </xsl:call-template>
   </xsl:template>
   
   <!--*******************Descriptive metadata************************************************************************************-->
   
   <!--This is all the structural stuff which lays out the descriptive metadata parts in the right hierarchy-->
   
   <!--Descriptive metadata is organised into 'parts' - these are not nesting - hierarchy is organised by ids (like METS)-->

   <!--each part has a unique xtf:subDocument attribute to facilitate search indexing against specific parts-->

   <xsl:template name="make-dmd-parts">      
      
      <!--if there are no msParts-->
      <xsl:if test="//*:sourceDesc/*:msDesc/*:msContents/*:msItem">
         <xsl:choose>
            <xsl:when test="count(//*:sourceDesc/*:msDesc/*:msContents/*:msItem) = 1">
               
               <!-- Just one top-level msItem, so merge with doc level -->
               
               <part>
                
                  <xsl:attribute name="xtf:subDocument" select="'ITEM-1'"/>
                  
                  <xsl:call-template name="get-doc-abstract"/>
                  
                  <xsl:call-template name="get-doc-and-item-names"/>
                  
                  <xsl:call-template name="get-doc-subjects"/>
                  <xsl:call-template name="get-doc-events"/>

                  <xsl:call-template name="get-doc-physloc"/>                  
                  <xsl:call-template name="get-doc-thumbnail"/>                  
                  
                  <xsl:call-template name="get-doc-image-rights"/>
                  <xsl:call-template name="get-doc-metadata-rights"/>
                  <xsl:call-template name="get-doc-authority"/>
                  
                  <xsl:call-template name="get-doc-funding"/>
                  
                  <xsl:call-template name="get-doc-physdesc"/> 
                  <xsl:call-template name="get-doc-history"/> 
                  
                  <xsl:call-template name="get-doc-and-item-biblio"/>

                  <xsl:call-template name="get-doc-metadata"/> 
                  
                  <xsl:call-template name="get-collection-memberships"/> 
                  
                  <!--not sure why this is called with a for-each - the above means that there will only ever be one msItem here-->
                  <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msContents/*:msItem[1]" >

                     <xsl:call-template name="get-item-dmdID"/>
                     <xsl:call-template name="get-item-title">
                        <xsl:with-param name="display" select="'false'" />
                     </xsl:call-template>
                     <xsl:call-template name="get-item-alt-titles"/>
                     <xsl:call-template name="get-item-desc-titles"/>
                     <xsl:call-template name="get-item-uniform-title"/>
                  <!--
                     <xsl:call-template name="get-item-names"/>
                     -->
                     <xsl:call-template name="get-item-languages"/>     
                     
                     <xsl:call-template name="get-item-excerpts"/>
                     <xsl:call-template name="get-item-notes"/>
                     <xsl:call-template name="get-item-filiation"/>
                     
                  </xsl:for-each>

               </part>
               
               <!-- Now process any sub-items -->
               <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msContents/*:msItem[1]" >
                  <xsl:apply-templates select="*:msContents/*:msItem|*:msItem" />
               </xsl:for-each>
                  
            </xsl:when>
            <xsl:otherwise>
               
               <!-- Sequence of top-level msItems, so need to introduce additional top-level to represent item as a whole-->
               
               <part>
                  <xsl:attribute name="xtf:subDocument" select="'DOCUMENT'"/>
                  
                  <xsl:call-template name="get-doc-dmdID"/>
                  <xsl:call-template name="get-doc-title"/>
                  <xsl:call-template name="get-doc-alt-titles"/>
                  <xsl:call-template name="get-doc-desc-titles"/>
                  <xsl:call-template name="get-doc-uniform-title"/>
                  <xsl:call-template name="get-doc-abstract"/>
                  
                  <xsl:call-template name="get-doc-names"/>

                  <xsl:call-template name="get-doc-subjects"/>
                  <xsl:call-template name="get-doc-events"/>
                  
                  <xsl:call-template name="get-doc-physloc"/>                  
                  <xsl:call-template name="get-doc-thumbnail"/> 
                  
                  <xsl:call-template name="get-doc-image-rights"/>
                  <xsl:call-template name="get-doc-metadata-rights"/>
                  <xsl:call-template name="get-doc-authority"/>
                  
                  <xsl:call-template name="get-doc-funding"/>
                  
                  <xsl:call-template name="get-doc-physdesc"/>
                  <xsl:call-template name="get-doc-history"/> 
                  
                  <xsl:call-template name="get-doc-biblio"/> 
                  
                  <xsl:call-template name="get-doc-metadata"/> 
               
                  <xsl:call-template name="get-collection-memberships"/> 
               
               </part>
               
               <!-- Now process top-level msItems -->
               <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:msContents/*:msItem" />
                                       
            </xsl:otherwise>
         </xsl:choose>
         
         
      </xsl:if>
      
   </xsl:template>
   
   <!--each msItem is also a part-->
   <xsl:template match="*:msItem">

      <part>
         
         <!--incrementing number to give a unique id-->
         <xsl:variable name="n-tree">         
            <xsl:value-of select="sum((count(ancestor-or-self::*[local-name()='msItem' or local-name()='msPart']), count(preceding::*[local-name()='msItem' or local-name()='msPart'])))" />
         </xsl:variable>
         
         <xsl:attribute name="xtf:subDocument" select="concat('ITEM-', normalize-space($n-tree))"/>
         
         
         <xsl:call-template name="get-item-dmdID"/>

         <xsl:call-template name="get-item-title">
            <xsl:with-param name="display" select="'true'" />
         </xsl:call-template>
         
         <xsl:call-template name="get-item-alt-titles"/>
         <xsl:call-template name="get-item-desc-titles"/>
         <xsl:call-template name="get-item-uniform-title"/>
         <xsl:call-template name="get-item-names"/>
         <xsl:call-template name="get-item-languages"/>
         
         <xsl:call-template name="get-item-excerpts"/>
         <xsl:call-template name="get-item-notes"/>
         
         <xsl:call-template name="get-item-filiation"/>
         
         <xsl:call-template name="get-item-biblio"/>
      
         <xsl:call-template name="get-collection-memberships"/> 
      
      </part>
      
      <!-- Any child items of this item -->
      <xsl:apply-templates select="*:msContents/*:msItem|*:msItem" />
      
   </xsl:template>
   
  
   
   <!--*************************and these are the templates used by the structural templates to fill in descriptive metadata fields-->

   <!--DMDIDs-->
   
   <!--for the whole document-->
   <xsl:template name="get-doc-dmdID">
      
      <ID>
         <xsl:value-of select="'DOCUMENT'"/>
      </ID>
      
      <fileID>
         <xsl:value-of select="$fileID"/>        
      </fileID>
      
      <startPage>1</startPage>
      <!--documents always start on page 1!-->
      <startPageLabel>
         <xsl:value-of select="//*:text/*:body/*:div[not(@type)]//*:pb[1]/@n" />
        
      </startPageLabel>
      
   </xsl:template>
    
   <!--for individual items-->
   <xsl:template name="get-item-dmdID">
      
      <!--incrementing number to give a unique id-->
      <xsl:variable name="n-tree">         
         <xsl:value-of select="sum((count(ancestor-or-self::*[local-name()='msItem' or local-name()='msPart']), count(preceding::*[local-name()='msItem' or local-name()='msPart'])))" />
      </xsl:variable>
      
      <ID>
         <xsl:value-of select="concat('ITEM-', normalize-space($n-tree))"/>
      </ID>
      
      <fileID>
         <xsl:value-of select="$fileID"/>        
      </fileID>
      
      <xsl:variable name="startPageLabel">
         <!--should always be a locus attached to an msItem - but defaults to first page if none present-->
         <xsl:choose>
            <xsl:when test="*:locus/@from">
               <xsl:value-of select="normalize-space(*:locus/@from)" />
               
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="//*:text/*:body/*:div[not(@type)]/*:pb[1]/@n" />
               
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <startPageLabel>
         <xsl:value-of select="$startPageLabel" />
         
      </startPageLabel>
      
      <xsl:variable name="startPage">
         <!-- Ugh must be a neater way -->
         <xsl:for-each select="//*:text/*:body/*:div[not(@type)]//*:pb" >
            <xsl:if test="@n = $startPageLabel">
               <xsl:value-of select="position()" />                                
            </xsl:if>
         </xsl:for-each>
      </xsl:variable>
      
      <startPage>
         <xsl:value-of select="$startPage" />                                
      </startPage>
   
   </xsl:template>
   
     
   <!--TITLES-->
   
   <!--main titles-->
   <!--whole document titles where there are multiple msItems are found in the summary - if not present, defaults to classmark-->
   <xsl:template name="get-doc-title">
      <title>
         <xsl:variable name="title">
            
            <xsl:choose>
               <xsl:when test="//*:sourceDesc/*:msDesc/*:msContents/*:summary//*:title[@type='general']">
                  <xsl:for-each-group select="//*:sourceDesc/*:msDesc/*:msContents/*:summary//*:title[@type='general']" group-by="normalize-space(.)">
                     <xsl:value-of select="normalize-space(.)"/>
                     <xsl:if test="not(position()=last())">
                        <xsl:text>, </xsl:text>
                     </xsl:if>
                  </xsl:for-each-group>
               </xsl:when>
               <xsl:when test="//*:sourceDesc/*:msDesc/*:msContents/*:summary//*:title[not(@type)]">
                  <xsl:for-each-group select="//*:sourceDesc/*:msDesc/*:msContents/*:summary//*:title[not(@type)]" group-by="normalize-space(.)">
                     <xsl:value-of select="normalize-space(.)"/>                                          
                     <xsl:if test="not(position()=last())">
                        <xsl:text>, </xsl:text>
                     </xsl:if>
                  </xsl:for-each-group>
               </xsl:when>
               <xsl:when test="//*:sourceDesc/*:msDesc/*:msIdentifier/*:idno">
                  <xsl:for-each-group select="//*:sourceDesc/*:msDesc/*:msIdentifier/*:idno" group-by="normalize-space(.)">
                     <xsl:value-of select="normalize-space(.)"/>                                          
                     <xsl:if test="not(position()=last())">
                        <xsl:text>, </xsl:text>
                     </xsl:if>
                  </xsl:for-each-group>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>Untitled Document</xsl:text>               
               </xsl:otherwise>
            </xsl:choose>         
         </xsl:variable>
         
         <xsl:attribute name="display" select="'false'" />
                  
         <xsl:attribute name="displayForm" select="$title" />         
         
         <xsl:value-of select="$title" />
         
      </title>
   </xsl:template>
   
   <xsl:template name="get-part-title">
      
      <title>

         <xsl:variable name="title">            
            <xsl:choose>
               <xsl:when test="normalize-space(*:title[not(@type)][1])">
                  <xsl:value-of select="normalize-space(*:title[not(@type)][1])"/>              
               </xsl:when>
               <xsl:when test="normalize-space(*:title[@type='general'][1])">
                  <xsl:value-of select="normalize-space(*:title[@type='general'][1])"/>              
               </xsl:when>
               <xsl:when test="normalize-space(*:title[@type='standard'][1])">
                  <xsl:value-of select="normalize-space(*:title[@type='standard'][1])"/>              
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>Untitled Part</xsl:text>               
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         
         
         <xsl:attribute name="display" select="'true'" />
         
         <xsl:attribute name="displayForm" select="$title" />         
         
         <xsl:value-of select="$title" />
         
      </title>
   </xsl:template>
   
   <xsl:template name="get-item-title">
      <xsl:param name="display" select="'true'" />
      
      <title>

         <xsl:variable name="title">            
            <xsl:choose>
               <xsl:when test="normalize-space(*:title[not(@type)][1])">
                  <xsl:value-of select="normalize-space(*:title[not(@type)][1])"/>              
               </xsl:when>
               <xsl:when test="normalize-space(*:title[@type='general'][1])">
                  <xsl:value-of select="normalize-space(*:title[@type='general'][1])"/>              
               </xsl:when>
               <xsl:when test="normalize-space(*:title[@type='standard'][1])">
                  <xsl:value-of select="normalize-space(*:title[@type='standard'][1])"/>              
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>Untitled Item</xsl:text>               
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         
         <xsl:attribute name="display" select="$display" />
         
         <xsl:attribute name="displayForm" select="$title" />         
         
         <xsl:value-of select="$title" />
         
      </title>
   </xsl:template>   


   <!--alternative titles-->
   <xsl:template name="get-doc-alt-titles">
      
      <xsl:if test="//*:sourceDesc/*:msDesc/*:msContents/*:summary/*:title[@type='alt']">
         
         <alternativeTitles>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msContents/*:summary/*:title[@type='alt']">
               
               <!-- <xsl:if test="not(normalize-space(.) = '')"> -->
               
               <xsl:if test="normalize-space(.)">
                  
                  <alternativeTitle>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:attribute name="displayForm" select="normalize-space(.)" />         
                     
                     <xsl:value-of select="normalize-space(.)"/>
                  </alternativeTitle>             
                  
               </xsl:if>
               
            </xsl:for-each>
            
         </alternativeTitles>
         
      </xsl:if>
      
   </xsl:template>

   <xsl:template name="get-part-alt-titles">
      
      <xsl:if test="*:head/*:title[@type='alt']">
         
         <alternativeTitles>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:for-each select="*:head/*:title[@type='alt']">
               
               <!-- <xsl:if test="not(normalize-space(.) = '')"> -->
                  
               <xsl:if test="normalize-space(.)">
                  
                  <alternativeTitle>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:attribute name="displayForm" select="normalize-space(.)" />         
                     
                     <xsl:value-of select="normalize-space(.)"/>
                  </alternativeTitle>             
                  
               </xsl:if>
               
            </xsl:for-each>
            
         </alternativeTitles>
         
      </xsl:if>
      
   </xsl:template>   
   
   <xsl:template name="get-item-alt-titles">
      
      <xsl:if test="*:title[@type='alt']">
         
         <alternativeTitles>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:for-each select="*:title[@type='alt']">
               
               <xsl:if test="normalize-space(.)">
                  
                  <alternativeTitle>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:attribute name="displayForm" select="normalize-space(.)" />         
                     
                     <xsl:value-of select="normalize-space(.)"/>
                  </alternativeTitle>             
                  
               </xsl:if>
               
            </xsl:for-each>               
         </alternativeTitles>
         
      </xsl:if>
      
   </xsl:template>
   
   <!--descriptive titles-->
   <xsl:template name="get-doc-desc-titles">
      
      <xsl:if test="//*:sourceDesc/*:msDesc/*:msContents/*:summary/*:title[@type='desc']">
         
         <descriptiveTitles>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msContents/*:summary/*:title[@type='desc']">
               
               <!-- <xsl:if test="not(normalize-space(.) = '')"> -->
               
               <xsl:if test="normalize-space(.)">
                  
                  <descriptiveTitle>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:attribute name="displayForm" select="normalize-space(.)" />         
                     
                     <xsl:value-of select="normalize-space(.)"/>
                  </descriptiveTitle>             
                  
               </xsl:if>
               
            </xsl:for-each>
            
         </descriptiveTitles>
         
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template name="get-part-desc-titles">
      
      <xsl:if test="*:head/*:title[@type='desc']">
         
         <descriptiveTitles>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:for-each select="*:head/*:title[@type='desc']">
               
               <!-- <xsl:if test="not(normalize-space(.) = '')"> -->
               
               <xsl:if test="normalize-space(.)">
                  
                  <descriptiveTitle>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:attribute name="displayForm" select="normalize-space(.)" />         
                     
                     <xsl:value-of select="normalize-space(.)"/>
                  </descriptiveTitle>             
                  
               </xsl:if>
               
            </xsl:for-each>
            
         </descriptiveTitles>
         
      </xsl:if>
      
   </xsl:template>   
   
   <xsl:template name="get-item-desc-titles">
      
      <xsl:if test="*:title[@type='desc']">
         
         <descriptiveTitles>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:for-each select="*:title[@type='desc']">
               
               <xsl:if test="normalize-space(.)">
                  
                  <descriptiveTitle>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:attribute name="displayForm" select="normalize-space(.)" />         
                     
                     <xsl:value-of select="normalize-space(.)"/>
                  </descriptiveTitle>             
                  
               </xsl:if>
               
            </xsl:for-each>               
         </descriptiveTitles>
         
      </xsl:if>
      
   </xsl:template>
   
   
   
   <!--uniform title-->
   <xsl:template name="get-doc-uniform-title">
      
      <xsl:variable name="uniformTitle" select="//*:sourceDesc/*:msDesc/*:msContents/*:summary/*:title[@type='uniform'][1]"/>
      
      <xsl:if test="normalize-space($uniformTitle)">
         
         <uniformTitle>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:attribute name="displayForm" select="normalize-space($uniformTitle)" />      
            
            <xsl:value-of select="normalize-space($uniformTitle)"/>
            
         </uniformTitle>
         
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template name="get-part-uniform-title">
      
      <xsl:variable name="uniformTitle" select="*:head/*:title[@type='uniform'][1]"/>
      
      <xsl:if test="normalize-space($uniformTitle)">
         
         <uniformTitle>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:attribute name="displayForm" select="normalize-space($uniformTitle)" />      
            
            <xsl:value-of select="normalize-space($uniformTitle)"/>
            
         </uniformTitle>
         
      </xsl:if>
      
   </xsl:template>
      
   <xsl:template name="get-item-uniform-title">
      
      <xsl:variable name="uniformTitle" select="*:title[@type='uniform'][1]"/>
      
      <xsl:if test="normalize-space($uniformTitle)">
         
         <uniformTitle>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:attribute name="displayForm" select="normalize-space($uniformTitle)" />      
            
            <xsl:value-of select="normalize-space($uniformTitle)"/>
            
         </uniformTitle>
         
      </xsl:if>
      
   </xsl:template>
   
   
   <!--abstracts-->
   
   <xsl:template name="get-doc-abstract">
      
      <xsl:if test="//*:sourceDesc/*:msDesc/*:msContents/*:summary">
         
         <abstract>
            
            <xsl:variable name="abstract">
               <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:msContents/*:summary" mode="html" />
            </xsl:variable>
            
            <xsl:attribute name="display" select="'false'" />
            
            <xsl:attribute name="displayForm" select="normalize-space($abstract)" />         
            
            <!-- <xsl:value-of select="normalize-space($abstract)" /> -->
            <xsl:value-of select="normalize-space(replace($abstract, '&lt;[^&gt;]+&gt;', ''))"/>
            
         </abstract>
         
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template match="*:summary" mode="html">
      
      
      <xsl:choose>
         <xsl:when test=".//*:seg[@type='para']">
            
            
            <xsl:apply-templates mode="html" />
            
         </xsl:when>
         <xsl:otherwise>
      
            <xsl:text>&lt;p style=&apos;text-align: justify;&apos;&gt;</xsl:text>
            <xsl:apply-templates mode="html" />
            <xsl:text>&lt;/p&gt;</xsl:text>
            
            
         </xsl:otherwise>   
         
      </xsl:choose>
      
      
   </xsl:template>

   <!--subjects-->
   <xsl:template name="get-doc-subjects">
      
      <xsl:if test="//*:profileDesc/*:textClass/*:keywords/*:list/*:item">
         
         <subjects>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:for-each select="//*:profileDesc/*:textClass/*:keywords/*:list/*:item"> 
               
               <xsl:if test="normalize-space(.)">
                  
                  <subject>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:attribute name="displayForm" select="normalize-space(.)" />
                     
                     <fullForm>
                        <xsl:value-of select="normalize-space(.)" />
                     </fullForm>
                     
                     <xsl:if test="*:ref/@target">
                        <authority>
                           <xsl:value-of select="normalize-space(id(substring-after(../../@scheme, '#'))/*:bibl/*:ref)"/>
                        </authority>
                        <authorityURI>
                           <xsl:value-of select="normalize-space(id(substring-after(../../@scheme, '#'))/*:bibl/*:ref/@target)"/>
                        </authorityURI>
                        <valueURI>
                           <xsl:value-of select="*:ref/@target" />
                        </valueURI>
                     </xsl:if>
                     
                  </subject>
                  
               </xsl:if>
               
            </xsl:for-each>
         </subjects>
      </xsl:if>
      
   </xsl:template>
   
   
   <!--events-->
   <xsl:template name="get-doc-events">
      
      <xsl:if test="//*:sourceDesc/*:msDesc/*:history/*:origin or exists(//*:sourceDesc/*:msDesc/*:msPart/*:history/*:origin)">
         
         
         <!--creation-->
         <creations>
            
            <xsl:attribute name="display" select="'true'" />
            <!--will there only ever be one of these?-->
            <xsl:for-each select="//*:sourceDesc/*:msDesc/*:history/*:origin">
               <event>
                  
                  <type>creation</type>
                  
                  <xsl:if test="*:origPlace">
                     <places>
                        
                        <xsl:attribute name="display" select="'true'" />
                        
                        <xsl:for-each select="*:origPlace">
                           <place>
                              <xsl:attribute name="display" select="'true'" />
                              
                              <xsl:attribute name="displayForm" select="normalize-space(.)" />
                              <shortForm>
                                 <xsl:value-of select="normalize-space(.)" />                              
                              </shortForm>
                           </place>
                           
                        </xsl:for-each>
                     </places>
                  </xsl:if>
                  
                  <xsl:for-each select="*:date[1]"> <!-- filter by calendar? -->
                     
                     <xsl:choose>
                        <xsl:when test="@from">
                           <dateStart>
                              <xsl:value-of select="@from" />
                           </dateStart>
                        </xsl:when>
                        <xsl:when test="@notBefore">
                           <dateStart>
                              <xsl:value-of select="@notBefore" />
                           </dateStart>
                        </xsl:when>
                        <xsl:when test="@when">
                           <dateStart>
                              <xsl:value-of select="@when" />
                           </dateStart>                        
                        </xsl:when>
                        <xsl:otherwise>                        
                        </xsl:otherwise>
                     </xsl:choose>
                     
                     <xsl:choose>
                        <xsl:when test="@to">
                           <dateEnd>
                              <xsl:value-of select="@to" />
                           </dateEnd>
                        </xsl:when>
                        <xsl:when test="@notAfter">
                           <dateEnd>
                              <xsl:value-of select="@notBefore" />
                           </dateEnd>
                        </xsl:when>
                        <xsl:when test="@when">
                           <dateEnd>
                              <xsl:value-of select="@when" />
                           </dateEnd>                        
                        </xsl:when>
                        <xsl:otherwise>                        
                        </xsl:otherwise>
                     </xsl:choose>
                     
                     <dateDisplay>
                        
                        <xsl:attribute name="display" select="'true'" />
                                                
                        <xsl:attribute name="displayForm" select="normalize-space(.)" />
                        
                        <xsl:value-of select="normalize-space(.)" />
                     </dateDisplay>
                     
                  </xsl:for-each>
               </event>
            </xsl:for-each>
            
            <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msPart/*:history/*:origin">
               <event>
                  
                  <type>creation</type>
                  
                  <xsl:if test="*:origPlace">
                     <places>
                        
                        <xsl:attribute name="display" select="'true'" />
                        
                        <xsl:for-each select="*:origPlace">
                           <place>
                              <xsl:attribute name="display" select="'true'" />
                              
                              <xsl:variable name="place">
                                 <xsl:for-each select="../../../*:altIdentifier/*:idno">
                                    
                                    <xsl:text>&lt;b&gt;</xsl:text>
                                    <xsl:apply-templates mode="html" />
                                    <xsl:text>:</xsl:text>
                                    <xsl:text>&lt;/b&gt;</xsl:text>
                                    <xsl:text> </xsl:text>
                                    
                                 </xsl:for-each>

                                 <xsl:value-of select="normalize-space(.)"/>
                                 
                              </xsl:variable>
                              
                              <xsl:attribute name="displayForm" select="normalize-space($place)" />

                              <shortForm>
                                 <xsl:value-of select="normalize-space(.)" />                              
                              </shortForm>
                           </place>
                           
                        </xsl:for-each>
                     </places>
                  </xsl:if>
                  
                  <xsl:for-each select="*:date[1]"> <!-- filter by calendar? -->
                     
                     <xsl:choose>
                        <xsl:when test="@from">
                           <dateStart>
                              <xsl:value-of select="@from" />
                           </dateStart>
                        </xsl:when>
                        <xsl:when test="@notBefore">
                           <dateStart>
                              <xsl:value-of select="@notBefore" />
                           </dateStart>
                        </xsl:when>
                        <xsl:when test="@when">
                           <dateStart>
                              <xsl:value-of select="@when" />
                           </dateStart>                        
                        </xsl:when>
                        <xsl:otherwise>                        
                        </xsl:otherwise>
                     </xsl:choose>
                     
                     <xsl:choose>
                        <xsl:when test="@to">
                           <dateEnd>
                              <xsl:value-of select="@to" />
                           </dateEnd>
                        </xsl:when>
                        <xsl:when test="@notAfter">
                           <dateEnd>
                              <xsl:value-of select="@notBefore" />
                           </dateEnd>
                        </xsl:when>
                        <xsl:when test="@when">
                           <dateEnd>
                              <xsl:value-of select="@when" />
                           </dateEnd>                        
                        </xsl:when>
                        <xsl:otherwise>                        
                        </xsl:otherwise>
                     </xsl:choose>
                     
                     <dateDisplay>
                        
                        <xsl:attribute name="display" select="'true'" />
                        
                        <xsl:variable name="date">
                           <xsl:for-each select="../../../*:altIdentifier/*:idno">
                              
                              <xsl:text>&lt;b&gt;</xsl:text>
                              <xsl:apply-templates mode="html" />
                              <xsl:text>:</xsl:text>
                              <xsl:text>&lt;/b&gt;</xsl:text>
                              <xsl:text> </xsl:text>
                              
                           </xsl:for-each>
                           
                           <xsl:value-of select="normalize-space(.)"/>
                           
                        </xsl:variable>
                        
                        <xsl:attribute name="displayForm" select="normalize-space($date)" />
                        
                        <xsl:value-of select="normalize-space(.)" />
                     </dateDisplay>
                     
                  </xsl:for-each>
               </event>
            </xsl:for-each>
            
         </creations>
      </xsl:if>
      
      
      
      <!--acquisition-->
      <xsl:if test="//*:sourceDesc/*:msDesc/*:history/*:acquisition">
         
         <acquisitions>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:for-each select="//*:sourceDesc/*:msDesc/*:history/*:acquisition">
               <event>
                  
                  <type>acquisition</type>
                                    
                  <xsl:for-each select="*:date[1]">
                     
                     <xsl:choose>
                        <xsl:when test="@from">
                           <dateStart>
                              <xsl:value-of select="@from" />
                           </dateStart>
                        </xsl:when>
                        <xsl:when test="@notBefore">
                           <dateStart>
                              <xsl:value-of select="@notBefore" />
                           </dateStart>
                        </xsl:when>
                        <xsl:when test="@when">
                           <dateStart>
                              <xsl:value-of select="@when" />
                           </dateStart>                        
                        </xsl:when>
                        <xsl:otherwise>                        
                        </xsl:otherwise>
                     </xsl:choose>
                     
                     <xsl:choose>
                        <xsl:when test="@to">
                           <dateEnd>
                              <xsl:value-of select="@to" />
                           </dateEnd>
                        </xsl:when>
                        <xsl:when test="@notAfter">
                           <dateEnd>
                              <xsl:value-of select="@notBefore" />
                           </dateEnd>
                        </xsl:when>
                        <xsl:when test="@when">
                           <dateEnd>
                              <xsl:value-of select="@when" />
                           </dateEnd>                        
                        </xsl:when>
                        <xsl:otherwise>                        
                        </xsl:otherwise>
                     </xsl:choose>
                     
                     <dateDisplay>
                        
                        <xsl:attribute name="display" select="'true'" />
                        
                        <xsl:attribute name="displayForm" select="normalize-space(.)" />
                        
                        <xsl:value-of select="normalize-space(.)" />
                     </dateDisplay>
                     
                  </xsl:for-each>
               </event>
            </xsl:for-each>
            
         </acquisitions>
      </xsl:if>
   
   </xsl:template>
   
   <!--physical location and classmark-->
   <xsl:template name="get-doc-physloc">
      
      <physicalLocation>
         
         <xsl:attribute name="display" select="'true'" />
         
         <xsl:attribute name="displayForm" select="normalize-space(//*:sourceDesc/*:msDesc/*:msIdentifier/*:repository)" />
         
         <xsl:value-of select="normalize-space(//*:sourceDesc/*:msDesc/*:msIdentifier/*:repository)" />
      
      </physicalLocation>
      
      <shelfLocator>
         
         <xsl:attribute name="display" select="'true'" />
         
         <xsl:attribute name="displayForm" select="normalize-space(//*:sourceDesc/*:msDesc/*:msIdentifier/*:idno)" />
         
         <xsl:value-of select="normalize-space(//*:sourceDesc/*:msDesc/*:msIdentifier/*:idno)" />
         
      </shelfLocator>
      
   </xsl:template>
   
   <!--thumbnail for document-->
   <xsl:template name="get-doc-thumbnail">
      
      
         <xsl:variable name="graphic" select="//*:graphic[@decls='#document-thumbnail']"/>
         
         <xsl:if test="$graphic">
            
            <thumbnailUrl>            
               
               <xsl:variable name="imageUrl" select="normalize-space($graphic/@url)"/>
               <xsl:variable name="imageUrlShort" select="replace($imageUrl, 'http://cudl.lib.cam.ac.uk/(newton|content)','/content')"/>
               
               <xsl:value-of select="normalize-space($imageUrlShort)"/>
            </thumbnailUrl>
            
            <thumbnailOrientation>
               <xsl:choose>
                  <xsl:when test="$graphic/@rend = 'portrait'">
                     <xsl:value-of select="'portrait'"/>
                  </xsl:when>
                  <xsl:when test="$graphic/@rend = 'landscape'">
                     <xsl:value-of select="'landscape'"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="'portrait'"/>                  
                  </xsl:otherwise>
               </xsl:choose>
            </thumbnailOrientation>
            
         </xsl:if>
               
   </xsl:template>
   
   
   
   <!-- rights for images and metadata-->
   <xsl:template name="get-doc-image-rights">

      <displayImageRights>
         <xsl:value-of select="normalize-space(//*:publicationStmt/*:availability[@xml:id='displayImageRights'])" />
      </displayImageRights>
          
      <downloadImageRights>
         <xsl:value-of select="normalize-space(//*:publicationStmt/*:availability[@xml:id='downloadImageRights'])" />
      </downloadImageRights>
      
      <imageReproPageURL>
         <xsl:value-of select="cudl:get-imageReproPageURL(normalize-space(//*:sourceDesc/*:msDesc/*:msIdentifier/*:repository))"/>
      </imageReproPageURL>
            
   </xsl:template>
   
   <xsl:template name="get-doc-metadata-rights">
      
      <metadataRights>
         <xsl:value-of select="normalize-space(//*:publicationStmt/*:availability[@xml:id='metadataRights'])" />
      </metadataRights>
      
   </xsl:template>
   
   <!--authority-->
   <xsl:template name="get-doc-authority">
      
      <docAuthority>
         <xsl:apply-templates select="//*:publicationStmt/*:authority" mode="html"/>
         <!--<xsl:value-of select="normalize-space(//*:publicationStmt/*:authority)" />-->
      </docAuthority>
      
   </xsl:template>
   
   <xsl:template match="*:authority" mode="html">
      <xsl:apply-templates mode="html"/>
   </xsl:template>
   
   <!--completeness-->
   
   <xsl:template match="*:note[@type='completeness']">
      <completeness>
         
         <xsl:value-of select="normalize-space(.)"/>
      </completeness>
   </xsl:template>
   
   <!--funding-->
   <xsl:template name="get-doc-funding">
      
      <fundings>
         
         <xsl:variable name="funding">
            <xsl:apply-templates select="//*:titleStmt/*:funder" mode="html"/>
         </xsl:variable>
         
         <xsl:attribute name="display" select="'true'" />
         <funding>
            <xsl:attribute name="display" select="'true'" />
            <xsl:attribute name="displayForm" select="normalize-space($funding)"/>
         <xsl:value-of select="normalize-space($funding)" />
         </funding>
      </fundings>
      
   </xsl:template>
   
   <!--physical description--> 
   <xsl:template name="get-doc-physdesc">

      <xsl:if test="exists(//*:sourceDesc/*:msDesc/*:physDesc/*:p|//*:sourceDesc/*:msDesc/*:physDesc/*:list) or exists(//*:sourceDesc/*:msDesc/*:msPart/*:physDesc/*:p|//*:sourceDesc/*:msDesc/*:msPart/*:physDesc/*:list)">
         
         <physdesc>
            
            <xsl:attribute name="display" select="'true'" />
         
            <xsl:variable name="physdesc">
               <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:physDesc/*:p|//*:sourceDesc/*:msDesc/*:physDesc/*:list" mode="html"/>
               
               <xsl:if test="exists(//*:sourceDesc/*:msDesc/*:msPart)">
                  
                  <xsl:text>&lt;div style=&apos;list-style-type: disc;&apos;&gt;</xsl:text>
                  
                  <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msPart">
                     
                     <xsl:if test="exists(*:physDesc/*:p|*:physDesc/*:list)">
                        
                        <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;&gt;</xsl:text>
                        
                        <xsl:for-each select="*:altIdentifier/*:idno">
                           
                           <!-- <xsl:text>&lt;p&gt;</xsl:text> -->
                           <xsl:text>&lt;b&gt;</xsl:text>
                           <xsl:apply-templates mode="html" />
                           <xsl:text>:</xsl:text>
                           <xsl:text>&lt;/b&gt;</xsl:text>
                           <!-- <xsl:text>&lt;/p&gt;</xsl:text> -->
                           <xsl:text>&lt;br /&gt;</xsl:text>
                           
                        </xsl:for-each>                  
                                                
                        <xsl:apply-templates select="*:physDesc/*:p|*:physDesc/*:list" mode="html" />
                        
                        <xsl:text>&lt;/div&gt;</xsl:text>
                        
                     </xsl:if>
                     
                  </xsl:for-each>
                  
                  <xsl:text>&lt;/div&gt;</xsl:text>
                                   
               </xsl:if>
               
            </xsl:variable>
            
            <xsl:attribute name="displayForm" select="normalize-space($physdesc)" />
            
            <!-- <xsl:value-of select="normalize-space($physdesc)" /> -->
            <xsl:value-of select="normalize-space(replace($physdesc, '&lt;[^&gt;]+&gt;', ''))"/>
         
         </physdesc>
         
      </xsl:if>
      
      <xsl:if test="normalize-space(//*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/@form) or exists(//*:sourceDesc/*:msDesc/*:msPart/*:physDesc/*:objectDesc/@form)">
         
         <form>

            <xsl:attribute name="display" select="'true'" />
            
            <xsl:variable name="form">
               <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/@form" mode="html" />

               
            </xsl:variable>
            
            <xsl:attribute name="displayForm" select="normalize-space($form)" />
            
            <xsl:value-of select="normalize-space(replace($form, '&lt;[^&gt;]+&gt;', ''))"/>
            
         </form>
         
      </xsl:if>
      
      <xsl:if test="normalize-space(//*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/*:supportDesc/*:support) or exists(//*:sourceDesc/*:msDesc/*:msPart/*:physDesc/*:objectDesc/*:supportDesc/*:support)">
         
         <material>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:variable name="material">
               <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/*:supportDesc/*:support" mode="html"/>
 
               <xsl:if test="exists(//*:sourceDesc/*:msDesc/*:msPart)">
                  
                  <xsl:text>&lt;div style=&apos;list-style-type: disc;&apos;&gt;</xsl:text>
                  
                  <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msPart">
   
                     <xsl:if test="normalize-space(*:physDesc/*:objectDesc/*:supportDesc/*:support)">
                        
                        <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;&gt;</xsl:text>
                        
                        <xsl:for-each select="*:altIdentifier/*:idno">
                           
                           <!-- <xsl:text> </xsl:text> -->
                           <xsl:text>&lt;b&gt;</xsl:text>
                           <xsl:apply-templates mode="html" />
                           <xsl:text>:</xsl:text>
                           <xsl:text>&lt;/b&gt;</xsl:text>
                           <xsl:text> </xsl:text>
                           
                        </xsl:for-each>                  
                        
                        <xsl:apply-templates select="*:physDesc/*:objectDesc/*:supportDesc/*:support" mode="html" />
                     
                        <xsl:text>&lt;/div&gt;</xsl:text>
                     
                     </xsl:if>
                     
                  </xsl:for-each>

                  <xsl:text>&lt;/div&gt;</xsl:text>
               
               </xsl:if>
               
            </xsl:variable>
            
            <xsl:attribute name="displayForm" select="normalize-space($material)" />
            
            <!-- <xsl:value-of select="normalize-space($material)" /> -->
            <xsl:value-of select="normalize-space(replace($material, '&lt;[^&gt;]+&gt;', ''))"/>
                     
         </material>
         
      </xsl:if>
      
      <xsl:if test="normalize-space(//*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/*:supportDesc/*:extent) or exists(//*:sourceDesc/*:msDesc/*:msPart/*:physDesc/*:objectDesc/*:supportDesc/*:extent)">
         
         <extent>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:variable name="extent">
               <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/*:supportDesc/*:extent" mode="html"/>
               
               <xsl:if test="exists(//*:sourceDesc/*:msDesc/*:msPart)">
                  
                  <xsl:text>&lt;div style=&apos;list-style-type: disc;&apos;&gt;</xsl:text>
                  
                  <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msPart">
                  
                     <xsl:if test="normalize-space(*:physDesc/*:objectDesc/*:supportDesc/*:extent)">
                        
                        <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;&gt;</xsl:text>
                        
                        <xsl:for-each select="*:altIdentifier/*:idno">
                        
                           <!-- <xsl:text>&lt;p&gt;</xsl:text> -->
                           <xsl:text>&lt;b&gt;</xsl:text>
                           <xsl:apply-templates mode="html" />
                           <xsl:text>:</xsl:text>
                           <xsl:text>&lt;/b&gt;</xsl:text>
                           <!-- <xsl:text>&lt;/p&gt;</xsl:text> -->
                           <xsl:text> </xsl:text>
                           
                        </xsl:for-each>                  
                        
                        <xsl:apply-templates select="*:physDesc/*:objectDesc/*:supportDesc/*:extent" mode="html" />
                     
                        <xsl:text>&lt;/div&gt;</xsl:text>
                        
                     </xsl:if>
                     
                  </xsl:for-each>
                  
                  <xsl:text>&lt;/div&gt;</xsl:text>
              </xsl:if>
                  
            </xsl:variable>
            
            <xsl:attribute name="displayForm" select="normalize-space($extent)" />
            
            <!-- <xsl:value-of select="normalize-space($extent)" /> -->
            <xsl:value-of select="normalize-space(replace($extent, '&lt;[^&gt;]+&gt;', ''))"/>
            
         </extent>
         
      </xsl:if>
      
      <xsl:if test="//*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/*:supportDesc/*:foliation or exists(//*:sourceDesc/*:msDesc/*:msPart/*:physDesc/*:objectDesc/*:supportDesc/*:foliation)">
                  
         <foliation>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:variable name="foliation">
               <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/*:supportDesc/*:foliation" mode="html"/>
               
               <xsl:if test="exists(//*:sourceDesc/*:msDesc/*:msPart)">
                  
                  <xsl:text>&lt;div style=&apos;list-style-type: disc;&apos;&gt;</xsl:text>
                  
                  <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msPart">

                     <xsl:if test="*:physDesc/*:objectDesc/*:supportDesc/*:foliation">
                        
                        <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;&gt;</xsl:text>
                        
                        <xsl:for-each select="*:altIdentifier/*:idno">
                        
                           <!-- <xsl:text>&lt;p&gt;</xsl:text> -->
                           <xsl:text>&lt;b&gt;</xsl:text>
                           <xsl:apply-templates mode="html" />
                           <xsl:text>:</xsl:text>
                           <xsl:text>&lt;/b&gt;</xsl:text>
                           <!-- <xsl:text>&lt;/p&gt;</xsl:text> -->
                           <xsl:text>&lt;br /&gt;</xsl:text>
                           
                        </xsl:for-each>                  
                        
                        <xsl:apply-templates select="*:physDesc/*:objectDesc/*:supportDesc/*:foliation" mode="html" />
                     
                        <xsl:text>&lt;/div&gt;</xsl:text>
                     
                     </xsl:if>
                     
                  </xsl:for-each>
            
                  <xsl:text>&lt;/div&gt;</xsl:text>
                  
               </xsl:if>
               
            </xsl:variable>
            
            <xsl:attribute name="displayForm" select="normalize-space($foliation)" />
            <!-- <xsl:value-of select="normalize-space($foliation)" /> -->
            <xsl:value-of select="normalize-space(replace($foliation, '&lt;[^&gt;]+&gt;', ''))"/>
            
         </foliation>
         
      </xsl:if>
      
      
      <xsl:if test="//*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/*:supportDesc/*:collation or exists(//*:sourceDesc/*:msDesc/*:msPart/*:physDesc/*:objectDesc/*:supportDesc/*:collation)">
         
         <collation>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:variable name="collation">
               <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/*:supportDesc/*:collation" mode="html"/>
               
               <xsl:if test="exists(//*:sourceDesc/*:msDesc/*:msPart)">
                  
                  <xsl:text>&lt;div style=&apos;list-style-type: disc;&apos;&gt;</xsl:text>
                  
                  <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msPart">
                     
                     <xsl:if test="*:physDesc/*:objectDesc/*:supportDesc/*:collation">
                        
                        <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;&gt;</xsl:text>
                        
                        <xsl:for-each select="*:altIdentifier/*:idno">
                           
                           <!-- <xsl:text>&lt;p&gt;</xsl:text> -->
                           <xsl:text>&lt;b&gt;</xsl:text>
                           <xsl:apply-templates mode="html" />
                           <xsl:text>:</xsl:text>
                           <xsl:text>&lt;/b&gt;</xsl:text>
                           <!-- <xsl:text>&lt;/p&gt;</xsl:text> -->
                           <xsl:text>&lt;br /&gt;</xsl:text>
                           
                        </xsl:for-each>                  
                        
                        <xsl:apply-templates select="*:physDesc/*:objectDesc/*:supportDesc/*:collation" mode="html" />
                        
                        <xsl:text>&lt;/div&gt;</xsl:text>
                        
                     </xsl:if>
                     
                  </xsl:for-each>
                  
                  <xsl:text>&lt;/div&gt;</xsl:text>
                  
               </xsl:if>
               
            </xsl:variable>
            
            <xsl:attribute name="displayForm" select="normalize-space($collation)" />
            <xsl:value-of select="normalize-space(replace($collation, '&lt;[^&gt;]+&gt;', ''))"/>
            
         </collation>
         
      </xsl:if>
      
      
      <xsl:if test="normalize-space(//*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/*:supportDesc/*:condition) or exists(//*:sourceDesc/*:msDesc/*:msPart/*:physDesc/*:objectDesc/*:supportDesc/*:condition)">
         
         <conditions>
            
            <xsl:attribute name="display" select="'true'" />
            
            <condition>
               
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:variable name="condition">
                  <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/*:supportDesc/*:condition" mode="html"/>
                  
                  <xsl:if test="exists(//*:sourceDesc/*:msDesc/*:msPart)">
                     
                     <xsl:text>&lt;div style=&apos;list-style-type: disc;&apos;&gt;</xsl:text>
                     
                     <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msPart">
   
                        <xsl:if test="normalize-space(*:physDesc/*:objectDesc/*:supportDesc/*:condition)">
                           
                           <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;&gt;</xsl:text>
                           
                           <xsl:for-each select="*:altIdentifier/*:idno">
                           
                              <!-- <xsl:text>&lt;p&gt;</xsl:text> -->
                              <xsl:text>&lt;b&gt;</xsl:text>
                              <xsl:apply-templates mode="html" />
                              <xsl:text>:</xsl:text>
                              <xsl:text>&lt;/b&gt;</xsl:text>
                              <!-- <xsl:text>&lt;/p&gt;</xsl:text> -->
                              <xsl:text>&lt;br /&gt;</xsl:text>
                              
                           </xsl:for-each>                  
                           
                           <xsl:apply-templates select="*:physDesc/*:objectDesc/*:supportDesc/*:condition" mode="html" />
                        
                           <xsl:text>&lt;/div&gt;</xsl:text>
                           
                        </xsl:if>
                        
                     </xsl:for-each>
                     
                     <xsl:text>&lt;/div&gt;</xsl:text>
                     
                 </xsl:if>
               </xsl:variable>
            
               <xsl:attribute name="displayForm" select="normalize-space($condition)" />
            
               <!-- <xsl:value-of select="normalize-space($condition)" /> -->
               <xsl:value-of select="normalize-space(replace($condition, '&lt;[^&gt;]+&gt;', ''))"/>
               
            </condition>
            
         </conditions>
         
      </xsl:if>
      
      <xsl:if test="//*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/*:layoutDesc or exists(//*:sourceDesc/*:msDesc/*:msPart/*:physDesc/*:objectDesc/*:layoutDesc)">
         
         <layouts>

            <xsl:attribute name="display" select="'true'" />
            
            <layout>
               
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:variable name="layout">
                  <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/*:layoutDesc" mode="html"/>
                  
                  <xsl:if test="exists(//*:sourceDesc/*:msDesc/*:msPart)">
                     
                     <xsl:text>&lt;div style=&apos;list-style-type: disc;&apos;&gt;</xsl:text>
                     
                     <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msPart">
                     
                        <xsl:if test="*:physDesc/*:objectDesc/*:layoutDesc">
                           
                           <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;&gt;</xsl:text>
                           
                           <xsl:for-each select="*:altIdentifier/*:idno">
                           
                              <!-- <xsl:text>&lt;p&gt;</xsl:text> -->
                              <xsl:text>&lt;b&gt;</xsl:text>
                              <xsl:apply-templates mode="html" />
                              <xsl:text>:</xsl:text>
                              <xsl:text>&lt;/b&gt;</xsl:text>
                              <!-- <xsl:text>&lt;/p&gt;</xsl:text> -->
                              <xsl:text>&lt;br /&gt;</xsl:text>
                              
                           </xsl:for-each>                  
                           
                           <xsl:apply-templates select="*:physDesc/*:objectDesc/*:layoutDesc" mode="html" />
                           
                           <xsl:text>&lt;/div&gt;</xsl:text>
                           
                        </xsl:if>
                        
                     </xsl:for-each>
               
                     <xsl:text>&lt;/div&gt;</xsl:text>
                     
                  </xsl:if>
                  
               </xsl:variable>
               
               <xsl:attribute name="displayForm" select="normalize-space($layout)" />
               
               <!-- <xsl:value-of select="normalize-space($layout)" /> -->
               <xsl:value-of select="normalize-space(replace($layout, '&lt;[^&gt;]+&gt;', ''))"/>
               
            </layout>
            
         </layouts>         
         
      </xsl:if>
   
      <xsl:if test="//*:sourceDesc/*:msDesc/*:physDesc/*:handDesc or exists(//*:sourceDesc/*:msDesc/*:msPart/*:physDesc/*:handDesc)">
         
         <scripts>
            
            <xsl:attribute name="display" select="'true'" />
            
            <script>
               
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:variable name="script">
                  <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:physDesc/*:handDesc" mode="html"/>

                  <xsl:if test="exists(//*:sourceDesc/*:msDesc/*:msPart)">
                     
                     <xsl:text>&lt;div style=&apos;list-style-type: disc;&apos;&gt;</xsl:text>
                     
                     <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msPart">
                     
                        <xsl:if test="*:physDesc/*:handDesc">
                           
                           <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;&gt;</xsl:text>
                           
                           <xsl:for-each select="*:altIdentifier/*:idno">
                              
                              <!-- <xsl:text>&lt;p&gt;</xsl:text> -->
                              <xsl:text>&lt;b&gt;</xsl:text>
                              <xsl:apply-templates mode="html" />
                              <xsl:text>:</xsl:text>
                              <xsl:text>&lt;/b&gt;</xsl:text>
                              <!-- <xsl:text>&lt;/p&gt;</xsl:text> -->
                              <xsl:text>&lt;br /&gt;</xsl:text>
                              
                           </xsl:for-each>                  
                           
                           <xsl:apply-templates select="*:physDesc/*:handDesc" mode="html" />
                        
                           <xsl:text>&lt;/div&gt;</xsl:text>
                           
                        </xsl:if>
                        
                     </xsl:for-each>
                     
                     <xsl:text>&lt;/div&gt;</xsl:text>
                     
                  </xsl:if>
                  
               </xsl:variable>
            
               <xsl:attribute name="displayForm" select="normalize-space($script)" />
               
               <!-- <xsl:value-of select="normalize-space($script)" /> -->
               <xsl:value-of select="normalize-space(replace($script, '&lt;[^&gt;]+&gt;', ''))"/>
               
            </script>
                        
         </scripts>
         
      </xsl:if>
      
      <xsl:if test="//*:sourceDesc/*:msDesc/*:physDesc/*:decoDesc or exists(//*:sourceDesc/*:msDesc/*:msPart/*:physDesc/*:decoDesc)">
         
         <decorations>
            
            <xsl:attribute name="display" select="'true'" />

            <decoration>

               <xsl:attribute name="display" select="'true'" />
               
               <xsl:variable name="decoration">
                  <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:physDesc/*:decoDesc" mode="html"/>
                  
                  <xsl:if test="exists(//*:sourceDesc/*:msDesc/*:msPart)">
                     
                     <xsl:text>&lt;div style=&apos;list-style-type: disc;&apos;&gt;</xsl:text>
                     
                     <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msPart">
                     
                        <xsl:if test="*:physDesc/*:decoDesc">
                           
                           <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;&gt;</xsl:text>
                           
                           <xsl:for-each select="*:altIdentifier/*:idno">
                           
                              <!-- <xsl:text>&lt;p&gt;</xsl:text> -->
                              <xsl:text>&lt;b&gt;</xsl:text>
                              <xsl:apply-templates mode="html" />
                              <xsl:text>:</xsl:text>
                              <xsl:text>&lt;/b&gt;</xsl:text>
                              <!-- <xsl:text>&lt;/p&gt;</xsl:text> -->
                              <xsl:text>&lt;br /&gt;</xsl:text>
                              
                           </xsl:for-each>                  
                           
                           <xsl:apply-templates select="*:physDesc/*:decoDesc" mode="html" />
                           
                           <xsl:text>&lt;/div&gt;</xsl:text>
                           
                        </xsl:if>
                        
                     </xsl:for-each>
                     
                     <xsl:text>&lt;/div&gt;</xsl:text>
                     
                  </xsl:if>
                  
               </xsl:variable>
            
               <xsl:attribute name="displayForm" select="normalize-space($decoration)" />
               
               <!-- <xsl:value-of select="normalize-space($decoration)" /> -->
               <xsl:value-of select="normalize-space(replace($decoration, '&lt;[^&gt;]+&gt;', ''))"/>
               
            </decoration>
                        
         </decorations>
         
      </xsl:if>
   
      <xsl:if test="//*:sourceDesc/*:msDesc/*:physDesc/*:additions or exists(//*:sourceDesc/*:msDesc/*:msPart/*:physDesc/*:additions)">
         
         <additions>
            
            <xsl:attribute name="display" select="'true'" />
            
            <addition>

               <xsl:attribute name="display" select="'true'" />
               
               <xsl:variable name="addition">               
                  <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:physDesc/*:additions" mode="html"/>
                  
                  <xsl:if test="exists(//*:sourceDesc/*:msDesc/*:msPart)">
                     
                     <xsl:text>&lt;div style=&apos;list-style-type: disc;&apos;&gt;</xsl:text>
                     
                     <xsl:for-each select="//*:sourceDesc/*:msDesc/*:msPart">
                        
                        <xsl:if test="*:physDesc/*:additions">
                           
                           <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;&gt;</xsl:text>
                           
                           <xsl:for-each select="*:altIdentifier/*:idno">
                              
                              <!-- <xsl:text>&lt;p&gt;</xsl:text> -->
                              <xsl:text>&lt;b&gt;</xsl:text>
                              <xsl:apply-templates mode="html" />
                              <xsl:text>:</xsl:text>
                              <xsl:text>&lt;/b&gt;</xsl:text>
                              <!-- <xsl:text>&lt;/p&gt;</xsl:text> -->
                              <xsl:text>&lt;br /&gt;</xsl:text>
                              
                           </xsl:for-each>                  
                           
                           <xsl:apply-templates select="*:physDesc/*:additions" mode="html" />
                           
                           <xsl:text>&lt;/div&gt;</xsl:text>
                           
                        </xsl:if>
                        
                     </xsl:for-each>
                     
                     <xsl:text>&lt;/div&gt;</xsl:text>
                     
                  </xsl:if>
                  
               </xsl:variable>
            
               <xsl:attribute name="displayForm" select="normalize-space($addition)" />
               
               <!-- <xsl:value-of select="normalize-space($addition)" /> -->            
               <xsl:value-of select="normalize-space(replace($addition, '&lt;[^&gt;]+&gt;', ''))"/>
               
            </addition>
            
         </additions>
         
      </xsl:if>
   
      <xsl:if test="//*:sourceDesc/*:msDesc/*:physDesc/*:bindingDesc">
         
         <bindings>
            
            <xsl:attribute name="display" select="'true'" />
            
            <binding>
               
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:variable name="binding">               
                  <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:physDesc/*:bindingDesc" mode="html"/>
               </xsl:variable>
            
               <xsl:attribute name="displayForm" select="normalize-space($binding)" />
               
               <!-- <xsl:value-of select="normalize-space($binding)" /> -->            
               <xsl:value-of select="normalize-space(replace($binding, '&lt;[^&gt;]+&gt;', ''))"/>
               
            </binding>
                        
         </bindings>
         
      </xsl:if>
   
   </xsl:template>
   
   <!--physical description processing templates-->
   <xsl:template match="*:objectDesc/@form" mode="html">
      
      
      <xsl:value-of select="concat(upper-case(substring(., 1, 1)), substring(., 2))"></xsl:value-of>
      <!--<xsl:value-of select="normalize-space(.)" />-->
      <!--<xsl:text>.</xsl:text>-->
      
   </xsl:template>
   
   <xsl:template match="*:supportDesc/*:support" mode="html">
   
      <xsl:apply-templates mode="html" />
      
   </xsl:template>
   
   <xsl:template match="*:supportDesc/*:extent" mode="html">
      
      <xsl:apply-templates mode="html" />
      
   </xsl:template>
   
   <xsl:template match="*:supportDesc/*:foliation" mode="html">
                  
      <xsl:text>&lt;p&gt;</xsl:text>
            
      <xsl:if test="@n">
         <xsl:value-of select="@n" />
         <xsl:text>. </xsl:text>
      </xsl:if>
            
      <xsl:if test="@type">
         <xsl:value-of select="cudl:first-upper-case(@type)" />
         <xsl:text>: </xsl:text>
      </xsl:if>

      <xsl:apply-templates mode="html" />
            
      <xsl:text>&lt;/p&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:supportDesc/*:condition" mode="html">

      <xsl:apply-templates mode="html" />
      
   </xsl:template>
   
   <xsl:template match="*:dimensions" mode="html">
      
<!--      <xsl:text>&lt;br /&gt;</xsl:text> -->
      
      <xsl:if test="@subtype">
         <xsl:text>&lt;b&gt;</xsl:text>
         <xsl:value-of select="cudl:first-upper-case(translate(@subtype, '_', ' '))" />
         <xsl:text>:</xsl:text>
         <xsl:text>&lt;/b&gt;</xsl:text>
         <xsl:text> </xsl:text>
      </xsl:if>
      
      <xsl:text> </xsl:text>
      <xsl:value-of select="cudl:first-upper-case(@type)" />
      <xsl:text> </xsl:text>
      <xsl:for-each select="*">
         
         <xsl:choose>
            <xsl:when test="local-name(.) = 'dim'">
               <xsl:value-of select="@type" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="local-name(.)" />
            </xsl:otherwise>
         </xsl:choose>
         <xsl:text>: </xsl:text>
         
         <xsl:choose>
            <xsl:when test="normalize-space(.)">
               <xsl:value-of select="." />
            </xsl:when>
            <xsl:when test="normalize-space(@quantity)">
               <xsl:value-of select="@quantity" />
            </xsl:when>
            <xsl:otherwise>
               <!-- shouldn't happen? -->
            </xsl:otherwise>   
         </xsl:choose>
         
         <xsl:if test="../@unit">
            <xsl:text> </xsl:text>
            <xsl:value-of select="../@unit" />
         </xsl:if>
         
         <xsl:if test="not(position()=last())">
            <xsl:text>, </xsl:text>
         </xsl:if>
         
      </xsl:for-each>
   
      <xsl:text>. </xsl:text>
      
      
   </xsl:template>
   
   <xsl:template match="*:layoutDesc" mode="html">
      
      <xsl:apply-templates mode="html" />            
      
   </xsl:template>
   
   <xsl:template match="*:layout" mode="html">
                 
      <xsl:apply-templates mode="html" />
    
   </xsl:template>
   
   <xsl:template match="*:commentaryForm" mode="html">
      
      <xsl:text>&lt;div&gt;</xsl:text>
      <xsl:text>&lt;b&gt;Commentary form:&lt;/b&gt; </xsl:text>
      <xsl:value-of select="@type"/>
      <xsl:text>. </xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:stringHole" mode="html">
      
      
      <xsl:apply-templates mode="html" />
      
   </xsl:template>
   
   <xsl:template match="*:handDesc" mode="html">
          
      <xsl:text>&lt;div style=&apos;list-style-type: disc;&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:handNote" mode="html">
      
     
      <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>         
      
   </xsl:template>
   
   <xsl:template match="*:decoDesc" mode="html">
                  
      <xsl:apply-templates mode="html" />
      
   </xsl:template>
   
   <xsl:template match="*:decoNote" mode="html">
  
      <xsl:apply-templates mode="html" />

      <xsl:if test="exists(following-sibling::*)">
            <xsl:text>&lt;br /&gt;</xsl:text>         
      </xsl:if>           
      
   </xsl:template>
   
   <xsl:template match="*:additions" mode="html">
            
      <xsl:apply-templates mode="html" />
      
   </xsl:template>
   
   <xsl:template match="*:bindingDesc" mode="html">
            
      <xsl:apply-templates mode="html" />
      
   </xsl:template>
   
   
   <!--provenance-->
   <xsl:template name="get-doc-history">
   
      <xsl:if test="//*:sourceDesc/*:msDesc/*:history/*:provenance">
         
         <ownerships>

            <xsl:attribute name="display" select="'true'" />
            
            <ownership>
               <xsl:attribute name="display" select="'true'" />

               <xsl:variable name="ownership">               
                  <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:history/*:provenance" mode="html"/>
               </xsl:variable>
               
               <xsl:attribute name="displayForm" select="normalize-space($ownership)" />
  
               <xsl:value-of select="normalize-space(replace($ownership, '&lt;[^&gt;]+&gt;', ''))"/>
               
            </ownership>
                                    
         </ownerships>
         
      </xsl:if>
   
   </xsl:template>
   
   <xsl:template match="*:history/*:provenance" mode="html">
      
      <xsl:if test="normalize-space(.)">
      
         <xsl:apply-templates mode="html" />
                        
      </xsl:if>

   </xsl:template>
   
   <!--***********************************excerpts - bits of transcription-->
   <xsl:template name="get-item-excerpts">
      
      
      <xsl:if test="*:head|*:div/*:head|*:p|*:div/*:p|*:div/*:note|*:colophon|*:div/*:colophon|*:decoNote|*:div/*:decoNote|*:explicit|*:div/*:explicit|*:finalRubric|*:div/*:finalRubric|*:incipit|*:div/*:incipit|*:rubric|*:div/*:rubric">
         <excerpts>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:variable name="excerpts">
               <xsl:apply-templates select="*:head|*:div/*:head|*:p|*:div/*:p|*:div/*:note|*:colophon|*:div/*:colophon|*:decoNote|*:div/*:decoNote|*:explicit|*:div/*:explicit|*:finalRubric|*:div/*:finalRubric|*:incipit|*:div/*:incipit|*:rubric|*:div/*:rubric" mode="html" />         
            </xsl:variable>
            
            <xsl:attribute name="displayForm" select="normalize-space($excerpts)" />
            <!-- <xsl:value-of select="normalize-space($excerpts)" /> -->
            <xsl:value-of select="normalize-space(replace($excerpts, '&lt;[^&gt;]+&gt;', ''))"/>
         </excerpts>
      </xsl:if>
      
   </xsl:template>
   
   <!--notes-->
   <xsl:template name="get-item-notes">
      
      
      <xsl:if test="*:note">
         <notes>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:for-each select="*:note">
               
               <xsl:variable name="note">
                  <xsl:apply-templates mode="html"/>
               </xsl:variable>
               
               <note>
                  <xsl:attribute name="display" select="'true'" />
                  <xsl:attribute name="displayForm" select="normalize-space($note)"/>
                  <xsl:value-of select="normalize-space($note)"/>
               </note>
               
            </xsl:for-each>
            
         </notes>
      </xsl:if>
      
   </xsl:template>
   
   <!--colophon-->
   <xsl:template match="*:msItem/*:colophon|*:msItem/*:div/*:colophon" mode="html">
      
      <xsl:text>&lt;div&gt;</xsl:text>
      <xsl:text>&lt;b&gt;Colophon</xsl:text>
      
      <xsl:if test="normalize-space(@type)">
         <xsl:value-of select="concat(', ', normalize-space(@type))" />
      </xsl:if>
      
      <xsl:text>:&lt;/b&gt; </xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>
      
   </xsl:template>
   
   <!--explicit-->
   <xsl:template match="*:msItem/*:explicit|*:msItem/*:div/*:explicit" mode="html">
      
      <xsl:text>&lt;div&gt;</xsl:text>
      <xsl:text>&lt;b&gt;Explicit</xsl:text>
      
      <xsl:if test="normalize-space(@type)">
         <xsl:value-of select="concat(', ', normalize-space(@type))" />
      </xsl:if>
      
      <xsl:text>:&lt;/b&gt; </xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>
      
   </xsl:template>
   
   
   <!--incipit-->
   <xsl:template match="*:msItem/*:incipit|*:msItem/*:div/*:incipit" mode="html">
      
      <xsl:text>&lt;div&gt;</xsl:text>
      <xsl:text>&lt;b&gt;Incipit</xsl:text>
      
      <xsl:if test="normalize-space(@type)">
         <xsl:value-of select="concat(', ', normalize-space(@type))" />
      </xsl:if>
      
      <xsl:text>:&lt;/b&gt; </xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>
      
   </xsl:template>
   
   <!--rubric-->
   <xsl:template match="*:msItem/*:rubric|*:msItem/*:div/*:rubric" mode="html">
      
      <xsl:text>&lt;div&gt;</xsl:text>
      <xsl:text>&lt;b&gt;Rubric</xsl:text>
      
      <xsl:if test="normalize-space(@type)">
         <xsl:value-of select="concat(', ', normalize-space(@type))" />
      </xsl:if>
      
      <xsl:text>:&lt;/b&gt; </xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:msItem/*:finalRubric|*:msItem/*:div/*:finalRubric" mode="html">
      
      <xsl:text>&lt;div&gt;</xsl:text>
      <xsl:text>&lt;b&gt;Final Rubric</xsl:text>
      
      <xsl:if test="normalize-space(@type)">
         <xsl:value-of select="concat(', ', normalize-space(@type))" />
      </xsl:if>
      
      <xsl:text>:&lt;/b&gt; </xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>
      
   </xsl:template>
   
   <!--****************************notes-->
   <xsl:template match="*:note" mode="html">
      
  
      <xsl:apply-templates mode="html" />
      
   </xsl:template>
   
   <!--deco notes within msitems-->
   <xsl:template match="*:msItem//*:decoNote" mode="html">
      
      <xsl:choose>
         <xsl:when test="*:p">
            
            <xsl:text>&lt;p&gt;</xsl:text>
            <xsl:text>&lt;b&gt;Decoration:&lt;/b&gt; </xsl:text>
            <xsl:text>&lt;/p&gt;</xsl:text>
            
            <xsl:apply-templates mode="html" />
            
         </xsl:when>
         <xsl:otherwise>
            
            <xsl:text>&lt;p&gt;</xsl:text>
            <xsl:text>&lt;b&gt;Decoration:&lt;/b&gt; </xsl:text>
            <xsl:apply-templates mode="html" />
            <xsl:text>&lt;/p&gt;</xsl:text>
            
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   <!--filiation-->
   <xsl:template name="get-item-filiation">
      
      <xsl:if test="*:filiation">
         <filiations>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:variable name="filiation">
               <xsl:text>&lt;div&gt;</xsl:text>
               <xsl:apply-templates select="*:filiation" mode="html" />         
               <xsl:text>&lt;/div&gt;</xsl:text>
            </xsl:variable>
            
            <xsl:attribute name="displayForm" select="normalize-space($filiation)" />
            <!-- <xsl:value-of select="normalize-space($filiation)" /> -->
            <xsl:value-of select="normalize-space(replace($filiation, '&lt;[^&gt;]+&gt;', ''))"/>
         </filiations>
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template match="*:filiation" mode="html">
      
      <xsl:text>&lt;div&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>
      
   </xsl:template>
   
   <!--************************************bibliography processing-->
   <xsl:template name="get-doc-biblio">
      
      <xsl:if test="//*:sourceDesc/*:msDesc/*:additional//*:listBibl">
         
         <bibliographies>
         
            <xsl:attribute name="display" select="'true'" />            

            <bibliography>
               
               <xsl:attribute name="display" select="'true'" />            
               
               <xsl:variable name="bibliography">
                  <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:additional//*:listBibl" mode="html" />                                
               </xsl:variable>
            
               <xsl:attribute name="displayForm" select="normalize-space($bibliography)" />
               <!-- <xsl:value-of select="normalize-space($bibliography)" /> -->
               <xsl:value-of select="normalize-space(replace($bibliography, '&lt;[^&gt;]+&gt;', ''))"/>
               
            </bibliography>
            
         </bibliographies>
         
      </xsl:if>
      
   </xsl:template>
   
   
   <xsl:template name="get-doc-and-item-biblio">
      
      <xsl:if test="//*:sourceDesc/*:msDesc/*:additional//*:listBibl|//*:sourceDesc/*:msDesc/*:msContents/*:msItem[1]/*:listBibl">
         
         <bibliographies>
            
            <xsl:attribute name="display" select="'true'" />           
            
            <bibliography>
               
               <xsl:attribute name="display" select="'true'" />            
               
               <xsl:variable name="bibliography">
                  <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:additional//*:listBibl|//*:sourceDesc/*:msDesc/*:msContents/*:msItem[1]/*:listBibl" mode="html" />                                
               </xsl:variable>
            
               <xsl:attribute name="displayForm" select="normalize-space($bibliography)" />
               <!-- <xsl:value-of select="normalize-space($bibliography)" /> -->
               <xsl:value-of select="normalize-space(replace($bibliography, '&lt;[^&gt;]+&gt;', ''))"/>
               
            </bibliography>
                        
         </bibliographies>
         
      </xsl:if>
      
   </xsl:template>


   <xsl:template name="get-item-biblio">
      
      <xsl:if test="*:listBibl">
         
         <!--         <bibliographies> -->
         <bibliographies>
            
            <xsl:attribute name="display" select="'true'" />
            
            <bibliography>
               
               <xsl:attribute name="display" select="'true'" />            
               <xsl:variable name="bibliography">
                  <xsl:apply-templates select="*:listBibl" mode="html" />                                
               </xsl:variable>
            
               <xsl:attribute name="displayForm" select="normalize-space($bibliography)" />
               <!-- <xsl:value-of select="normalize-space($bibliography)" /> -->
               <xsl:value-of select="normalize-space(replace($bibliography, '&lt;[^&gt;]+&gt;', ''))"/>
               
            </bibliography>
            
         </bibliographies>
         
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template match="*:head" mode="html">
      
      <!-- <xsl:text>&lt;br /&gt;</xsl:text> -->
      
      <xsl:text>&lt;p&gt;&lt;b&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/b&gt;&lt;/p&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:listBibl" mode="html">
 
 
         <xsl:apply-templates select="*:head" mode="html" />
      
      <xsl:text>&lt;div style=&apos;list-style-type: disc;&apos;&gt;</xsl:text>
      <xsl:apply-templates select=".//*:bibl|.//*:biblStruct" mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>
      
      <xsl:text>&lt;br /&gt;</xsl:text>
      
   </xsl:template>
   
   
   <xsl:template match="*:listBibl//*:bibl" mode="html">
      
      <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>
   
   </xsl:template>
   
   
   <xsl:template match="*:listBibl//*:biblStruct[not(*)]" mode="html">
      
      <!-- Template to catch biblStruct w no child elements and treat like bibl - shouldn't really happen but frequently does, so prob easiest to handle it -->
      
      <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>
   
   </xsl:template>
  

   <xsl:template match="*:listBibl//*:biblStruct[*:analytic]" mode="html">
      
      <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;</xsl:text>
      
      <xsl:choose>
         <xsl:when test="@xml:id">
            <xsl:text> id=&quot;</xsl:text>
            <xsl:value-of select="normalize-space(@xml:id)" />
            <xsl:text>&quot;</xsl:text>
         </xsl:when>
         <xsl:when test="*:idno[@type='callNumber']">
            <xsl:text> id=&quot;</xsl:text>
            <xsl:value-of select="normalize-space(*:idno)" />
            <xsl:text>&quot;</xsl:text>
         </xsl:when>
      </xsl:choose>      
      
      <xsl:text>&gt;</xsl:text>
      
      <xsl:choose>
         <xsl:when test="@type='bookSection' or @type='encyclopaediaArticle' or @type='encyclopediaArticle'">
            
            <xsl:for-each select="*:analytic">
               
               <xsl:for-each select="*:author|*:editor">
                  
                  <xsl:call-template name="get-names-first-surname-first" />
                  
               </xsl:for-each>                  
               
               <xsl:text>, </xsl:text>
               
               <xsl:for-each select="*:title">
                  
                  <xsl:text>&quot;</xsl:text>
                  <xsl:value-of select="normalize-space(.)" />
                  <xsl:text>&quot;</xsl:text>
                  
               </xsl:for-each>
            
            </xsl:for-each>
            
            <xsl:text>, in </xsl:text>
            
            <xsl:for-each select="*:monogr">
               
               <xsl:choose>
                  <xsl:when test="*:author">
                     
                     <xsl:for-each select="*:author">
                        
                        <xsl:call-template name="get-names-all-forename-first" />
                        
                     </xsl:for-each>                  
                     
                     <xsl:text>, </xsl:text>
                     
                     <xsl:for-each select="*:title">
                        
                        <xsl:text>&lt;i&gt;</xsl:text>
                        <xsl:value-of select="normalize-space(.)" />
                        <xsl:text>&lt;/i&gt;</xsl:text>
                        
                     </xsl:for-each>
                     
                     <xsl:if test="*:editor">
                        
                        <xsl:text>, ed. </xsl:text>
                        
                        <xsl:for-each select="*:editor">
                           
                           <xsl:call-template name="get-names-all-forename-first" />
                           
                        </xsl:for-each>
                        
                     </xsl:if>
                     
                  </xsl:when>
                  
                  <xsl:when test="*:editor">
                     
                     <xsl:for-each select="*:editor">
                        
                        <xsl:call-template name="get-names-all-forename-first" />
                        
                     </xsl:for-each>                  
                     
                     
                     <xsl:choose>
                        <xsl:when test="(count(*:editor) &gt; 1)">
                           <xsl:text> (eds)</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:text> (ed.)</xsl:text>
                        </xsl:otherwise>
                     </xsl:choose>
                     
                     <xsl:text>, </xsl:text>
                     
                     <xsl:for-each select="*:title">
                        
                        <xsl:text>&lt;i&gt;</xsl:text>
                        <xsl:value-of select="normalize-space(.)" />
                        <xsl:text>&lt;/i&gt;</xsl:text>
                        
                     </xsl:for-each>
                     
                  </xsl:when>
                  
                  <xsl:otherwise>
                     
                     <xsl:for-each select="*:title">
                        
                        <xsl:text>&lt;i&gt;</xsl:text>
                        <xsl:value-of select="normalize-space(.)" />
                        <xsl:text>&lt;/i&gt;</xsl:text>
                        
                     </xsl:for-each>
                     
                  </xsl:otherwise>
                  
               </xsl:choose>
                             
               <xsl:if test="*:edition">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="*:edition" />
               </xsl:if>
                              
               <xsl:if test="*:respStmt">
                  
                  <xsl:for-each select="*:respStmt">
                     
                     <xsl:text> </xsl:text>
                     
                     <xsl:call-template name="get-respStmt" />
                     
                  </xsl:for-each>
                  
               </xsl:if>
               
               
                           
               <xsl:if test="../*:series">
                  
                  <xsl:for-each select="../*:series">
                     
                     <xsl:text>, </xsl:text>
                     
                     <xsl:for-each select="*:title">
                        
                        <!-- <xsl:text>&lt;i&gt;</xsl:text> -->
                        <xsl:value-of select="normalize-space(.)" />
                        <!-- <xsl:text>&lt;/i&gt;</xsl:text> -->
                        
                     </xsl:for-each>
                     
                     <xsl:if test=".//*:biblScope">
                        
                        <xsl:for-each select=".//*:biblScope">
                           
                           <xsl:text> </xsl:text>
                           
                           <xsl:if test="@type">
                              <xsl:value-of select="normalize-space(@type)" />
                              <xsl:text>. </xsl:text>
                           </xsl:if>
                           
                           <xsl:value-of select="normalize-space(.)" />
                           
                        </xsl:for-each>
                        
                     </xsl:if>
                     
                  </xsl:for-each>
                  
               </xsl:if>
               
               <xsl:if test="*:imprint">
                  
                  <xsl:text> </xsl:text>
                  
                  <xsl:for-each select="*:imprint">
                  
                     <xsl:call-template name="get-imprint" />
                  
                  </xsl:for-each>
                  
                </xsl:if>
               
               
               <xsl:if test=".//*:biblScope">
                  
                  <xsl:for-each select=".//*:biblScope">
                     
                     <xsl:text> </xsl:text>
                     
                     <xsl:if test="@type">
                        <xsl:value-of select="normalize-space(@type)" />
                        <xsl:text>. </xsl:text>
                     </xsl:if>
                     
                     <xsl:value-of select="normalize-space(.)" />
                     
                  </xsl:for-each>
                  
               </xsl:if>
               
            </xsl:for-each>
               
            <xsl:text>.</xsl:text>            
            
         </xsl:when>
         
         <xsl:when test="@type='journalArticle'">
            
            <xsl:for-each select="*:analytic">
               
               <xsl:for-each select="*:author|*:editor">
                  
                  <xsl:call-template name="get-names-first-surname-first" />
                  
               </xsl:for-each>                  
               
               <xsl:text>, </xsl:text>
               
               <xsl:for-each select="*:title">
                  
                  <xsl:text>&quot;</xsl:text>
                  <xsl:value-of select="normalize-space(.)" />
                  <xsl:text>&quot;</xsl:text>
                  
               </xsl:for-each>
               
            </xsl:for-each>
            
            <xsl:text>, </xsl:text>
            
            <xsl:for-each select="*:monogr">
               
               <xsl:for-each select="*:title">
                  
                  <xsl:text>&lt;i&gt;</xsl:text>
                  <xsl:value-of select="normalize-space(.)" />
                  <xsl:text>&lt;/i&gt;</xsl:text>
                  
               </xsl:for-each>
               
               <xsl:if test=".//*:biblScope">
                  
                  <xsl:for-each select=".//*:biblScope">
                     
                     <xsl:text> </xsl:text>
                     
                     <xsl:if test="@type">
                        <xsl:value-of select="normalize-space(@type)" />
                        <xsl:text>. </xsl:text>
                     </xsl:if>
                     
                     <xsl:value-of select="normalize-space(.)" />                     
                     
                  </xsl:for-each>
                  
               </xsl:if>
                              
               <xsl:if test="../*:series">
                  
                  <xsl:for-each select="../*:series">
                     
                     <xsl:text>, </xsl:text>
                     
                     <xsl:for-each select="*:title">
                        
                        <!-- <xsl:text>&lt;i&gt;</xsl:text> -->
                        <xsl:value-of select="normalize-space(.)" />
                        <!-- <xsl:text>&lt;/i&gt;</xsl:text> -->
                        
                     </xsl:for-each>
                     
                     <xsl:if test=".//*:biblScope">
                        
                        <xsl:for-each select=".//*:biblScope">
                           
                           <xsl:text>. </xsl:text>
                           
                           <xsl:if test="@type">
                              <xsl:value-of select="normalize-space(@type)" />
                              <xsl:text> </xsl:text>
                           </xsl:if>
                           
                           <xsl:value-of select="normalize-space(.)" />
                           
                        </xsl:for-each>
                        
                     </xsl:if>
                     
                  </xsl:for-each>
                  
               </xsl:if>
               
               <xsl:if test="*:imprint">
                  
                  <xsl:text> </xsl:text>
                  
                  <xsl:for-each select="*:imprint">
                     
                     <xsl:call-template name="get-imprint" />
                     
                  </xsl:for-each>
                  
               </xsl:if>
               
            </xsl:for-each>
               
            <xsl:text>.</xsl:text>
            
         </xsl:when>
         
         <xsl:otherwise>
            
         </xsl:otherwise>
         
      </xsl:choose>
            
      <xsl:text>&lt;/div&gt;</xsl:text>
      
   </xsl:template>
   
   
   
   <xsl:template match="*:listBibl//*:biblStruct[*:monogr and not(*:analytic)]" mode="html">
      
      <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;</xsl:text>
      
      <xsl:choose>
         <xsl:when test="@xml:id">
            <xsl:text> id=&quot;</xsl:text>
            <xsl:value-of select="normalize-space(@xml:id)" />
            <xsl:text>&quot;</xsl:text>
         </xsl:when>
         <xsl:when test="*:idno[@type='callNumber']">
            <xsl:text> id=&quot;</xsl:text>
            <xsl:value-of select="normalize-space(*:idno)" />
            <xsl:text>&quot;</xsl:text>
         </xsl:when>
      </xsl:choose>      
      
      <xsl:text>&gt;</xsl:text>
      
      <xsl:choose>
         <xsl:when test="@type='book' or @type='document' or @type='thesis' or @type='manuscript' or @type='webpage'">
            
            <xsl:for-each select="*:monogr">
               
               <xsl:choose>
                  <xsl:when test="*:author">
                     
                     <xsl:for-each select="*:author">
                        
                        <xsl:call-template name="get-names-first-surname-first" />
                        
                     </xsl:for-each>                  
                     
                     <xsl:text>, </xsl:text>
                     
                     <xsl:for-each select="*:title">
                        
                        <xsl:text>&lt;i&gt;</xsl:text>
                        <xsl:value-of select="normalize-space(.)" />
                        <xsl:text>&lt;/i&gt;</xsl:text>
                        
                     </xsl:for-each>
                     
                     <xsl:if test="*:editor">
                        
                        <xsl:text>, ed. </xsl:text>
                        
                        <xsl:for-each select="*:editor">
                           
                           <xsl:call-template name="get-names-all-forename-first" />
                           
                        </xsl:for-each>
                        
                     </xsl:if>
                     
                  </xsl:when>
                  
                  <xsl:when test="*:editor">
                     
                     <xsl:for-each select="*:editor">
                        
                        <xsl:call-template name="get-names-first-surname-first" />
                        
                     </xsl:for-each>                  
                     
                     
                     <xsl:choose>
                        <xsl:when test="(count(*:editor) &gt; 1)">
                           <xsl:text> (eds)</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:text> (ed.)</xsl:text>
                        </xsl:otherwise>
                     </xsl:choose>
                     
                     <xsl:text>, </xsl:text>
                                             
                     <xsl:for-each select="*:title">
                        
                        <xsl:text>&lt;i&gt;</xsl:text>
                        <xsl:value-of select="normalize-space(.)" />
                        <xsl:text>&lt;/i&gt;</xsl:text>
                        
                     </xsl:for-each>
                  
                  </xsl:when>
                  
                  <xsl:otherwise>
                     
                     <xsl:for-each select="*:title">
                        
                        <xsl:text>&lt;i&gt;</xsl:text>
                        <xsl:value-of select="normalize-space(.)" />
                        <xsl:text>&lt;/i&gt;</xsl:text>
                        
                     </xsl:for-each>
                  
                  </xsl:otherwise>
                  
               </xsl:choose>
               
               <xsl:if test="*:edition">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="*:edition" />
               </xsl:if>
                                             
               <xsl:if test="*:respStmt">
                  
                  <xsl:for-each select="*:respStmt">
                     
                     <xsl:text> </xsl:text>
                     
                     <xsl:call-template name="get-respStmt" />
                     
                  </xsl:for-each>
               
               </xsl:if>
               
               
               
               <xsl:if test="../*:series">
                  
                  <xsl:for-each select="../*:series">
                     
                     <xsl:text>, </xsl:text>
                     
                     <xsl:for-each select="*:title">
                        
                        <!-- <xsl:text>&lt;i&gt;</xsl:text> -->
                        <xsl:value-of select="normalize-space(.)" />
                        <!-- <xsl:text>&lt;/i&gt;</xsl:text> -->
                        
                     </xsl:for-each>
                     
                     <xsl:if test=".//*:biblScope">
                        
                        <xsl:for-each select=".//*:biblScope">
                           
                           
                              <xsl:text> </xsl:text>
                              
                           <xsl:if test="@type">
                              <xsl:value-of select="normalize-space(@type)" />
                              <xsl:text>. </xsl:text>
                           </xsl:if>
                           
                           <xsl:value-of select="normalize-space(.)" />
                           
                        </xsl:for-each>
                        
                     </xsl:if>
                     
                  </xsl:for-each>
                  
               </xsl:if>
               
               <xsl:if test="*:extent">
                  
                  <xsl:for-each select="*:extent">
                     
                     <xsl:text>, </xsl:text>
                     
                     <xsl:value-of select="normalize-space(.)"></xsl:value-of>
                     
                  </xsl:for-each>
                  
               </xsl:if>
               
               
               <xsl:if test="*:imprint">
                  
                  <xsl:for-each select="*:imprint">
                     
                     <xsl:text> </xsl:text>
                     
                     <xsl:call-template name="get-imprint" />
                     
                  </xsl:for-each>
                  
               </xsl:if>
               
               <xsl:if test="*:biblScope">
                  
                  <xsl:for-each select="*:biblScope">
                     
                     <xsl:text> </xsl:text>
                     
                     <xsl:if test="@type">
                        <xsl:value-of select="normalize-space(@type)" />
                        <xsl:text>. </xsl:text>
                     </xsl:if>
                     
                     <xsl:value-of select="normalize-space(.)" />
                     
                  </xsl:for-each>
                  
               </xsl:if>
               
            </xsl:for-each>
            
            <xsl:if test="*:idno[@type='ISBN']">
               
               <xsl:for-each select="*:idno[@type='ISBN']">
                  
                  <xsl:text> ISBN: </xsl:text>
                  <xsl:value-of select="normalize-space(.)" />
                  
               </xsl:for-each>
               
            </xsl:if>
            
            
            
            <xsl:text>.</xsl:text>
            
         </xsl:when>
         
         <xsl:otherwise>
            
         </xsl:otherwise>
      </xsl:choose>
      
      
      <xsl:text>&lt;/div&gt;</xsl:text>
      
   </xsl:template>


   <!--names processing for bibliography-->
   <xsl:template name="get-names-first-surname-first">
      
      <xsl:choose>
         <xsl:when test="position() = 1">
            <!-- first author = surname first -->
            
            <xsl:choose>
               <xsl:when test=".//*:surname">
                  <!-- surname explicitly present -->
                 
                  <xsl:for-each select=".//*:surname">
                     <xsl:value-of select="normalize-space(.)" />
                     <xsl:if test="not(position()=last())">
                        <xsl:text> </xsl:text>
                     </xsl:if>
                  </xsl:for-each>
                  
                  <xsl:if test=".//*:forename">
                     <xsl:text>, </xsl:text>
                  
                     <xsl:for-each select=".//*:forename">
                        <xsl:value-of select="normalize-space(.)" />
                        <xsl:if test="not(position()=last())">
                           <xsl:text> </xsl:text>
                        </xsl:if>
                     </xsl:for-each>
                     
                  </xsl:if>
               
               </xsl:when>
               <xsl:when test="*:name[not(*)]">
                  <!-- just a name, not surname/forename -->
                  
                  <xsl:for-each select=".//*:name[not(*)]">
                     <xsl:value-of select="normalize-space(.)" />
                     <xsl:if test="not(position()=last())">
                        <xsl:text> </xsl:text>
                     </xsl:if>
                  </xsl:for-each>
                  
               </xsl:when>
               
               <xsl:otherwise>
                  <!-- forenames only? not sure what else to do but render them -->
                  
                  <xsl:for-each select=".//*:forename">
                     <xsl:value-of select="normalize-space(.)" />
                     <xsl:if test="not(position()=last())">
                        <xsl:text> </xsl:text>
                     </xsl:if>
                  </xsl:for-each>
                  
               </xsl:otherwise>
            </xsl:choose>
            
         </xsl:when>
         <xsl:otherwise>
            <!-- not first author = forenames first -->
            
            <xsl:choose>
               <xsl:when test="position()=last()">
                  <xsl:text> and </xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>, </xsl:text>
               </xsl:otherwise>
            </xsl:choose>
            
            <xsl:choose>
               <xsl:when test=".//*:surname">
                  <!-- surname explicitly present -->
                  
                  <xsl:if test=".//*:forename">
                     
                     <xsl:for-each select=".//*:forename">
                        <xsl:value-of select="normalize-space(.)" />
                        <xsl:if test="not(position()=last())">
                           <xsl:text> </xsl:text>
                        </xsl:if>
                     </xsl:for-each>
                     
                     <xsl:text> </xsl:text>
                     
                 </xsl:if>
                  
                  <xsl:for-each select=".//*:surname">
                     <xsl:value-of select="normalize-space(.)" />
                     <xsl:if test="not(position()=last())">
                        <xsl:text> </xsl:text>
                     </xsl:if>
                  </xsl:for-each>
                  
               </xsl:when>   
               <xsl:when test="*:name[not(*)]">
                  <!-- just a name, not forename/surname -->
                  
                  <xsl:for-each select=".//*:name[not(*)]">
                     <xsl:value-of select="normalize-space(.)" />
                     <xsl:if test="not(position()=last())">
                        <xsl:text> </xsl:text>
                     </xsl:if>
                  </xsl:for-each>
                  
               </xsl:when>
               <xsl:otherwise>
                  <!-- forenames only? not sure what else to do but render them -->
                  
                  <xsl:for-each select=".//*:forename">
                     <xsl:value-of select="normalize-space(.)" />
                     <xsl:if test="not(position()=last())">
                        <xsl:text> </xsl:text>
                     </xsl:if>
                  </xsl:for-each>
                  
               </xsl:otherwise>
               
            </xsl:choose>
            
         </xsl:otherwise>
      </xsl:choose>      
      
   </xsl:template>
   
   <xsl:template name="get-names-all-forename-first">

      <xsl:choose>
         <xsl:when test="position() = 1" />
         <xsl:when test="position()=last()">
            <xsl:text> and </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>, </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      
      <xsl:for-each select=".//*:name[not(*)]">
         <xsl:value-of select="normalize-space(.)" />
         <xsl:if test="not(position()=last())">
            <xsl:text> </xsl:text>
         </xsl:if>
      </xsl:for-each>
      
      <xsl:for-each select=".//*:forename">
         <xsl:value-of select="normalize-space(.)" />
         <xsl:if test="not(position()=last())">
            <xsl:text> </xsl:text>
         </xsl:if>
      </xsl:for-each>
      
      <xsl:text> </xsl:text>
      
      <xsl:for-each select=".//*:surname">
         <xsl:value-of select="normalize-space(.)" />
         <xsl:if test="not(position()=last())">
            <xsl:text> </xsl:text>
         </xsl:if>
      </xsl:for-each>
      
   </xsl:template>
   
   <xsl:template name="get-imprint">
      
      
      <xsl:variable name="pubText">
         
         <xsl:if test="*:note[@type='thesisType']">
            <xsl:for-each select="*:note[@type='thesisType']">
               <xsl:value-of select="normalize-space(.)" />
               <xsl:text> thesis</xsl:text>
            </xsl:for-each>
            <xsl:text> </xsl:text>
         </xsl:if>
         
         <xsl:if test="*:pubPlace">
            <xsl:for-each select="*:pubPlace">
               <xsl:value-of select="normalize-space(.)" />
            </xsl:for-each>
            <xsl:text>: </xsl:text>
         </xsl:if>
         
         <xsl:if test="*:publisher">
            <xsl:for-each select="*:publisher">
               <xsl:value-of select="normalize-space(.)" />
            </xsl:for-each>
            <xsl:if test="*:date">
               <xsl:text>, </xsl:text>
            </xsl:if>
         </xsl:if>
         
         <xsl:if test="*:date">
            <xsl:for-each select="*:date">
               <xsl:value-of select="normalize-space(.)" />
            </xsl:for-each>
         </xsl:if>
         
         
         
         
      </xsl:variable>
      
      
      <xsl:if test="normalize-space($pubText)">
         
         <xsl:text>(</xsl:text>
         <xsl:value-of select="$pubText"/>
         <xsl:text>)</xsl:text>
      
      </xsl:if>
      
      
      
      <xsl:if test="*:note[@type='url']">
         <xsl:text> &lt;a target=&apos;_blank&apos; class=&apos;externalLink&apos; href=&apos;</xsl:text>
         <xsl:value-of select="*:note[@type='url']" />
         <xsl:text>&apos;&gt;</xsl:text>
         <xsl:value-of select="*:note[@type='url']" />
         <xsl:text>&lt;/a&gt;</xsl:text>         
      </xsl:if>
   
      <xsl:if test="*:note[@type='accessed']">
         <xsl:text> Accessed: </xsl:text>
         <xsl:for-each select="*:note[@type='accessed']">
            <xsl:value-of select="normalize-space(.)" />
         </xsl:for-each>
      </xsl:if>
         
   </xsl:template>
   
   <xsl:template name="get-respStmt">
      
      <xsl:choose>
         <xsl:when test="*">
            <xsl:for-each select="*:resp">
               <xsl:value-of select="." />
               <xsl:text>: </xsl:text>
            </xsl:for-each>
            <xsl:for-each select=".//*:forename">
               <xsl:value-of select="." />
               <xsl:text> </xsl:text>
            </xsl:for-each>
            <xsl:for-each select=".//*:surname">
               <xsl:value-of select="." />
               <xsl:if test="not(position()=last())">
                  <xsl:text> </xsl:text>
               </xsl:if>
            </xsl:for-each>
            <xsl:for-each select=".//*:name[not(*)]">
               <xsl:value-of select="." />
               <xsl:if test="not(position()=last())">
                  <xsl:text> </xsl:text>
               </xsl:if>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="." />
         </xsl:otherwise>
     </xsl:choose>       
      
   </xsl:template>
   
   
   <!--*******************************************name processing-->
   
   <!-- Table of role relator codes and role element names -->
   <xsl:variable name="rolemap">
      <role code="aut" name="authors" />
      <role code="dnr" name="donors" />
      <role code="fmo" name="formerOwners" />
      <!-- Treat pbl as "associated"
         <role code="pbl" name="publishers" />
      -->
      <role code="rcp" name="recipients" />
      <role code="scr" name="scribes" />
   </xsl:variable>
   
   <xsl:template name="get-doc-names">
      
      <!--for doc names looks only in summary, physdesc and history-->
      
      <xsl:if test="//*:sourceDesc/*:msDesc/*:msContents/*:summary//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))]|//*:sourceDesc/*:msDesc/*:physDesc//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))]|//*:sourceDesc/*:msDesc/*:history//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))]">
         
         <xsl:for-each-group select="//*:sourceDesc/*:msDesc/*:msContents/*:summary//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][@subtype=$rolemap/role/@code]|//*:sourceDesc/*:msDesc/*:physDesc//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][@subtype=$rolemap/role/@code]|//*:sourceDesc/*:msDesc/*:history//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][@subtype=$rolemap/role/@code]" group-by="@subtype">

            <xsl:variable name="rolecode" select="@subtype" />
            
            <xsl:variable name="elementName" select="$rolemap/role[@code=$rolecode]/@name" />
            <!--
            <xsl:variable name="label" select="$rolemap/role[@code=$rolecode]/@label" />
            -->
            
            
            <xsl:element name="{$elementName}">
               <xsl:attribute name="display" select="'true'" />
               
              
               
               <!-- to de-dup names, group by name and process just first one in group -->
               <xsl:for-each-group select="current-group()" group-by="*:persName[@type='standard']">
                  
                  <!-- <xsl:sort select="*:persName[@type='standard']" /> --> <!-- CHECK WHETHER ORDER SIGNIFICANT -->
                  
                  <xsl:choose>
                     <xsl:when test="normalize-space(*:persName[@type='standard'])">
                        <xsl:apply-templates select="current-group()[1]"/>                        
                     </xsl:when>
                     <xsl:otherwise>
                        <!-- if no standard name then may be several names grouped together -->
                        <xsl:for-each-group select="current-group()" group-by="*:persName">
                           <xsl:apply-templates select="current-group()[1]"/>                        
                        </xsl:for-each-group>
                     </xsl:otherwise>
                  </xsl:choose> 
                  
               </xsl:for-each-group>
               
            </xsl:element>
            
         </xsl:for-each-group>
         
         <xsl:if test="//*:sourceDesc/*:msDesc/*:msContents/*:summary//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][not(@subtype=$rolemap/role/@code)]|//*:sourceDesc/*:msDesc/*:physDesc//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][not(@subtype=$rolemap/role/@code)]|//*:sourceDesc/*:msDesc/*:history//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][not(@subtype=$rolemap/role/@code)]">
            
            <associated>
               
               <xsl:attribute name="display" select="'true'" />
               
               
               <xsl:for-each-group select="//*:sourceDesc/*:msDesc/*:msContents/*:summary//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][not(@subtype=$rolemap/role/@code)]|//*:sourceDesc/*:msDesc/*:physDesc//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][not(@subtype=$rolemap/role/@code)]|//*:sourceDesc/*:msDesc/*:history//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][not(@subtype=$rolemap/role/@code)]" group-by="*:persName[@type='standard']">
                  
                  <xsl:sort select="*:persName[@type='standard']" />
                  
                  <xsl:choose>
                     <xsl:when test="normalize-space(*:persName[@type='standard'])">
                        <xsl:apply-templates select="current-group()[1]"/>                        
                     </xsl:when>
                     <xsl:otherwise>
                        <!-- if no standard name then may be several names grouped together -->
                        <xsl:for-each-group select="current-group()" group-by="*:persName">
                           <xsl:apply-templates select="current-group()[1]"/>                        
                        </xsl:for-each-group>
                     </xsl:otherwise>
                  </xsl:choose> 
                  
               </xsl:for-each-group>
               
            </associated>
            
         </xsl:if>
         
      </xsl:if>
         
   </xsl:template>
   
   <xsl:template name="get-doc-and-item-names">
      
      <!--for doc and item, looks in summary, physdesc, history, first msItem author and respstmt fields-->
      <!--simplify to just pick up all names in first msItem?-->
      
      <xsl:if test="//*:sourceDesc/*:msDesc/*:msContents/*:summary//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))]|//*:sourceDesc/*:msDesc/*:physDesc//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))]|//*:sourceDesc/*:msDesc/*:history//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))]|//*:sourceDesc/*:msDesc/*:msContents/*:msItem[1]/*:author/*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][@subtype=$rolemap/role/@code]
         |//*:sourceDesc/*:msDesc/*:msContents/*:msItem[1]/*:respStmt/*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][@subtype=$rolemap/role/@code]">
         
         <xsl:for-each-group select="//*:sourceDesc/*:msDesc/*:msContents/*:summary//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][@subtype=$rolemap/role/@code]|//*:sourceDesc/*:msDesc/*:physDesc//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][@subtype=$rolemap/role/@code]|//*:sourceDesc/*:msDesc/*:history//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][@subtype=$rolemap/role/@code]|//*:sourceDesc/*:msDesc/*:msContents/*:msItem[1]/*:author/*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][@subtype=$rolemap/role/@code]
|//*:sourceDesc/*:msDesc/*:msContents/*:msItem[1]/*:respStmt/*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][@subtype=$rolemap/role/@code]" group-by="@subtype">
                        
            <xsl:variable name="rolecode" select="@subtype" />
            
            <xsl:variable name="elementName" select="$rolemap/role[@code=$rolecode]/@name" />
            <!--
            <xsl:variable name="label" select="$rolemap/role[@code=$rolecode]/@label" />
            -->
            
            <xsl:element name="{$elementName}">
               <xsl:attribute name="display" select="'true'" />
             
               
               <!-- to de-dup names, group by name and process just first one in group -->
               <xsl:for-each-group select="current-group()" group-by="*:persName[@type='standard']">
                                    
                  <!-- <xsl:sort select="*:persName[@type='standard']" /> --> <!-- CHECK WHETHER ORDER SIGNIFICANT -->
                  <xsl:choose>
                     <xsl:when test="normalize-space(*:persName[@type='standard'])">
                        <xsl:apply-templates select="current-group()[1]"/>                        
                     </xsl:when>
                     <xsl:otherwise>
                        <!-- if no standard name then may be several names grouped together -->
                        <xsl:for-each-group select="current-group()" group-by="*:persName">
                           <xsl:apply-templates select="current-group()[1]"/>                        
                        </xsl:for-each-group>
                     </xsl:otherwise>
                  </xsl:choose> 
                                    
               </xsl:for-each-group>
            
            </xsl:element>
            
         </xsl:for-each-group>
      </xsl:if>
         
         <xsl:if test="//*:sourceDesc/*:msDesc/*:msContents/*:summary//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][not(@subtype=$rolemap/role/@code)]|//*:sourceDesc/*:msDesc/*:physDesc//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][not(@subtype=$rolemap/role/@code)]|//*:sourceDesc/*:msDesc/*:history//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][not(@subtype=$rolemap/role/@code)]
            |//*:sourceDesc/*:msDesc/*:msContents/*:msItem[1]/*:respStmt/*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][not(@subtype=$rolemap/role/@code)]">
            
            <associated>
               
               <xsl:attribute name="display" select="'true'" />
               <!--
               <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:msContents/*:summary//*:name[*:persName][not(@subtype=$rolemap/role/@code)]|//*:sourceDesc/*:msDesc/*:physDesc//*:name[*:persName][not(@subtype=$rolemap/role/@code)]|//*:sourceDesc/*:msDesc/*:history//*:name[*:persName][not(@subtype=$rolemap/role/@code)]"/>
               -->
               <xsl:for-each-group select="//*:sourceDesc/*:msDesc/*:msContents/*:summary//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][not(@subtype=$rolemap/role/@code)]|//*:sourceDesc/*:msDesc/*:physDesc//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][not(@subtype=$rolemap/role/@code)]|//*:sourceDesc/*:msDesc/*:history//*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][not(@subtype=$rolemap/role/@code)]
                  |//*:sourceDesc/*:msDesc/*:msContents/*:msItem[1]/*:respStmt/*:name[*:persName][not(contains(lower-case(*:persName[@type='standard']), 'unknown'))][not(@subtype=$rolemap/role/@code)]" group-by="*:persName[@type='standard']">
                  
                  <xsl:sort select="*:persName[@type='standard']" />
                  
                  <xsl:choose>
                     <xsl:when test="normalize-space(*:persName[@type='standard'])">
                        <xsl:apply-templates select="current-group()[1]"/>                        
                     </xsl:when>
                     <xsl:otherwise>
                        <!-- if no standard name then may be several names grouped together -->
                        <xsl:for-each-group select="current-group()" group-by="*:persName">
                           <xsl:apply-templates select="current-group()[1]"/>                        
                        </xsl:for-each-group>
                     </xsl:otherwise>
                  </xsl:choose> 
                  
               </xsl:for-each-group>
               
            </associated>
            
         </xsl:if>
         

      
   </xsl:template>
   
   <xsl:template name="get-item-names">
      
      <!--for items, just look in author field-->
      <!--look for all names in msItem?-->
      
      <xsl:if test="*:author/*:name[not(contains(lower-case(*:persName[@type='standard']), 'unknown'))]">
         
         <authors>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:apply-templates select="*:author/*:name[not(contains(lower-case(*:persName[@type='standard']), 'unknown'))]" />
            
         </authors>
         
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template match="*:name[*:persName]">
      
      <name>
         
         <xsl:attribute name="display" select="'true'" />
         
         <xsl:choose>
            <xsl:when test="*:persName[@type='standard']">
               <xsl:for-each select="*:persName[@type='standard']">
                  <xsl:attribute name="displayForm" select="normalize-space(.)" />
                  <fullForm>
                     <xsl:value-of select="normalize-space(.)"/>
                  </fullForm>                   
               </xsl:for-each>
               
               <xsl:choose>
                  <!-- if separate display form exists, use as short form -->
                  <xsl:when test="*:persName[@type='display']">
                     <xsl:for-each select="*:persName[@type='display']">
                        <shortForm>
                           <xsl:value-of select="normalize-space(.)"/>
                        </shortForm>                   
                     </xsl:for-each>
                     
                  </xsl:when>
                  <!-- if no separate display form exists, use standard form as short form -->
                  <xsl:otherwise>
                     <xsl:for-each select="*:persName[@type='standard']">
                        <shortForm>
                           <xsl:value-of select="normalize-space(.)"/>
                        </shortForm>
                     </xsl:for-each>
                  </xsl:otherwise>
               </xsl:choose>
               
            </xsl:when>
            <xsl:when test="*:persName[@type='display']">
               <xsl:for-each select="*:persName[@type='display']">
                  <xsl:attribute name="displayForm" select="normalize-space(.)" />
                  <shortForm>
                     <xsl:value-of select="normalize-space(.)"/>
                  </shortForm>                   
               </xsl:for-each>
               
            </xsl:when>
            <xsl:otherwise>
               <!-- No standard form, no display form, take whatever we've got? -->
               <xsl:for-each select="*:persName">
                  <xsl:attribute name="displayForm" select="normalize-space(.)" />
                  <shortForm>
                     <xsl:value-of select="normalize-space(.)"/>
                  </shortForm>                   
               </xsl:for-each>
               
            </xsl:otherwise>
         </xsl:choose>
         
         
         <xsl:for-each select="@type">
            <type>
               <xsl:value-of select="normalize-space(.)" />
            </type>
         </xsl:for-each>
         
         <xsl:for-each select="@subtype">
            <role>
               <xsl:value-of select="normalize-space(.)" />
            </role>
         </xsl:for-each>
         
         <xsl:for-each select="@key[contains(., 'VIAF_')]">
            
            <authority>VIAF</authority>
            <authorityURI>http://viaf.org/</authorityURI>
            
            <!-- Possible that there are multiple VIAF_* tokens (if multiple VIAF entries for same person) e.g. Sanskrit MS-OR-02339. For now, just use first, but should maybe handle multiple -->
            <xsl:for-each select="tokenize(normalize-space(.), ' ')[starts-with(., 'VIAF_')][1]">
               
               <!-- <xsl:if test="starts-with(., 'VIAF_')"> -->                    
                  <valueURI>
                     <xsl:value-of select="concat('http://viaf.org/viaf/', substring-after(.,'VIAF_'))" />
                  </valueURI>                        
               <!-- </xsl:if> -->
            </xsl:for-each>           
            
         </xsl:for-each>
         
      </name>
      
   </xsl:template>
   
   <xsl:template name="get-part-names">
      <!-- TODO -->
   </xsl:template>   
   
   <xsl:template name="get-part-languages">
      <!-- TODO -->
   </xsl:template>   
   
   
   
   <!--******************************language processing-->
   <xsl:template name="get-item-languages">
      
      <xsl:if test="*:textLang/@mainLang">
         
         <languageCodes>
            
            <xsl:for-each select="*:textLang/@mainLang">
               
               <languageCode>
                  <xsl:value-of select="normalize-space(.)" />
               </languageCode>
               
            </xsl:for-each>
            
         </languageCodes>
         
      </xsl:if>
      
      <xsl:if test="*:textLang">
         
         <languageStrings>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:for-each select="*:textLang">
               
               <languageString>
                  
                  <xsl:attribute name="display" select="'true'" />
                  <xsl:attribute name="displayForm" select="normalize-space(.)" />
                  <xsl:value-of select="normalize-space(.)" />
               </languageString>
               
            </xsl:for-each>
            
         </languageStrings>
         
      </xsl:if>
      
   </xsl:template>
   
   
   <!--******************************data sources and revisions-->
   <xsl:template name="get-doc-metadata">
      
      <xsl:if test="normalize-space(//*:sourceDesc/*:msDesc/*:additional/*:adminInfo/*:recordHist/*:source)">
         
         <dataSources>
            
            <xsl:attribute name="display" select="'true'" />
            
            <dataSource>
               
               <xsl:variable name="dataSource">               
                  <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:additional/*:adminInfo/*:recordHist/*:source" mode="html" />
               </xsl:variable>
            
               <xsl:attribute name="display" select="'true'" />
               <xsl:attribute name="displayForm" select="normalize-space($dataSource)" />
               <!-- <xsl:value-of select="normalize-space($dataSource)" /> -->
               <xsl:value-of select="normalize-space(replace($dataSource, '&lt;[^&gt;]+&gt;', ''))"/>
               
            </dataSource>
            
         </dataSources>
         
      </xsl:if>
      
      <xsl:if test="normalize-space(//*:revisionDesc)">
         
         <dataRevisions>
            
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:variable name="dataRevisions">               
               <xsl:apply-templates select="//*:revisionDesc" mode="html" />
            </xsl:variable>
            
            <xsl:attribute name="displayForm" select="normalize-space($dataRevisions)" />
            <!-- <xsl:value-of select="normalize-space($dataRevisions)" /> -->
            <xsl:value-of select="normalize-space(replace($dataRevisions, '&lt;[^&gt;]+&gt;', ''))"/>
            
         </dataRevisions>
         
      </xsl:if>
   
   </xsl:template>
   
   <xsl:template match="*:recordHist/*:source" mode="html">
      
      <xsl:apply-templates mode="html" />
      
   </xsl:template>
   
   <xsl:template match="*:revisionDesc" mode="html">

      <xsl:apply-templates mode="html" />
      
   </xsl:template>
   
   <xsl:template match="*:revisionDesc/*:change" mode="html">
      
      <xsl:apply-templates mode="html" />
      
      <xsl:if test="not(position()=last())">
         <xsl:text>&lt;br /&gt;</xsl:text>         
      </xsl:if>
      
   </xsl:template>
   
   
   
   <!--************************************collection membership-->
   <xsl:template name="get-collection-memberships">
      <!-- Lookup collections of which this item is a member (from SQL database) -->
      
      <xsl:element name="collections">
         <xsl:for-each select="cudl:get-memberships($fileID)">
            <xsl:element name="collection">
               <xsl:value-of select="title"/>
            </xsl:element>
         </xsl:for-each>         
      </xsl:element>
      
   </xsl:template>
   
   
   <!--*********************************** number of pages -->
   <xsl:template name="get-numberOfPages">
      <numberOfPages>
         <xsl:value-of select="count(//*:text/*:body/*:div[not(@type)]//*:pb)"/>
      </numberOfPages>
   </xsl:template>
   
   
   <!-- ********************************* embeddable -->
   <xsl:template name="get-embeddable">
      
      <xsl:variable name="downloadImageRights" select="normalize-space(//*:publicationStmt/*:availability[@xml:id='downloadImageRights'])"/>
      <xsl:variable name="images" select="normalize-space(//*:facsimile/*:surface[1]/*:graphic[1]/@url)"/>
      
 
      
      <embeddable>
         <xsl:choose>
            
            <xsl:when test="normalize-space($images)">
               
               <xsl:choose>
                  <xsl:when test="normalize-space($downloadImageRights)">true</xsl:when>
                  <xsl:otherwise>false</xsl:otherwise>
               </xsl:choose>
               
               
            </xsl:when>
            
            <xsl:otherwise>false</xsl:otherwise>
         </xsl:choose>
      </embeddable>
      
   </xsl:template>
   
   
   <!--*****************************make pages and urls which relate to them-->
   <xsl:template name="make-pages">
      
      <pages>
         <!--differentiates from translation pages-->
         <xsl:for-each select="//*:text/*:body/*:div[not(@type)]//*:pb">
            
            <page>
               <label>
                  <xsl:value-of select="normalize-space(@n)"/>
               </label>
                              
               <physID>
                  <xsl:value-of select="concat('PHYS-',position())"/>
               </physID>
               
               <sequence>
                  <xsl:value-of select="position()"/>
               </sequence>
               
               <!-- Page image -->
               <xsl:if test="normalize-space(@facs)">
                  <!-- page image present -->
                  
                  <xsl:variable name="surface" select="id(substring-after(@facs, '#'))"/>
                  
                  <xsl:if test="$surface">                     
                     <xsl:variable name="imageUrl" select="normalize-space($surface/*:graphic[contains(@decls, '#download')]/@url)"/>
                     <xsl:variable name="imageUrlShort" select="replace($imageUrl, 'http://cudl.lib.cam.ac.uk/(newton|content)','/content')"/>
                     
                     <xsl:variable name="thumbnailUrl" select="normalize-space($surface/*:graphic[@decls='#thumbnail']/@url)"/>
                     <xsl:variable name="thumbnailUrlShort" select="replace($thumbnailUrl, 'http://cudl.lib.cam.ac.uk/(newton|content)','/content')"/>
                     <xsl:variable name="thumbnailOrientation" select="normalize-space($surface/*:graphic[@decls='#thumbnail']/@rend)"/>
                     
                     
                     <displayImageURL>
                        <xsl:value-of select="replace($imageUrlShort, '.jpg','.dzi')"/>
                     </displayImageURL>
                     <downloadImageURL>
                        <xsl:value-of select="$imageUrlShort"/>
                     </downloadImageURL>
                     <thumbnailImageURL>
                        <xsl:value-of select="$thumbnailUrlShort"/>
                     </thumbnailImageURL>
                     <thumbnailImageOrientation>
                        <xsl:value-of select="$thumbnailOrientation"/>
                     </thumbnailImageOrientation>
                     
                  </xsl:if>
                  
               </xsl:if>
               
               <!-- Page transcription -->
               <xsl:choose>
                  <!--when this pb has no following siblings i.e. it is the last element pb element and is not followed by transcription content, do nothing-->
                  <!--<xsl:when test="count(following-sibling::*)=0" />-->
                  <xsl:when test="position() = last() and count(following-sibling::*)=0"/>
                    
                  <!--when there's no content between here and the next pb element do nothing-->
                  <xsl:when test="local-name(following-sibling::*[1])='pb'" >
                     
                  </xsl:when>
                  <xsl:otherwise>
                     <!-- transcription content present so set up page extract URI  -->
                     <transcriptionDiplomaticURL>
                        
                        <xsl:value-of select="concat('/v1/transcription/tei/diplomatic/internal/',$fileID,'/',@n,'/',@n)"/>
                        
                     </transcriptionDiplomaticURL>
                  </xsl:otherwise>
               </xsl:choose>
               
               <xsl:variable name="transcriptionLabel"><xsl:value-of select="@n"/></xsl:variable>
               
               <xsl:for-each select="//*:text/*:body/*:div[@type='translation']//*:pb[@n=$transcriptionLabel]">
                  
                  
                  
                  <!-- Page translation -->
                  <xsl:choose>
                     <!--when this pb has no following siblings i.e. it is the last element pb element and is not followed by content, do nothing-->
                     <!--<xsl:when test="count(following-sibling::*)=0" />-->
                     <xsl:when test="position() = last() and count(following-sibling::*)=0"/>
                     
                     <!--when there's no content between here and the next pb element do nothing-->
                     <xsl:when test="local-name(following-sibling::*[1])='pb'" >
                        
                     </xsl:when>
                     <xsl:otherwise>
                        <!-- translation content present so set up page extract URI  -->
                        <translationURL>
                           
                           <xsl:value-of select="concat('/v1/translation/tei/EN/',$fileID,'/',@n,'/',@n)"/>
                           
                          
                        </translationURL>
                        
                     </xsl:otherwise>
                  </xsl:choose>
                  
                  
               </xsl:for-each>
               
               <!-- 
                  Note: possible to have:
                  - page with neither image nor transcription
                  - page with image but no transcription
                  - page with transcription but no image
                  - page with image and transcription
               -->
            </page>
            
         </xsl:for-each>
      </pages>
      
   </xsl:template>
   
   
   <!--make logical structure for navigation-->
   <xsl:template name="make-logical-structure">
      
      <logicalStructures xtf:noindex="true">
         
         <xsl:if test="//*:sourceDesc/*:msDesc/*:msContents/*:msItem">
            
            <xsl:choose>
               <xsl:when test="count(//*:sourceDesc/*:msDesc/*:msContents/*:msItem) = 1">
                  
                  <!-- Just one top-level item -->
                  
                  <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:msContents/*:msItem[1]" mode="logicalstructure" />
                  
               </xsl:when>
               <xsl:otherwise>
                  
                  <!-- Sequence of top-level items, so need to wrap -->
                  
                  <logicalStructure>
                     
                     <descriptiveMetadataID>
                        <xsl:value-of select="'DOCUMENT'"/>
                     </descriptiveMetadataID>
                     
                     <label>
                        <xsl:choose>
                           <xsl:when test="//*:sourceDesc/*:msDesc/*:msContents/*:summary/*:title[@type='general']">
                              <xsl:value-of select="*:msDesc/*:msContents/*:summary/*:title[@type='general'][1]"/>
                           </xsl:when>
                           <xsl:when test="//*:sourceDesc/*:msDesc/*:msContents/*:summary/*:title">
                              <xsl:value-of select="*:msDesc/*:msContents/*:summary/*:title[1]"/>
                           </xsl:when>
                           <xsl:when test="//*:sourceDesc/*:msDesc/*:msIdentifier/*:idno">
                              <xsl:value-of select="normalize-space(//*:sourceDesc/*:msDesc/*:msIdentifier/*:idno)"/>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:text>Untitled Document</xsl:text>               
                           </xsl:otherwise>
                        </xsl:choose>         
                     </label>
                                               
                     <startPageLabel>
                        <xsl:value-of select="//*:text/*:body/*:div[not(@type)]/*:pb[1]/@n" />
                        
                        
                        
                     </startPageLabel>
                     
                     <startPagePosition>
                        <xsl:text>1</xsl:text>
                     </startPagePosition>
                     
                     <startPageID>
                        <xsl:value-of select="'PHYS-1'" />
                     </startPageID>
                     
                     <endPageLabel>
                        <xsl:value-of select="//*:text/*:body/*:div[not(@type)]//*:pb[last()]/@n" />
                     </endPageLabel>
                     
                     <xsl:variable name="endPagePosition" select="count(//*:text/*:body/*:div[not(@type)]//*:pb)" />
                     <endPagePosition>
                        <xsl:value-of select="$endPagePosition" />
                     </endPagePosition>
                                         
                     <children>
                        <xsl:apply-templates select="//*:sourceDesc/*:msDesc/*:msContents/*:msItem" mode="logicalstructure" />               
                     </children>                  
                  </logicalStructure>
                  
               </xsl:otherwise>
            </xsl:choose>
            
         </xsl:if>
         
      </logicalStructures>
      
   </xsl:template>
   
   
   <xsl:template match="*:msItem" mode="logicalstructure">
      
      <logicalStructure>
         
         <xsl:variable name="n-tree">         
            <xsl:value-of select="sum((count(ancestor-or-self::*[local-name()='msItem' or local-name()='msPart']), count(preceding::*[local-name()='msItem' or local-name()='msPart'])))" />
         </xsl:variable>
         
         <descriptiveMetadataID>
            <xsl:value-of select="concat('ITEM-', normalize-space($n-tree))"/>
         </descriptiveMetadataID>
         
         <label>            
            <xsl:choose>
               <xsl:when test="*:title[not(@type)]">
                  <xsl:value-of select="normalize-space(*:title[not(@type)][1])"/>              
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>Untitled Item</xsl:text>               
               </xsl:otherwise>
            </xsl:choose>
         </label>
         
         <xsl:variable name="startPageLabel">
            <xsl:choose>
               <xsl:when test="*:locus/@from">
                  <xsl:value-of select="normalize-space(*:locus/@from)" />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="//*:text/*:body/*:div[not(@type)]/*:pb[1]/@n" />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         
         <startPageLabel>
            <xsl:value-of select="$startPageLabel" />
            
            
            
         </startPageLabel>
         
         <xsl:variable name="startPagePosition">
            <!-- Ugh must be a neater way -->
            <xsl:for-each select="//*:text/*:body/*:div[not(@type)]//*:pb" >
               <xsl:if test="@n = $startPageLabel">
                  <xsl:value-of select="position()" />                                
               </xsl:if>
            </xsl:for-each>
         </xsl:variable>
         
         <startPagePosition>
            <xsl:value-of select="$startPagePosition" />                                
         </startPagePosition>
         
         <startPageID>
            <xsl:value-of select="concat('PHYS-',$startPagePosition)" />
         </startPageID>
         
         <xsl:variable name="endPageLabel">
            <xsl:choose>
               <xsl:when test="*:locus/@to">
                  <xsl:value-of select="normalize-space(*:locus/@to)" />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="//*:text/*:body/*:div[not(@type)]/*:pb[last()]/@n" />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         
         <endPageLabel>
            <xsl:value-of select="$endPageLabel" />
         </endPageLabel>
         
         <endPagePosition>
            <!-- Ugh must be a neater way -->
            <xsl:for-each select="//*:text/*:body/*:div[not(@type)]//*:pb" >
               <xsl:if test="@n = $endPageLabel">
                  <xsl:value-of select="position()" />                                
               </xsl:if>
            </xsl:for-each>
         </endPagePosition>
         
         <xsl:if test="*:msContents/*:msItem">
            <children>
               <xsl:apply-templates select="*:msContents/*:msItem" mode="logicalstructure" />               
            </children>                            
         </xsl:if>
                  
         <xsl:if test="*:msItem">
            <children>
               <xsl:apply-templates select="*:msItem" mode="logicalstructure" />               
            </children>                            
         </xsl:if>
         
      </logicalStructure>
      
   </xsl:template>
   
   
   <!--************************************indexes content for search at page level - not displayed in viewer-->
   <xsl:template name="make-index-pages">
      
      
      <!--rework this system of flags in favour of automatic tab creation at page level?-->
      <xsl:if test="//*:text/*:body/*:div[not(@type)]/*[not(local-name()='pb')]">
         
         <useTranscriptions>true</useTranscriptions>
         <useDiplomaticTranscriptions>true</useDiplomaticTranscriptions>
         
      </xsl:if>
      
      <xsl:if test="//*:text/*:body/*:div[@type='translation']/*[not(local-name()='pb')]">
         
         <useTranslations>true</useTranslations>
         
      </xsl:if>
      
      <!--indexes each page of transcription or translation-->

      <xsl:for-each select="//*:text/*:body/*:div">
         
         <xsl:if test="./*[not(local-name()='pb')]">
            
               <xsl:apply-templates select=".//*:pb"/>
         
         </xsl:if>
         
      </xsl:for-each>    
           
      
      <!--this indexes any list items containing at least one locus element under the from attribute of the first locus-->
      <xsl:for-each select="//*:list/*:item[*:locus]">
         
        
            <listItemPage>
               <xsl:attribute name="xtf:subDocument" select="concat('listItem-', position())" />
               
               
               <fileID>
                  <xsl:value-of select="$fileID"/>          
               </fileID>
               
               <!-- Below is a bit of a fudge. It uses the "top-level" dmdID in all cases. What it should really do is work out where this page is in the logical structure. But as collection facet already propagated throughout, and subjects and dates(?) only at top level, can probably get away with it without losing out on fact inheritance -->
               
               <xsl:if test="//*:sourceDesc/*:msDesc/*:msContents/*:msItem">
                  <xsl:choose>
                     <xsl:when test="count(//*:sourceDesc/*:msDesc/*:msContents/*:msItem) = 1">
                        <dmdID xtf:noindex="true">ITEM-1</dmdID>
                     </xsl:when>
                     <xsl:otherwise>
                        <dmdID xtf:noindex="true">DOCUMENT</dmdID>                           
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:if>
               
               <xsl:variable name="startPageLabel" select="*:locus[1]/@from"/>
               
               <xsl:variable name="startPagePosition">
                  <!-- Ugh must be a neater way -->
                  <xsl:for-each select="//*:text/*:body/*:div[not(@type)]//*:pb" >
                     <xsl:if test="@n = $startPageLabel">
                        <xsl:value-of select="position()" />                                
                     </xsl:if>
                  </xsl:for-each>
               </xsl:variable>
              
               
               <startPageLabel>
                  <xsl:value-of select="$startPageLabel"/>
                  
                  
                  
               </startPageLabel>
               
               <startPage>
                  <xsl:value-of select="$startPagePosition"/>
               </startPage>
               
               <title>
                  <xsl:value-of select="$startPageLabel"/>
               </title>
               
               <listItemText>
                  
                 
                   <xsl:apply-templates mode="index"/>
                 
                  
               </listItemText>
               
            </listItemPage>
      
      </xsl:for-each>
      
   </xsl:template>
   
   <xsl:template match="*:pb">
      
            <transcriptionPage>
               <xsl:attribute name="xtf:subDocument" select="concat('sub-', normalize-space(@xml:id))" />
               
               
               <fileID>
                  <xsl:value-of select="$fileID"/>          
               </fileID>
               
               <!-- Below is a bit of a fudge. It uses the "top-level" dmdID in all cases. What it should really do is work out where this page is in the logical structure. But as collection facet already propagated throughout, and subjects and dates(?) only at top level, can probably get away with it without losing out on fact inheritance -->
               
               <xsl:if test="//*:sourceDesc/*:msDesc/*:msContents/*:msItem">
                  <xsl:choose>
                     <xsl:when test="count(//*:sourceDesc/*:msDesc/*:msContents/*:msItem) = 1">
                        <dmdID>ITEM-1</dmdID>
                     </xsl:when>
                     <xsl:otherwise>
                        <dmdID>DOCUMENT</dmdID>                           
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:if>                  
               
               <startPageLabel>
                  <xsl:value-of select="normalize-space(@n)"/>
                  
                  
                  
               </startPageLabel>
               
               <startPage>
                  <xsl:value-of select="position()"/>
               </startPage>
               
               <title>
                  <xsl:value-of select="normalize-space(@n)"/>
               </title>
               
               <transcriptionText>
                  
                 <xsl:variable name="xmlid">
                    <xsl:value-of select="@xml:id"/>
                 </xsl:variable>
                  
                 
                 
                 <xsl:variable name="pageText">
                 <xsl:choose>
                     <xsl:when test="following::*:pb">
                        <xsl:variable name="nextpb" select="following::*:pb[1]/@xml:id" />
                        
                           
                              <xsl:apply-templates select="following::text()[following::*:pb[@xml:id = $nextpb]]" mode="index"/>
                           
                           
                     </xsl:when>
                     <xsl:otherwise>
                        
                           <xsl:apply-templates select="following::text()" mode="index"/>
                           
                     </xsl:otherwise>
                  </xsl:choose>
                 </xsl:variable>
              
              <xsl:value-of select="normalize-space($pageText)"/>

         
               </transcriptionText>
               
            </transcriptionPage>
      
   </xsl:template>
   
   
   <xsl:template match="*" mode="index">
      
         <xsl:apply-templates mode="index"/>
      
   </xsl:template>
   
   <xsl:template match="text()" mode="index">
      
      
      <xsl:copy-of select="."/>
      
      
   </xsl:template>
   
   
     <!-- ******************************html processing templates-->
 

   <xsl:template match="*:p" mode="html">
      
     <xsl:text>&lt;p&gt;</xsl:text>
 
      <xsl:apply-templates mode="html" />
      
     <xsl:text>&lt;/p&gt;</xsl:text> 
      
   </xsl:template>
   
   <!--allows creation of paragraphs in summary (a bit of a cheat - TEI doesn't allow p tags here so we use seg and process into p)-->
   <!--this is necessary to allow collapse to first paragraph in interface-->
   <xsl:template match="*:seg[@type='para']" mode="html">
      
      <xsl:text>&lt;p style=&apos;text-align: justify;&apos;&gt;</xsl:text>

      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/p&gt;</xsl:text> 

      
   </xsl:template>
   
   
   <xsl:template match="*[not(local-name()='additions')]/*:list" mode="html">
      
      <xsl:text>&lt;div&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>
      <xsl:text>&lt;br /&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*[not(local-name()='additions')]/*:list/*:item" mode="html">
      
     
      <xsl:apply-templates mode="html" />
     
      <xsl:text>&lt;br /&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:additions/*:list" mode="html">
      
      <xsl:apply-templates select="*:head" mode="html" />
      
      <xsl:text>&lt;div style=&apos;list-style-type: disc;&apos;&gt;</xsl:text>
      <xsl:apply-templates select="*[not(local-name()='head')]" mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:additions/*:list/*:item" mode="html">
      
      <xsl:text>&lt;div style=&apos;display: list-item; margin-left: 20px;&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/div&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:lb" mode="html">
      
      <xsl:text>&lt;br /&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:title" mode="html">
      
      <xsl:text>&lt;i&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:term" mode="html">
      
      <xsl:text>&lt;i&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
    
   <xsl:template match="*:q|*:quote" mode="html">
      
      <xsl:text>"</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>"</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*[@rend='italic']" mode="html">
      
      <xsl:text>&lt;i&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*[@rend='superscript']" mode="html">
      
      <xsl:text>&lt;sup&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/sup&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*[@rend='bold']" mode="html">
      
      <xsl:text>&lt;b&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/b&gt;</xsl:text>
      
   </xsl:template>
      
   <xsl:template match="*:g" mode="html">
      
      <xsl:choose>
         <xsl:when test=".='%'">
            <xsl:text>&#x25CE;</xsl:text>
         </xsl:when>
         <xsl:when test=".='@'">
            <xsl:text>&#x2748;</xsl:text>
         </xsl:when>
         <xsl:when test=".='$'">
            <xsl:text>&#x2240;</xsl:text>
         </xsl:when>
         <xsl:when test=".='bhale'">
            <xsl:text>&#x2114;</xsl:text>
         </xsl:when>
         <xsl:when test=".='ba'">
            <xsl:text>&#x00A7;</xsl:text>
         </xsl:when>
         <xsl:when test=".='&#x00A7;'">
            <xsl:text>&#x30FB;</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&lt;i&gt;</xsl:text>
            <xsl:apply-templates mode="html" />
            <xsl:text>&lt;/i&gt;</xsl:text>
         </xsl:otherwise>
      </xsl:choose>      
      
   </xsl:template>
   
   <xsl:template match="*:l" mode="html">
      
      <xsl:if test="not(local-name(preceding-sibling::*[1]) = 'l')">
         <xsl:text>&lt;br /&gt;</xsl:text>
      </xsl:if>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;br /&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:name" mode="html">
      
      <xsl:choose>
         <xsl:when test="*[@type='display']">
            <xsl:value-of select="*[@type='display']" />        
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates mode="html" />           
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <xsl:template match="*:ref[@type='biblio']" mode="html">
      
      <xsl:apply-templates mode="html" />
      
   </xsl:template>
   
   
  
   
   <xsl:template match="*:ref[@type='extant_mss']" mode="html">
      
      <xsl:choose>
         <xsl:when test="normalize-space(@target)">
            <xsl:text>&lt;a target=&apos;_blank&apos; class=&apos;externalLink&apos; href=&apos;</xsl:text>
            <xsl:value-of select="normalize-space(@target)" />
            <xsl:text>&apos;&gt;</xsl:text>
            <xsl:apply-templates mode="html" />
            <xsl:text>&lt;/a&gt;</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates mode="html" />
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   <xsl:template match="*:ref[@type='cudl_link']" mode="html">
      
      <xsl:choose>
         <xsl:when test="normalize-space(@target)">
            <xsl:text>&lt;a href=&apos;</xsl:text>
            <xsl:value-of select="normalize-space(@target)" />
            <xsl:text>&apos;&gt;</xsl:text>
            <xsl:apply-templates mode="html" />
            <xsl:text>&lt;/a&gt;</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates mode="html" />
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   <xsl:template match="*:ref[@type='nmm_link']" mode="html">
      
      <xsl:choose>
         <xsl:when test="normalize-space(@target)">
            <xsl:apply-templates mode="html" />
            <xsl:text> [</xsl:text>
            <xsl:text>&lt;a target=&apos;_blank&apos; class=&apos;externalLink&apos; href=&apos;</xsl:text>
            <xsl:value-of select="normalize-space(@target)" />
            <xsl:text>&apos;&gt;</xsl:text>
            <xsl:text>&lt;img title="Link to RMG" alt=&apos;RMG icon&apos; class=&apos;nmm_icon&apos; src=&apos;/images/general/nmm_small.png&apos;/&gt;</xsl:text>
            <xsl:text>&lt;/a&gt;</xsl:text>
            <xsl:text>]</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates mode="html" />
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   <xsl:template match="*:ref[not(@type)]" mode="html">
      
      <xsl:choose>
         <xsl:when test="normalize-space(@target)">
            
            <xsl:choose>
               
               <xsl:when test="@rend='left' or @rend='right'">
                  
                  <xsl:text>&lt;span style=&quot;float:</xsl:text><xsl:value-of select="@rend"/><xsl:text>; text-align:center; padding-bottom:10px&quot;&gt;</xsl:text>
                  
                  <xsl:text>&lt;a target=&apos;_blank&apos; class=&apos;externalLink&apos; href=&apos;</xsl:text>
                  <xsl:value-of select="normalize-space(@target)" />
                  <xsl:text>&apos;&gt;</xsl:text>
                  <xsl:apply-templates mode="html" />
                  <xsl:text>&lt;/a&gt;</xsl:text>
                  
                  <xsl:text>&lt;/span&gt;</xsl:text>
                  
               </xsl:when>
               
               <xsl:otherwise>
                  
                  <xsl:text>&lt;a target=&apos;_blank&apos; class=&apos;externalLink&apos; href=&apos;</xsl:text>
                  <xsl:value-of select="normalize-space(@target)" />
                  <xsl:text>&apos;&gt;</xsl:text>
                  <xsl:apply-templates mode="html" />
                  <xsl:text>&lt;/a&gt;</xsl:text>
                  
                  
               </xsl:otherwise>
               
               
            </xsl:choose>   
            
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates mode="html" />
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   
   <xsl:template match="*:ref[@type='popup']" mode="html">
      
      <xsl:choose>
         <xsl:when test="normalize-space(@target)">
            
            <xsl:choose>
            
            <xsl:when test="@rend='left' or @rend='right'">
            
            <xsl:text>&lt;span style=&quot;float:</xsl:text><xsl:value-of select="@rend"/><xsl:text>; text-align:center; padding-bottom:10px&quot;&gt;</xsl:text>
            
            <xsl:text>&lt;a class=&apos;popup&apos; href=&apos;</xsl:text>
            <xsl:value-of select="normalize-space(@target)" />
            <xsl:text>&apos;&gt;</xsl:text>
            <xsl:apply-templates mode="html" />
            <xsl:text>&lt;/a&gt;</xsl:text>
               
            <xsl:text>&lt;/span&gt;</xsl:text>
               
            </xsl:when>
               
               <xsl:otherwise>
                  
                  <xsl:text>&lt;a class=&apos;popup&apos; href=&apos;</xsl:text>
                  <xsl:value-of select="normalize-space(@target)" />
                  <xsl:text>&apos;&gt;</xsl:text>
                  <xsl:apply-templates mode="html" />
                  <xsl:text>&lt;/a&gt;</xsl:text>
                  
                  
               </xsl:otherwise>
               
               
            </xsl:choose>   
               
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates mode="html" />
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   
   <xsl:template match="*:locus" mode="html">
      
      <xsl:variable name="from" select="normalize-space(@from)" />
      
      <xsl:variable name="page">
         <!-- Ugh must be a neater way -->
         <xsl:for-each select="//*:text/*:body/*:div[not(@type)]//*:pb" >
            <xsl:if test="@n = $from">
               <xsl:value-of select="position()" />                                
            </xsl:if>
         </xsl:for-each>
      </xsl:variable>
      
      <xsl:text>&lt;a href=&apos;&apos; onclick=&apos;store.loadPage(</xsl:text>
      <xsl:value-of select="$page" />
      <xsl:text>);return false;&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/a&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:graphic[not(@url)]" mode="html">
      
      <xsl:text>&lt;i class=&apos;graphic&apos; style=&apos;font-style:italic;&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   
   <xsl:template match="*:graphic[@url]" mode="html">
       
      
      <xsl:variable name="float">
         <xsl:choose>
            <xsl:when test="@rend='right'">
               <xsl:text>float:right</xsl:text>
               
            </xsl:when>
            <xsl:when test="@rend='left'">
               <xsl:text>float:left</xsl:text>
               
            </xsl:when>
            <xsl:otherwise>
               
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <xsl:text>&lt;img style=&quot;padding:10px;</xsl:text><xsl:value-of select="$float"></xsl:value-of><xsl:text>&quot; src=&quot;</xsl:text><xsl:value-of select="@url"/><xsl:text>&quot; /&gt;</xsl:text>
      
   </xsl:template>
   
      
   <xsl:template match="*:damage" mode="html">
      
      <xsl:text>&lt;i class=&apos;delim&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; color:red&apos;&gt;</xsl:text>
      <xsl:text>[</xsl:text>
      <xsl:text>&lt;/i&gt;</xsl:text>
      <xsl:text>&lt;i class=&apos;damage&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal;&apos;</xsl:text>
      <xsl:text> title=&apos;This text damaged in source&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      <xsl:text>&lt;i class=&apos;delim&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; color:red&apos;&gt;</xsl:text>
      <xsl:text>]</xsl:text>
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:sic" mode="html">
      
      <xsl:text>&lt;i class=&apos;error&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal;&apos;</xsl:text>
      <xsl:text> title=&apos;This text in error in source&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      <xsl:text>&lt;i class=&apos;delim&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; color:red&apos;&gt;</xsl:text>
      <xsl:text>(!)</xsl:text>
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:term/*:sic" mode="html">
      
      <xsl:text>&lt;i class=&apos;error&apos;</xsl:text>
      <xsl:text> title=&apos;This text in error in source&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      <xsl:text>&lt;i class=&apos;delim&apos;</xsl:text>
      <xsl:text> style=&apos;color:red&apos;&gt;</xsl:text>
      <xsl:text>(!)</xsl:text>
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:unclear" mode="html">
      
      <xsl:text>&lt;i class=&apos;delim&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; color:red&apos;&gt;</xsl:text>
      <xsl:text>[</xsl:text>
      <xsl:text>&lt;/i&gt;</xsl:text>
      <xsl:text>&lt;i class=&apos;unclear&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal;&apos;</xsl:text>
      <xsl:text> title=&apos;This text imperfectly legible in source&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      <xsl:text>&lt;i class=&apos;delim&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; color:red&apos;&gt;</xsl:text>
      <xsl:text>]</xsl:text>
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:supplied" mode="html">
      
      <xsl:text>&lt;i class=&apos;supplied&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal;&apos;</xsl:text>
      <xsl:text> title=&apos;This text supplied by transcriber&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:add" mode="html">
      
      <xsl:text>&lt;i class=&apos;delim&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; color:red&apos;&gt;</xsl:text>
      <xsl:text>\</xsl:text>
      <xsl:text>&lt;/i&gt;</xsl:text>
      <xsl:text>&lt;i class=&apos;add&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal;&apos;</xsl:text>
      <xsl:text> title=&apos;This text added&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text> 
      <xsl:text>&lt;i class=&apos;delim&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; color:red&apos;&gt;</xsl:text>
      <xsl:text>/</xsl:text>
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:del[@type='illegible']" mode="html">
      
      <xsl:text>&lt;i class=&apos;delim&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; color:red&apos;&gt;</xsl:text>
      <xsl:text>&#x301A;</xsl:text>
      <xsl:text>&lt;/i&gt;</xsl:text>
      <xsl:text>&lt;i class=&apos;del&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal;&apos;</xsl:text>
      <xsl:text> title=&apos;This text deleted and illegible&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      <xsl:text>&lt;i class=&apos;delim&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; color:red&apos;&gt;</xsl:text>
      <xsl:text>&#x301B;</xsl:text>
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:del" mode="html">
      
      <xsl:text>&lt;i class=&apos;delim&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; color:red&apos;&gt;</xsl:text>
      <xsl:text>&#x301A;</xsl:text>
      <xsl:text>&lt;/i&gt;</xsl:text>
      <xsl:text>&lt;i class=&apos;del&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; text-decoration:line-through;&apos;</xsl:text>
      <xsl:text> title=&apos;This text deleted&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      <xsl:text>&lt;i class=&apos;delim&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; color:red&apos;&gt;</xsl:text>
      <xsl:text>&#x301B;</xsl:text>
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:subst" mode="html">
   
      <xsl:apply-templates mode="html" />
   
   </xsl:template>
   
   <xsl:template match="*:gap" mode="html">
      
      <xsl:text>&lt;i class=&apos;delim&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; color:red&apos;&gt;</xsl:text>
      <xsl:text>&gt;-</xsl:text>
      <xsl:text>&lt;/i&gt;</xsl:text>
      <xsl:text>&lt;i class=&apos;gap&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; color:red&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      <xsl:text>&lt;i class=&apos;delim&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal; color:red&apos;&gt;</xsl:text>
      <xsl:text>-&lt;</xsl:text>
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:desc" mode="html">
      
      <xsl:apply-templates mode="html" />
      
   </xsl:template>
   
   <xsl:template match="*:choice[*:orig][*:reg[@type='hyphenated']]" mode="html">
      
      <xsl:text>&lt;i class=&apos;reg&apos;</xsl:text>
      <xsl:text> style=&apos;font-style:normal;&apos;</xsl:text>
      <xsl:text> title=&apos;String hyphenated for display. Original: </xsl:text>
      <xsl:value-of select="normalize-space(*:orig)"/>
      <xsl:text>&apos;&gt;</xsl:text>
      <xsl:apply-templates select="*:reg[@type='hyphenated']" mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   
   
   
   <xsl:template match="*:reg" mode="html">
      
      <xsl:apply-templates mode="html" />
      
   </xsl:template>
   
  <!-- <xsl:template match="*:reg[@type='hyphenated']" mode="html">
      
      <xsl:value-of select="replace(., '-', '')"/> 
     
   </xsl:template>-->
   
   
   
   <xsl:template match="text()" mode="html">
      
      <xsl:variable name="translated" select="translate(., '^&#x00A7;', '&#x00A0;&#x30FB;')" />
<!--      <xsl:variable name="replaced" select="replace($translated, '&#x005F;&#x005F;&#x005F;', '&#x2014;&#x2014;&#x2014;')" /> -->
      <xsl:variable name="replaced" select="replace($translated, '_ _ _', '&#x2014;&#x2014;&#x2014;')" /> 
      <xsl:value-of select="$replaced" />
   
   </xsl:template>
 
   
   
   
   <!--***************functions-->
   
   <!--Capitalises first letter of text-->
   <xsl:function name="cudl:first-upper-case">
      <xsl:param name="text" />
      
      <xsl:value-of select="concat(upper-case(substring($text,1,1)),substring($text, 2))" />
   </xsl:function>
   

</xsl:stylesheet>
