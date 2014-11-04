<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:parse="http://cdlib.org/xtf/parse"
   xmlns:xtf="http://cdlib.org/xtf"
   xmlns:cudl="http://cudl.lib.cam.ac.uk/xtf/"
   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
   xmlns:ead="urn:isbn:1-931666-22-9"
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
   
   
   <!--*********************************************************************************************
      Fairly comprehensive modifications made by Digital Library team, Foundations Project,
      Cambridge University Library
      
      Basically, all EAD files are pointed here by docSelector.xsl. A variety of templates are then used
      
      1. To create an xml document in an internal format to be passed to style/dynaXML/docFormatter/general/generalDocFormatter.xsl
      2. To index fields and text for search
      
      Here, the conversion to internal format is done by this stylesheet, and the addition of further attributes which affect indexing
      (i.e. marking as metadata, facet or not to be indexed) is done by preFilterCommon.xsl
      
   -->
   
   <!-- ====================================================================== -->
   <!-- Import Common Templates and Functions                                  -->
   <!-- ====================================================================== -->
   
   <xsl:import href="../common/preFilterCommon.xsl"/>
   
   <!-- ====================================================================== -->
   <!-- Output parameters                                                      -->
   <!-- ====================================================================== -->
   
   <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
      
   
   <!-- ====================================================================== -->
   <!-- Default: null transformation                                       -->
   <!-- ====================================================================== -->
  
   <xsl:template match="@*|node()" />
   
   <!-- ====================================================================== -->
   <!-- Root Template                                                          -->
   <!-- ====================================================================== -->
   
   <xsl:template match="/">
      <xtf-converted>
         <xsl:namespace name="xtf" select="'http://cdlib.org/xtf'"/>
         <xsl:call-template name="get-meta"/>
      </xtf-converted>
      
   </xsl:template>
   
   <!-- ====================================================================== -->
   <!-- Metadata Indexing                                                      -->
   <!-- ====================================================================== -->
   
   <xsl:template name="get-meta">
      
      <xsl:variable name="meta">
         
         <xsl:call-template name="make-dmd-parts"/>
         
         <xsl:call-template name="get-numberOfPages"/>
         
         <xsl:call-template name="make-pages" /> 
         <xsl:call-template name="make-logical-structures" /> 
         
         <xsl:call-template name="make-transcription-pages" /> 
                  
      </xsl:variable>
      
      <!-- Add doc kind and sort fields to the data, and output the result. -->
      <xsl:call-template name="add-fields">
         <xsl:with-param name="display" select="'dynaxml'"/>
         <xsl:with-param name="meta" select="$meta"/>
      </xsl:call-template>
   </xsl:template>
   
   <!--top level template for descriptive metadata-->
   <xsl:template name="make-dmd-parts">
      
      <descriptiveMetadata>
         
         <xsl:apply-templates select="*:ead/*:archdesc" />
         
      </descriptiveMetadata>
      
   </xsl:template>
      
   <!--this is the top-level structure for the item-->
   <xsl:template match="*:archdesc">
      
      <xsl:call-template name="make-dmd-part" />
      
      <xsl:apply-templates select="*:dsc/*:c|*:c01" />
      
   </xsl:template>
   
   <!--and these are the lower level structures-->
   <xsl:template match="*:c|*:c01|*:c02|*:c03|*:c04|*:c05|*:c06|*:c07|*:c08|*:c09|*:c10|*:c11|*:c12">
      
      <xsl:call-template name="make-dmd-part" />
      
      <xsl:apply-templates select="*:c|*:c02|*:c03|*:c04|*:c05|*:c06|*:c07|*:c08|*:c09|*:c10|*:c11|*:c12" />
      
   </xsl:template>
   
   <!--fills in descriptive metadata for a structure within the item-->
   <xsl:template name="make-dmd-part">
      
      <part>
         <xsl:call-template name="get-dmdID"/>
         <xsl:call-template name="get-title"/>
                  
         <xsl:call-template name="get-abstract"/>
         
         <xsl:call-template name="get-physloc"/>
         
         <xsl:call-template name="get-level"/>
         
         <xsl:call-template name="get-languages"/>
         
         <xsl:call-template name="get-creators"/>
         
         <xsl:call-template name="get-authors"/>
         
         <xsl:call-template name="get-recipients"/>
         
         <xsl:call-template name="get-associated-persons"/>
         
         <xsl:call-template name="get-associated-corporates"/>         
         
         <xsl:call-template name="get-places"/>
         
         <xsl:call-template name="get-subjects"/>
         
         <xsl:call-template name="get-events"/>         

         <xsl:call-template name="get-physdesc"/>
         
         <xsl:call-template name="get-notes"/>
         
         <xsl:call-template name="get-originals"/>
         
         <xsl:call-template name="get-altforms"/>

         <xsl:call-template name="get-related"/>
         
         <xsl:call-template name="get-biblio"/>
         
         <xsl:if test="local-name(.) = 'archdesc'">
            
            <xsl:call-template name="get-thumbnail"/>
            
            <xsl:call-template name="get-rights"/>
            
            <xsl:call-template name="get-metadata"/>
            
         </xsl:if>
         
         <xsl:call-template name="get-collection-memberships"/> 
         
      </part>
      
   </xsl:template>   
   
   
   <!--ids for structural item-->
   <xsl:template name="get-dmdID">
      
      <xsl:variable name="normunitid" select="translate(normalize-space(*:did/*:unitid[not(@type)]), ' .:/', '----')" />
      
      <xsl:attribute name="xtf:subDocument" select="$normunitid"/>
      
      <xsl:element name="ID"><xsl:value-of select="$normunitid"/></xsl:element>      
      
      <xsl:element name="fileID">
         <xsl:value-of select="$fileID"/>
      </xsl:element>
            
      <xsl:element name="startPageLabel">
         
         <xsl:choose>
            <xsl:when test="*:daogrp[@role='download']/*:daoloc[1]/@label">
               <xsl:value-of select="*:daogrp[@role='download']/*:daoloc[1]/@label"/>               
            </xsl:when>
            <xsl:otherwise>
               <!-- default if page image data missing --> 
               <xsl:text>1</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>

      <xsl:variable name="startPageHref" select="*:daogrp[@role='download']/*:daoloc[1]/@href"/>
      
      <xsl:element name="startPage">
         <xsl:choose>
            <xsl:when test="/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@href=$startPageHref]">
               <xsl:for-each select="/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@href=$startPageHref]">
                  <xsl:value-of select="1 + count(preceding-sibling::*:daoloc)"/>
               </xsl:for-each>               
            </xsl:when>
            <xsl:otherwise>
               <!-- default if page image data missing --> 
               <xsl:message>Error: failed to match component start page to top-level page for <xsl:value-of select="$normunitid"></xsl:value-of></xsl:message> 
               <xsl:text>1</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
      
   </xsl:template>   

   <!--title-->
   <xsl:template name="get-title">
      
      <xsl:variable name="title">
         <xsl:choose>
            <xsl:when test="normalize-space(*:did/*:unittitle)">
               <xsl:value-of select="normalize-space(*:did/*:unittitle)" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>Untitled</xsl:text>
            </xsl:otherwise>            
         </xsl:choose>         
      </xsl:variable>
      
      <!-- temporary work-around for XTF search problem -->
      <xsl:variable name="title" select="translate($title, '&quot;', ' ')" />
      
      <xsl:element name="title">
         <xsl:attribute name="display" select="'true'" />      
         <xsl:attribute name="displayForm" select="$title" />
         <xsl:value-of select="$title" />
      </xsl:element>
      
   </xsl:template>
   
   <!--abstract-->
   <xsl:template name="get-abstract">
      
      <xsl:if test="normalize-space(scopecontent)">
         
         <xsl:element name="abstract">
            
            <xsl:choose>
               <xsl:when test="local-name(.)='archdesc'">
                  <xsl:attribute name="display" select="'false'" />                              
               </xsl:when>
               <xsl:otherwise>
                  <xsl:attribute name="display" select="'true'" />                            
               </xsl:otherwise>
            </xsl:choose>
            
            <xsl:variable name="abstract">
               <xsl:apply-templates select="*:scopecontent" mode="html"/>
            </xsl:variable>
            
            <xsl:attribute name="displayForm" select="normalize-space($abstract)" />         
            
            <!-- <xsl:value-of select="normalize-space($abstract)" /> -->
            <xsl:value-of select="normalize-space(replace($abstract, '&lt;[^&gt;]+&gt;', ''))"/>
            
         </xsl:element>
         
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template match="*:scopecontent" mode="html">
      
      <xsl:apply-templates mode="html" />
      
   </xsl:template>
   
   <!--level-->
   <xsl:template name="get-level">
      
      <xsl:if test="normalize-space(@level)">
         <xsl:element name="level">
            <xsl:attribute name="display" select="'true'" />      
            <xsl:attribute name="displayForm" select="normalize-space(@level)" />
            <xsl:value-of select="normalize-space(@level)" />
         </xsl:element>
      </xsl:if>
      
   </xsl:template>
   
   <!--languages-->
   <xsl:template name="get-languages">
      
      <xsl:if test="normalize-space(string-join(*:did/*:langmaterial/*:language/@langcode, ' '))">
         
         <xsl:element name="languageCodes">
            
            <xsl:apply-templates select="*:did/*:langmaterial/*:language/@langcode" />
            
         </xsl:element>
      
      </xsl:if>
      
      <xsl:if test="normalize-space(string-join(*:did/*:langmaterial/*:language, ' '))">
         
         <xsl:element name="languageStrings">
            
            <xsl:apply-templates select="*:did/*:langmaterial/*:language" />
            
         </xsl:element>
         
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template match="*:langmaterial/*:language/@langcode">
      
      <xsl:element name="languageCode">
         <xsl:value-of select="normalize-space(.)" />   
      </xsl:element>
      
   </xsl:template>
   
   <xsl:template match="*:langmaterial/*:language">
      
      <xsl:element name="languageString">
         <xsl:attribute name="display" select="'true'" />      
         <xsl:attribute name="displayForm" select="normalize-space(.)" />
         <xsl:value-of select="normalize-space(.)" />   
      </xsl:element>
      
   </xsl:template>
   
   <!--physical location-->
   <xsl:template name="get-physloc">
      
      <xsl:choose>
         <xsl:when test="local-name(.)='archdesc'">
            <xsl:if test="normalize-space(*:did/*:repository)">
               <xsl:element name="physicalLocation">
                  <xsl:attribute name="display" select="'true'" />      
                  <xsl:attribute name="displayForm" select="normalize-space(*:did/*:repository)" />
                  <xsl:value-of select="normalize-space(*:did/*:repository)" />
               </xsl:element>
            </xsl:if>
            
            <xsl:if test="normalize-space(*:did/*:unitid[not(@type)])">
               
               <xsl:element name="shelfLocator">
                  
                  <xsl:variable name="shelfLocator" select="replace(normalize-space(*:did/*:unitid[not(@type)]), '^GBR/\d*/', '')"/>
                  
                  <xsl:attribute name="display" select="'true'" />
                  <xsl:attribute name="displayForm" select="$shelfLocator" />
                  <xsl:value-of select="$shelfLocator" />
                  
               </xsl:element>
               
            </xsl:if>
            
         </xsl:when>
         <xsl:otherwise>
            <xsl:if test="normalize-space(*:did/*:unitid[not(@type)])">
               <xsl:element name="reference">
               
                  <xsl:variable name="reference" select="replace(normalize-space(*:did/*:unitid[not(@type)]), '^GBR/\d*/', '')"/>
                  
                  <xsl:attribute name="display" select="'true'" />
                  <xsl:attribute name="displayForm" select="$reference" />
                  <xsl:value-of select="$reference" />
               
               </xsl:element>
           </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   <!--********************people-->
   <!--creators-->
   <xsl:template name="get-creators">
            
      <xsl:if test="normalize-space(string-join(*:did/*:origination, ' '))">
         <xsl:element name="creators">
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:apply-templates select="*:did/*:origination" />
            
         </xsl:element>
      </xsl:if>
   
   </xsl:template>
    
   <!--authors-->
   <xsl:template name="get-authors">
      
      <xsl:if test="normalize-space(string-join(*:controlaccess/*:persname[@role='aut'], ' '))">
         <xsl:element name="authors">
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:apply-templates select="*:controlaccess/*:persname[@role='aut']" />
         </xsl:element>
      </xsl:if>
      
   </xsl:template>
   
   <!--recipients (of letters)-->
   <xsl:template name="get-recipients">
      
      <xsl:if test="normalize-space(string-join(*:controlaccess/*:persname[@role='rcp'], ' '))">
         <xsl:element name="recipients">
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:apply-templates select="*:controlaccess/*:persname[@role='rcp']" />
         </xsl:element>
      </xsl:if>
      
   </xsl:template>
   
   <!--and other associated people-->
   <xsl:template name="get-associated-persons">
      
      <xsl:if test="normalize-space(string-join(*:controlaccess/*:persname[not(@role)], ' '))">
         <xsl:element name="associated">
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:apply-templates select="*:controlaccess/*:persname[not(@role)]" />
         </xsl:element>
      </xsl:if>
      
   </xsl:template>
   
   <!--and associated corporation names-->
   <xsl:template name="get-associated-corporates">
      
      <xsl:if test="normalize-space(string-join(*:controlaccess/*:corpname[not(@role)], ' '))">
         <xsl:element name="associatedCorps">
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:apply-templates select="*:controlaccess/*:corpname[not(@role)]" />
         </xsl:element>
      </xsl:if>
      
   </xsl:template>
   
   <!--origination is where the statement of responsibility is - may be overlap between here and index points-->
   <xsl:template match="*:did/*:origination">
      
      <xsl:for-each select="*:name|*:persname|*:corpname|*:famname|text()[string-length(normalize-space(.)) > 1]">
         
         <xsl:variable name="onormal" select="normalize-space(@normal)"/>
         <xsl:variable name="ocontent" select="normalize-space(.)"/>
         
         <xsl:choose>
            <xsl:when test="normalize-space(string($onormal))">                  
               <!-- Is there a corresponding controlaccess/persname or controlaccess/corpname? -->
               <xsl:choose>
                  <xsl:when test="exists(../../../*:controlaccess/*[.=$onormal and @role='aut'])">
                     <!-- If present as role=author then ignore as creator --> 
                  </xsl:when>
                  
                  <xsl:when test="exists(../../../*:controlaccess/*[.=$onormal and @rules='AACR2'])">
                     <!-- 1st choice = AACR2 name (from VIAF) -->                        
                     <!-- may be multiple matches with different roles so use group -->
                     
                     <xsl:for-each-group select="../../../*:controlaccess/*[.=$onormal and @rules='AACR2']" group-by=".">
                        
                        <xsl:element name="name">
                           <xsl:attribute name="display" select="'true'" />
                           <xsl:attribute name="displayForm" select="." />
                           <xsl:element name="fullForm">
                              <xsl:value-of select="." />
                           </xsl:element>               
                           <xsl:element name="shortForm">
                              <xsl:value-of select="$ocontent" />
                           </xsl:element>
                           <xsl:if test="normalize-space(@source)">                           
                              <xsl:element name="authority">
                                 <xsl:value-of select="@source" />
                              </xsl:element>
                           </xsl:if>
                           <xsl:if test="normalize-space(@authfilenumber)">
                              <xsl:element name="valueURI">
                                 <xsl:value-of select="@authfilenumber" />
                              </xsl:element>
                           </xsl:if>                           
                           
                        </xsl:element>
                     </xsl:for-each-group>
                     
                  </xsl:when>
                  <xsl:when test="exists(../../*:controlaccess/*[.=$onormal and @source='ncarules'])">
                     <!-- 2nd choice = NCA Rules name -->
                     
                     <!-- may be multiple matches with different roles so use group -->
                     
                     <xsl:for-each-group select="../../../*:controlaccess/*[.=$onormal and @source='ncarules']" group-by=".">
                        
                        <xsl:element name="name">
                           <xsl:attribute name="display" select="'true'" />
                           <xsl:attribute name="displayForm" select="." />
                           <xsl:element name="fullForm">
                              <xsl:value-of select="." />
                           </xsl:element>               
                           <xsl:element name="shortForm">
                              <xsl:value-of select="$ocontent" />
                           </xsl:element>
                           <xsl:if test="normalize-space(@source)">                           
                              <xsl:element name="authority">
                                 <xsl:value-of select="@source" />
                              </xsl:element>
                           </xsl:if>
                           <xsl:if test="normalize-space(@authfilenumber)">
                              <xsl:element name="valueURI">
                                 <xsl:value-of select="@authfilenumber" />
                              </xsl:element>
                           </xsl:if>
                        </xsl:element>
                        
                     </xsl:for-each-group>
                     
                  </xsl:when>
                  <xsl:otherwise>
                     <!-- (no match) use did/origination form -->
                     
                     <xsl:element name="name">
                        <xsl:attribute name="display" select="'true'" />
                        <xsl:attribute name="displayForm" select="normalize-space(.)" />
                        <xsl:element name="shortForm">
                           <xsl:value-of select="normalize-space(.)" />
                        </xsl:element>
                     </xsl:element>
                     
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <!-- (no @normal to match) use did/origination form -->
               
               <xsl:element name="name">
                  <xsl:attribute name="display" select="'true'" />
                  <xsl:attribute name="displayForm" select="normalize-space(.)" />
                  <xsl:element name="shortForm">
                     <xsl:value-of select="normalize-space(.)" />
                  </xsl:element>
               </xsl:element>
               
            </xsl:otherwise>
         </xsl:choose>
         
      </xsl:for-each>
      
   </xsl:template>
   
   <!--names in index points-->
   <xsl:template match="*:controlaccess/*:persname[normalize-space(@role)]">
      
      <xsl:call-template name="process-persname"/>
      
   </xsl:template>
   
   
   <xsl:template match="*:controlaccess/*:persname[not(normalize-space(@role))]">
      <xsl:variable name="persname" select="normalize-space(.)"/>
      
      <xsl:choose>
         <xsl:when test="../../*:did/*:origination/*:persname[@normal=$persname]">
            <!-- corresponding did/origination/persname - already handled as creator, so ignore -->
         </xsl:when>
         <xsl:when test="../../*:controlaccess/*:persname[@normal=$persname][@role='aut' or @role='rcp']">
            <!-- already handled as author or recipient, so ignore -->            
         </xsl:when>
         <xsl:otherwise>
            <!-- use controlaccess/persname form -->
            <xsl:call-template name="process-persname"/>
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   <xsl:template name="process-persname">
      
      <xsl:choose>
         <xsl:when test="@rules='AACR2'">
            <!-- AACR2 name (from VIAF) so always use -->
            
            <xsl:element name="name">
               <xsl:attribute name="display" select="'true'" />
               <xsl:attribute name="displayForm" select="normalize-space(.)" />
               <xsl:element name="fullForm">
                  <xsl:value-of select="normalize-space(.)" />
               </xsl:element>               
               <xsl:if test="@source">                           
                  <xsl:element name="authority">
                     <xsl:value-of select="@source" />
                  </xsl:element>
               </xsl:if>
               <xsl:if test="@authfilenumber">
                  <xsl:element name="valueURI">
                     <xsl:value-of select="@authfilenumber" />
                  </xsl:element>
               </xsl:if>
            </xsl:element>
            
         </xsl:when>
         <xsl:when test="@source='ncarules'">
            <!-- NCA Rules name : use if no AACR2 name -->
            <xsl:variable name="persnormal" select="normalize-space(@normal)"/>
            
            <!--
               <xsl:comment>persnormal = <xsl:value-of select="$persnormal"/></xsl:comment>
               <xsl:comment>match = <xsl:value-of select="normalize-space(../../*:controlaccess/*[@normal=$persnormal and @rules='AACR2'])"/></xsl:comment>
            -->
            <!--           <xsl:if test="not(normalize-space(../../*:controlaccess/*[@normal=$persnormal and @rules='AACR2']))"> -->
            <xsl:if test="empty(../../*:controlaccess/*[@normal=$persnormal and @rules='AACR2'])">
               
               <xsl:element name="name">
                  <xsl:attribute name="display" select="'true'" />
                  <xsl:attribute name="displayForm" select="normalize-space(.)" />
                  <xsl:element name="fullForm">
                     <xsl:value-of select="normalize-space(.)" />
                  </xsl:element>
                  <xsl:if test="normalize-space(@source)">                           
                     <xsl:element name="authority">
                        <xsl:value-of select="@source" />
                     </xsl:element>
                  </xsl:if>
                  <xsl:if test="normalize-space(@authfilenumber)">
                     <xsl:element name="valueURI">
                        <xsl:value-of select="@authfilenumber" />
                     </xsl:element>
                  </xsl:if>                           
               </xsl:element>
               
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <!-- Not AACR2 or NCA Rules -->
            <xsl:element name="name">
               <xsl:attribute name="display" select="'true'" />
               <xsl:attribute name="displayForm" select="normalize-space(.)" />
               <xsl:element name="shortForm">
                  <xsl:value-of select="normalize-space(.)" />
               </xsl:element>                        
            </xsl:element>                                       
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   <xsl:template match="*:controlaccess/*:corpname[normalize-space(@role)]">
      
      <xsl:call-template name="process-corpname"/>
      
   </xsl:template>
   
   <xsl:template match="*:controlaccess/*:corpname[not(@role)]">
      <xsl:variable name="corpname" select="normalize-space(.)"/>
      
      <xsl:choose>
         <xsl:when test="../../*:did/*:origination/*:corpname[@normal=$corpname]">
            <!-- corresponding did/origination/corpname - already handled as creator, so ignore -->
         </xsl:when>
         <xsl:otherwise>
            <!-- use controlaccess/corpname form -->
            <xsl:call-template name="process-corpname"/>            
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   <xsl:template name="process-corpname">
      
      <xsl:choose>
         <xsl:when test="@rules='AACR2'">
            <!-- AACR2 name (from VIAF) so always use -->
            
            <xsl:element name="name">
               <xsl:attribute name="display" select="'true'" />
               <xsl:attribute name="displayForm" select="normalize-space(.)" />
               <xsl:element name="fullForm">
                  <xsl:value-of select="normalize-space(.)" />
               </xsl:element>               
               <xsl:if test="@source">                           
                  <xsl:element name="authority">
                     <xsl:value-of select="@source" />
                  </xsl:element>
               </xsl:if>
               <xsl:if test="@authfilenumber">
                  <xsl:element name="valueURI">
                     <xsl:value-of select="@authfilenumber" />
                  </xsl:element>
               </xsl:if>
            </xsl:element>
            
         </xsl:when>
         <xsl:when test="@source='ncarules'">
            <!-- NCA Rules name : use if no AACR2 name -->
            <xsl:variable name="corpnormal" select="normalize-space(@normal)"/>
            
            <!--            <xsl:if test="not(normalize-space(../../*:controlaccess/*[@normal=$corpnormal and @rules='AACR2']))"> -->
            <xsl:if test="empty(../../*:controlaccess/*[@normal=$corpnormal and @rules='AACR2'])">
               
               <xsl:element name="name">
                  <xsl:attribute name="display" select="'true'" />
                  <xsl:attribute name="displayForm" select="normalize-space(.)" />
                  <xsl:element name="fullForm">
                     <xsl:value-of select="normalize-space(.)" />
                  </xsl:element>               
                  <xsl:if test="normalize-space(@source)">                           
                     <xsl:element name="authority">
                        <xsl:value-of select="@source" />
                     </xsl:element>
                  </xsl:if>
                  <xsl:if test="normalize-space(@authfilenumber)">
                     <xsl:element name="valueURI">
                        <xsl:value-of select="@authfilenumber" />
                     </xsl:element>
                  </xsl:if>                           
               </xsl:element>
               
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <!-- Not AACR2 or NCA Rules -->
            <xsl:element name="name">
               <xsl:attribute name="display" select="'true'" />
               <xsl:attribute name="displayForm" select="normalize-space(.)" />
               <xsl:element name="shortForm">
                  <xsl:value-of select="normalize-space(.)" />
               </xsl:element>                        
            </xsl:element>                                       
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   <!--places-->
   <xsl:template name="get-places">
      
      <xsl:if test="normalize-space(string-join(*:controlaccess/*:geogname[not(@role) or @role='subj'], ' '))">
         <xsl:element name="places">
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:apply-templates select="*:controlaccess/*:geogname[not(@role) or @role='subj']" />
         </xsl:element>
      </xsl:if>
      
      <xsl:if test="normalize-space(string-join(*:controlaccess/*:geogname[@role='dest'], ' '))">
         
         <xsl:element name="destinations">
            <xsl:attribute name="display" select="'true'" />            
                  
            <xsl:apply-templates select="*:controlaccess/*:geogname[@role='dest']" />
         </xsl:element>
      </xsl:if>
   
   </xsl:template>
   
   <xsl:template match="*:controlaccess/*:geogname">
      
      <xsl:choose>
         <xsl:when test="@source='Getty_thesaurus'">
            <!-- Getty term so always use -->
            
            <xsl:element name="place">
               <xsl:attribute name="display" select="'true'" />
               <xsl:attribute name="displayForm" select="normalize-space(.)" />
               <xsl:element name="fullForm">
                  <xsl:value-of select="normalize-space(.)" />
               </xsl:element>               
               <xsl:if test="@source">                           
                  <xsl:element name="authority">
                     <xsl:value-of select="@source" />
                  </xsl:element>
               </xsl:if>
               <xsl:if test="@authfilenumber">
                  <xsl:element name="valueURI">
                     <xsl:value-of select="@authfilenumber" />
                  </xsl:element>
               </xsl:if>
            </xsl:element>
            
         </xsl:when>
         <xsl:when test="@source='http://geonames.org/'">
            <!-- Geonames term : always use, but display only if no Getty term -->
            <!-- Note: for places the @normal "links" go from Getty TGN to Geonames -->
            <xsl:variable name="placenormal" select="normalize-space(.)"/>
                           
                  <xsl:choose>
                     <!-- Have to allow for multiple Getty TGN terms w different roles -->
                     <xsl:when test="normalize-space(../../*:controlaccess/*[@normal=$placenormal and @source='Getty_thesaurus'][1])">
                        <!-- 
                           Really want to include Geonames term here with display=false but viewer tries to display it so suppress as workaround 
                           <xsl:element name="place">
                           <xsl:attribute name="display" select="'false'" /> 
                        <xsl:element name="fullForm">
                           <xsl:value-of select="normalize-space(.)" />
                        </xsl:element>               
                        <xsl:if test="normalize-space(@source)">                           
                           <xsl:element name="authority">
                              <xsl:value-of select="@source" />
                           </xsl:element>
                        </xsl:if>
                        <xsl:if test="normalize-space(@authfilenumber)">
                           <xsl:element name="valueURI">
                              <xsl:value-of select="@authfilenumber" />
                           </xsl:element>
                        </xsl:if>
                        </xsl:element>
                        -->
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:element name="place">
                           <xsl:attribute name="display" select="'true'" />                        
                           <xsl:attribute name="displayForm" select="normalize-space(.)" />
                           <xsl:element name="fullForm">
                              <xsl:value-of select="normalize-space(.)" />
                           </xsl:element>               
                           <xsl:if test="normalize-space(@source)">                           
                              <xsl:element name="authority">
                                 <xsl:value-of select="@source" />
                              </xsl:element>
                           </xsl:if>
                           <xsl:if test="normalize-space(@authfilenumber)">
                              <xsl:element name="valueURI">
                                 <xsl:value-of select="@authfilenumber" />
                              </xsl:element>
                           </xsl:if>
                        </xsl:element>
                     </xsl:otherwise>                        
                  </xsl:choose>
               
         </xsl:when>
         <xsl:otherwise>
            <!-- Not Getty TGN or Geonames -->
            <xsl:element name="place">
               <xsl:attribute name="display" select="'true'" />
               <xsl:attribute name="displayForm" select="normalize-space(.)" />
               <xsl:element name="shortForm">
                  <xsl:value-of select="normalize-space(.)" />
               </xsl:element>                        
            </xsl:element>                                       
         </xsl:otherwise>
      </xsl:choose>

   </xsl:template>
   
   <!--subjects-->
   <xsl:template name="get-subjects">
      
      <xsl:if test="normalize-space(string-join(*:controlaccess/*:subject, ' '))">
         <xsl:element name="subjects">
            <xsl:attribute name="display" select="'true'" />            
            <xsl:apply-templates select="*:controlaccess/*:subject" />
         </xsl:element>
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template match="*:controlaccess/*:subject">
      
      <xsl:choose>
         <xsl:when test="@rules='LCSH'">
            <!-- LCSH term (from id.loc.gov) so always use -->
            
            <xsl:element name="subject">
               <xsl:attribute name="display" select="'true'" />
               <xsl:attribute name="displayForm" select="normalize-space(.)" />
               <xsl:element name="fullForm">
                  <xsl:value-of select="normalize-space(.)" />
               </xsl:element>               
               <xsl:if test="@source">                           
                  <xsl:element name="authority">
                     <xsl:value-of select="@source" />
                  </xsl:element>
               </xsl:if>
               <xsl:if test="@authfilenumber">
                  <xsl:element name="valueURI">
                     <xsl:value-of select="@authfilenumber" />
                  </xsl:element>
               </xsl:if>
            </xsl:element>
            
         </xsl:when>
         <xsl:when test="@source='UNESCO_thesaurus'">
            <!-- UNESCO Theasurus term : use if no LCSH term -->
            <xsl:variable name="subjectnormal" select="normalize-space(@normal)"/>
            
            <xsl:if test="not(normalize-space(../../*:controlaccess/*[@normal=$subjectnormal and @rules='LCSH']))">
               
               <xsl:element name="subject">
                  <xsl:attribute name="display" select="'true'" />
                  <xsl:attribute name="displayForm" select="normalize-space(.)" />
                  <xsl:element name="fullForm">
                     <xsl:value-of select="normalize-space(.)" />
                  </xsl:element>               
                  <xsl:if test="normalize-space(@source)">                           
                     <xsl:element name="authority">
                        <xsl:value-of select="@source" />
                     </xsl:element>
                  </xsl:if>
                  <xsl:if test="normalize-space(@authfilenumber)">
                     <xsl:element name="valueURI">
                        <xsl:value-of select="@authfilenumber" />
                     </xsl:element>
                  </xsl:if>                           
               </xsl:element>
               
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <!-- Not UNESCO or LCSH -->
            <xsl:element name="subject">
               <xsl:attribute name="display" select="'true'" />
               <xsl:attribute name="displayForm" select="normalize-space(.)" />
               <xsl:element name="shortForm">
                  <xsl:value-of select="normalize-space(.)" />
               </xsl:element>
            
               
            </xsl:element>                                       
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   <!--events-->
   <xsl:template name="get-events">
      
      <xsl:if test="normalize-space(*:did/*:unitdate)">
         <xsl:element name="creations">
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:element name="event">
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:element name="type">
                  <xsl:text>creation</xsl:text>
               </xsl:element>
               <xsl:apply-templates select="*:did/*:unitdate" />
               
               <xsl:if test="normalize-space(string-join(*:controlaccess/*:geogname[@role='orig'], ' '))">
                  <xsl:element name="places">
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:apply-templates select="*:controlaccess/*:geogname[@role='orig']" />
                  </xsl:element>
               </xsl:if>
               
            </xsl:element>
         </xsl:element>
         
      </xsl:if>

      <!-- Considered receipt-as-event with no date to accommodate destination place but opted for simple thing-places relation instead (see get-places) -->
         
   </xsl:template>
   
   <!--dates-->
   <xsl:template match="*:did/*:unitdate">
            
      <xsl:if test="matches(normalize-space(@normal),'1\d{3}((0\d)|(1[0-2]))(([0-2]\d)|(3[0-1]))-1\d{3}((0\d)|(1[0-2]))(([0-2]\d)|(3[0-1]))')">
         
         <xsl:variable name="start" select="substring-before(normalize-space(@normal), '-')"/>
         <xsl:variable name="end" select="substring-after(normalize-space(@normal), '-')"/>
         
         <xsl:element name="dateStart">
            <xsl:value-of select="concat(substring($start, 1, 4), '-', substring($start, 5, 2), '-', substring($start, 7, 2))"/>
         </xsl:element>
         
         <xsl:element name="dateEnd">
            <xsl:value-of select="concat(substring($end, 1, 4), '-', substring($end, 5, 2), '-', substring($end, 7, 2))"/>
         </xsl:element>
         
         <xsl:element name="dateDisplay">
            <xsl:attribute name="display" select="'true'" />            
            <xsl:attribute name="displayForm" select="normalize-space(.)"/>            
            <xsl:value-of select="normalize-space(.)" />            
         </xsl:element>
         
      </xsl:if>
      
   </xsl:template>
   
   <!--physical description-->
   <xsl:template name="get-physdesc">
      
      <xsl:if test="normalize-space(*:did/*:physdesc/*:extent)">
         
         <xsl:element name="extent">
            <xsl:attribute name="display" select="'true'" />            
            <xsl:attribute name="displayForm" select="normalize-space(*:did/*:physdesc/*:extent)"/>            
            <xsl:value-of select="normalize-space(*:did/*:physdesc/*:extent)" />             
         </xsl:element>
                  
      </xsl:if>

      <xsl:if test="normalize-space(*:did/*:physdesc/*:genreform)">
         
         <xsl:element name="material">
            <xsl:attribute name="display" select="'true'" />            
            <xsl:attribute name="displayForm" select="normalize-space(*:did/*:physdesc/*:genreform)"/>            
            <xsl:value-of select="normalize-space(*:did/*:physdesc/*:genreform)" />             
         </xsl:element>
      
      </xsl:if>
   
   </xsl:template>
   
   <!--notes-->
   <xsl:template name="get-notes">
      
      <xsl:if test="normalize-space(*:odd)">
         
         <xsl:element name="notes">
            <xsl:attribute name="display" select="'true'" />            
            
            <xsl:apply-templates select="*:odd" />
            
         </xsl:element>
         
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template match="*:odd">
      
      <xsl:element name="note">
            
         <xsl:variable name="note">
            <xsl:apply-templates select="*" mode="html" />
         </xsl:variable>
            
         <xsl:attribute name="display" select="'true'" />            
         <xsl:attribute name="displayForm" select="normalize-space($note)" />         
            
         <xsl:value-of select="normalize-space($note)" />
            
      </xsl:element>
      
   </xsl:template>
   
   
   <!--miscellaneous ead fields-->
   <xsl:template name="get-originals" >
      
      <xsl:if test="normalize-space(*:originalsloc)">
         
         <xsl:element name="originals">
            <xsl:attribute name="display" select="'true'" />            
            
            <xsl:apply-templates select="*:originalsloc" />
            
         </xsl:element>
         
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template match="*:originalsloc">
      
      <xsl:element name="relatedmaterial">
         
         <xsl:variable name="original">
            <xsl:apply-templates select="*" mode="html" />
         </xsl:variable>
         
         <xsl:attribute name="display" select="'true'" />            
         <xsl:attribute name="displayForm" select="normalize-space($original)" />         
         
         <xsl:value-of select="normalize-space($original)" />
         
      </xsl:element>
      
   </xsl:template>
   
   <xsl:template name="get-altforms" >
      
      <xsl:if test="normalize-space(*:altformavail)">
         
         <xsl:element name="altforms">
            <xsl:attribute name="display" select="'true'" />            
            
            <xsl:apply-templates select="*:altformavail" />
            
         </xsl:element>
         
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template match="*:altformavail">
      
      <xsl:element name="altform">
         
         <xsl:variable name="altform">
            <xsl:apply-templates select="*" mode="html" />
         </xsl:variable>
         
         <xsl:attribute name="display" select="'true'" />            
         <xsl:attribute name="displayForm" select="normalize-space($altform)" />         
         
         <xsl:value-of select="normalize-space($altform)" />
         
      </xsl:element>
      
   </xsl:template>
   
   <xsl:template name="get-related" >
      
      <xsl:if test="normalize-space(*:relatedmaterial)">
         
         <xsl:element name="relatedmaterials">
            <xsl:attribute name="display" select="'true'" />            
            
            <xsl:apply-templates select="*:relatedmaterial" />
            
         </xsl:element>
         
      </xsl:if>
   
   </xsl:template>
   
   <xsl:template match="*:relatedmaterial">
      
      <xsl:element name="relatedmaterial">
         
         <xsl:variable name="relatedmaterial">
            <xsl:apply-templates select="*" mode="html" />
         </xsl:variable>
         
         <xsl:attribute name="display" select="'true'" />            
         <xsl:attribute name="displayForm" select="normalize-space($relatedmaterial)" />         
         
         <xsl:value-of select="normalize-space($relatedmaterial)" />
         
      </xsl:element>
      
   </xsl:template>

   
   
   <!--bibliography-->
   <xsl:template name="get-biblio">
   
      <xsl:if test="normalize-space(*:bibliography)">
         
         <xsl:element name="bibliographies">
            <xsl:attribute name="display" select="'true'" />            
            
            <xsl:apply-templates select="*:bibliography" />
            
         </xsl:element>
         
      </xsl:if>
   
   </xsl:template>
   
   <xsl:template match="*:bibliography">
      
      <xsl:element name="bibliography">
         
         <xsl:variable name="bibliography">
            <xsl:apply-templates select="*" mode="html" />
         </xsl:variable>
         
         <xsl:attribute name="display" select="'true'" />            
         <xsl:attribute name="displayForm" select="normalize-space($bibliography)" />         
         
         <xsl:value-of select="normalize-space($bibliography)" />
         
      </xsl:element>
      
   </xsl:template>
   
   <!--rights-->
   <xsl:template name="get-rights">
      
      <xsl:element name="displayImageRights">
         <xsl:value-of select="normalize-space(//*:userestrict[@type='displayImageRights'])"/>
      </xsl:element>
      
      <xsl:element name="downloadImageRights">
         <xsl:value-of select="normalize-space(//*:userestrict[@type='downloadImageRights'])"/>
      </xsl:element>
      
      <xsl:element name="imageReproPageURL">
         <xsl:value-of select="cudl:get-imageReproPageURL(normalize-space(//*:did/*:repository))"/>
      </xsl:element>
      
      <xsl:element name="metadataRights">
         <xsl:value-of select="normalize-space(//*:userestrict[@type='metadataRights'])"/>
      </xsl:element>
   
   </xsl:template>
   
   <!--metadata about document authorship-->
   <xsl:template name="get-metadata">
      
      <xsl:if test="/*:ead/*:eadheader/*:filedesc/*:titlestmt/*:author">
         
         <xsl:element name="dataRevisions">
            
            <xsl:variable name="dataRevisions">
               <xsl:choose>
                  <xsl:when test="/*:ead/*:eadheader/*:filedesc/*:titlestmt/*:author//*:persname">
                     <xsl:for-each select="/*:ead/*:eadheader/*:filedesc/*:titlestmt/*:author//*:persname">
                        <xsl:value-of select="."/>
                        <xsl:if test="not(position()=last())">
                           <xsl:text>, </xsl:text>
                        </xsl:if>
                     </xsl:for-each>                     
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:for-each select="/*:ead/*:eadheader/*:filedesc/*:titlestmt/*:author">
                        <xsl:value-of select="."/>
                        <xsl:if test="not(position()=last())">
                           <xsl:text>, </xsl:text>
                        </xsl:if>
                     </xsl:for-each>                     
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            
            <xsl:attribute name="display" select="'true'" />            
            <xsl:attribute name="displayForm" select="normalize-space($dataRevisions)" />         
            
            <xsl:value-of select="normalize-space($dataRevisions)" />
            
         </xsl:element>
         
      </xsl:if>
      
   </xsl:template>
   
   <!--document thumbnail-->
   <xsl:template name="get-thumbnail">
      
      <xsl:for-each select="/*:ead/*:archdesc/*:daogrp[@role='document-thumbnail']/*:daoloc[1]">
         <xsl:variable name="imageURI" select="normalize-space(@href)"/>
         <xsl:variable name="imageURIShort" select="replace($imageURI, 'http://cudl.lib.cam.ac.uk/(newton|content)','/content')"/>
         <xsl:element name="thumbnailUrl">
            <xsl:value-of select="$imageURIShort"/>                  
         </xsl:element>

         <xsl:element name="thumbnailOrientation">
            <xsl:choose>
               <xsl:when test="normalize-space(@altrender)">
                  <xsl:value-of select="normalize-space(@altrender)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>portrait</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
         
      </xsl:for-each>
         
   </xsl:template>
   
   <!--collection membership-->
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
   
   <!-- number of pages -->
   <xsl:template name="get-numberOfPages">
      <numberOfPages>
         <xsl:value-of select="count(//*:archdesc/*:daogrp[@role='download']/*:daoloc)"/>
      </numberOfPages>
   </xsl:template>
   
   <!--pages with associated resources-->
   <xsl:template name="make-pages">
      
      <xsl:element name="pages">
         
         <xsl:for-each select="/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc">
            
            
            <xsl:variable name="imageLabel" select="@label"/>
            
            <xsl:variable name="imageURI" select="normalize-space(@href)"/>
            <xsl:variable name="imageURIShort" select="replace($imageURI, 'http://cudl.lib.cam.ac.uk/(newton|content)','/content')"/>
            
            <xsl:variable name="thumbnailURI" select="/*:ead/*:archdesc/*:daogrp[@role='thumbnail']/*:daoloc[@label=$imageLabel][1]/@href"/>
            <xsl:variable name="thumbnailURIShort" select="replace($thumbnailURI, 'http://cudl.lib.cam.ac.uk/(newton|content)','/content')"/>
            
            <xsl:variable name="thumbnailOrientation" select="/*:ead/*:archdesc/*:daogrp[@role='thumbnail']/*:daoloc[@label=$imageLabel]/@altrender"/>
            
            <xsl:element name="page">
               <xsl:element name="label">
                  <xsl:value-of select="@label"/>                  
               </xsl:element>
               <xsl:element name="physID">
                  <xsl:value-of select="@id"/>                  
               </xsl:element>
               <xsl:element name="sequence">
                  <xsl:value-of select="position()"/>
               </xsl:element>
               <xsl:element name="displayImageURL">
                  <xsl:value-of select="replace($imageURIShort, '.jpg', '.dzi')"/>                  
               </xsl:element>
               <xsl:element name="downloadImageURL">
                  <xsl:value-of select="$imageURIShort"/>                  
               </xsl:element>
               <xsl:element name="thumbnailImageURL">
                  <xsl:value-of select="$thumbnailURIShort"/>                  
               </xsl:element>
               <xsl:element name="thumbnailImageOrientation">
                  <xsl:value-of select="$thumbnailOrientation"/>                  
               </xsl:element>
               
               
               <!-- Now check for transcription for this page by matching on @label - may not be transcription for every page -->
               <!--for the json, just knock off the cudl bit-->
               
               <xsl:for-each select="/*:ead/*:archdesc/*:daogrp[@role='transcription-normal']/*:daoloc[@label=$imageLabel]">
                  <xsl:element name="transcriptionNormalisedURL">
                     <xsl:value-of select="replace(@href, 'http://services.cudl.lib.cam.ac.uk', '')"/>
                  </xsl:element>                  
               </xsl:for-each>
                                 
               <xsl:for-each select="/*:ead/*:archdesc/*:daogrp[@role='transcription-diplomatic']/*:daoloc[@label=$imageLabel]">
                  <xsl:element name="transcriptionDiplomaticURL">
                     <xsl:value-of select="replace(@href, 'http://services.cudl.lib.cam.ac.uk', '')"/>
                  </xsl:element>                  
               </xsl:for-each>
            </xsl:element>
         
         </xsl:for-each>
         
      </xsl:element>
         
   </xsl:template>   
   
   <!--logical structures for navigation-->
   <xsl:template name="make-logical-structures">
      
      <xsl:element name="logicalStructures">
         
         <xsl:apply-templates select="*:ead/*:archdesc" mode="logical" />
      
      </xsl:element>
   
   </xsl:template>
   
   <!--top level structure-->
   <xsl:template match="*:archdesc" mode="logical">      
      
      <xsl:call-template name="make-logical-structure" />      
      
   </xsl:template>
   <!--lower level structures-->
   <xsl:template match="*:c|*:c01|*:c02|*:c03|*:c04|*:c05|*:c06|*:c07|*:c08|*:c09|*:c10|*:c11|*:c12" mode="logical">
      
      <xsl:call-template name="make-logical-structure" />
           
   </xsl:template>
   
   
   <xsl:template name="make-logical-structure">
      
      <xsl:variable name="normunitid" select="translate(normalize-space(*:did/*:unitid[not(@type)]), ' .:/', '----')" />
            
      <xsl:element name="logicalStructure">
         
         <xsl:element name="descriptiveMetadataID"><xsl:value-of select="$normunitid"/></xsl:element>

         <xsl:element name="label">
            <xsl:value-of select="normalize-space(*:did/*:unittitle)" />
         </xsl:element>

         <xsl:choose>
            <xsl:when test="*:daogrp[@role='download']/*:daoloc">
               <xsl:element name="startPageLabel">
                  <xsl:value-of select="*:daogrp[@role='download']/*:daoloc[1]/@label"/>
               </xsl:element>
               
               <xsl:variable name="startPageHref" select="*:daogrp[@role='download']/*:daoloc[1]/@href"/>
               
               <xsl:element name="startPagePosition">
                  <xsl:for-each select="/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@href=$startPageHref]">
                     <xsl:value-of select="1 + count(preceding-sibling::*:daoloc)"/>
                   </xsl:for-each>
               </xsl:element>
               
               <xsl:element name="startPageID">
                  <xsl:value-of select="/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@href=$startPageHref]/@id" />
               </xsl:element>
               
               <xsl:element name="endPageLabel">
                  <xsl:value-of select="*:daogrp[@role='download']/*:daoloc[last()]/@label"/>
               </xsl:element>

               <xsl:variable name="endPageHref" select="*:daogrp[@role='download']/*:daoloc[last()]/@href"/>
               
               <xsl:element name="endPagePosition">
                  <xsl:for-each select="/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@href=$endPageHref]">
                     <xsl:value-of select="1 + count(preceding-sibling::*:daoloc)"/>
                  </xsl:for-each>
               </xsl:element>
               
               <xsl:element name="endPageID">
                  <xsl:value-of select="/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@href=$endPageHref]/@id" />
               </xsl:element>
            
            </xsl:when>
            <xsl:otherwise>
               <xsl:element name="startPageLabel">
                  <xsl:value-of select="'1'"/>
               </xsl:element>
            </xsl:otherwise>
            
         </xsl:choose>
         
         <xsl:if test="*:dsc/*:c|dsc/c01|*:c|*:c01|*:c02|*:c03|*:c04|*:c05|*:c06|*:c07|*:c08|*:c09|*:c10|*:c11|*:c12">
            <xsl:element name="children"> 
               <xsl:apply-templates select="*:dsc/*:c|dsc/c01|*:c|*:c01|*:c02|*:c03|*:c04|*:c05|*:c06|*:c07|*:c08|*:c09|*:c10|*:c11|*:c12" mode="logical"/>
            </xsl:element>
         </xsl:if>
         
      </xsl:element>
      
   </xsl:template>

   <!--sets flags and pulls transcription text for indexing-->
   <!--we'll have to put translation processing in here too-->
   
   
   <xsl:template name="make-transcription-pages">
      
      <xsl:choose>
         <xsl:when test="/*:ead/*:archdesc/*:daogrp[@role='transcription-normal']/*:daoloc and /*:ead/*:archdesc/*:daogrp[@role='transcription-diplomatic']/*:daoloc">            
            <xsl:element name="useTranscriptions">true</xsl:element>
            <xsl:element name="useNormalisedTranscriptions">true</xsl:element>
            <xsl:element name="useDiplomaticTranscriptions">true</xsl:element>
         </xsl:when>
         <xsl:when test="/*:ead/*:archdesc/*:daogrp[@role='transcription-normal']/*:daoloc">            
            <xsl:element name="useTranscriptions">true</xsl:element>
            <xsl:element name="useNormalisedTranscriptions">true</xsl:element>
         </xsl:when>
         <xsl:when test="/*:ead/*:archdesc/*:daogrp[@role='transcription-diplomatic']/*:daoloc">            
            <xsl:element name="useTranscriptions">true</xsl:element>
            <xsl:element name="useDiplomaticTranscriptions">true</xsl:element>
         </xsl:when>
         <xsl:otherwise>
            <xsl:element name="useTranscriptions">false</xsl:element>            
         </xsl:otherwise>
      </xsl:choose>
      
      <!-- for indexing by XTF -->
      
      <!--this indexes any list items containing at least one archref element-->
      <xsl:for-each select="//*:list/*:item[*:archref]">
         
            
         <xsl:variable name="identifier">
            <xsl:value-of select=".//*:archref[1]/@identifier"/>
         </xsl:variable>
         
         <xsl:variable name="linkFileID">
            
            <xsl:value-of select="substring-before($identifier, ':')"/>
            
         </xsl:variable>
         
         <xsl:if test="$fileID=$linkFileID">
            
            <xsl:variable name="label" select="substring-after($identifier, ':')"/>
            
            <xsl:variable name="startPageLabel">
               <xsl:choose>
                  <xsl:when test="contains($label, '-')">
                     <xsl:value-of select="substring-before($label, '-')"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="$label"/>
                  </xsl:otherwise>
               </xsl:choose>
               
               
            </xsl:variable>
            
            <xsl:variable name="startPagePosition">
               
               <xsl:for-each select="//*:archdesc/*:daogrp[@role='download']/*:daoloc" >
                  <xsl:if test="@label = $startPageLabel">
                     <xsl:value-of select="position()" />                                
                  </xsl:if>
               </xsl:for-each>
               
            </xsl:variable>
            
            <xsl:if test="normalize-space($startPagePosition)">
               
               <listItemPage>
                  <xsl:attribute name="xtf:subDocument" select="concat('listItem-', position())" />
                  
                  
                  <fileID>
                     <xsl:value-of select="$fileID"/>          
                  </fileID>
               
                  <xsl:variable name="normunitid" select="translate(normalize-space(//*:archdesc/*:did/*:unitid[not(@type)]), ' .:/', '----')" />
                  
                  <xsl:element name="dmdID">
                     <xsl:attribute name="xtf:noindex">true</xsl:attribute>
                     <xsl:value-of select="$normunitid"/>
                  </xsl:element>
               
               
               
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
                  
            </xsl:if>
            
         </xsl:if>
            
      </xsl:for-each>
      
      <!--transcription indexing-->
      <xsl:for-each select="/*:ead/*:archdesc/*:daogrp[@role='transcription-normal' or @role='transcription-diplomatic']/*:daoloc">
         
               <transcriptionPage>
                  <xsl:attribute name="xtf:subDocument" select="concat('sub-', normalize-space(@id))" />
                  <fileID>
                     <xsl:value-of select="$fileID"/>          
                  </fileID>
                  
                  <!-- Ideally we'd have the transcription daogrp/daoloc at the appropriate level in the EAD tree, but in the data we actually have it only at the top (archdesc) level, so this will always be the archdesc unitid. This means that when we come to do facet inheritance in prefilterCommon, we won't get stuff from lower down the tree --> 
                  <xsl:variable name="normunitid" select="translate(normalize-space(../../*:did/*:unitid[not(@type)]), ' .:/', '----')" />
                                    
                  <xsl:element name="dmdID"><xsl:value-of select="$normunitid"/></xsl:element>      
                  
                  <startPageLabel>
                     <xsl:value-of select="normalize-space(@label)"/>
                  </startPageLabel>
                  
                  <startPage>
                     <!--position() won't give the start page as not all pages are transcribed. need to look back at the list of all pages-->
                     
                     <!--<xsl:value-of select="position()"/>-->
                     
                     <xsl:variable name="transcriptionLabel" select="@label"/>
                     <!--gets the position of the page within doc by looking at the corresponding page id-->
                     
                     <xsl:choose>
                        <xsl:when test="normalize-space(substring-after(/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=$transcriptionLabel]/@id, '-'))">
                           <xsl:value-of select="substring-after(/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=$transcriptionLabel]/@id, '-')"/>                           
                        </xsl:when>
                        <xsl:otherwise>
                           <!-- default if page image data missing -->
                           <xsl:message>Error: failed to match transcription page label to page image label</xsl:message> 
                           <xsl:text>1</xsl:text>                           
                        </xsl:otherwise>
                     </xsl:choose>
                     
                  </startPage>
                  
                  <title>
                     <xsl:value-of select="normalize-space(@label)"/>
                  </title>
                  
                  <xsl:variable name="transcriptionURI" select="cudl:transcription-uri(@href)"/>
                  
                  
                  <!-- Map whitespace to single space - non-breaking-spaces need special handling as not mapped by normalize-space -->
                  <transcriptionText>
                  
                     
                     <xsl:variable name="transcriptionText">
                              
                              <xsl:variable name="transcriptionAllText" select="document($transcriptionURI)"/>
                              <xsl:value-of select="$transcriptionAllText//*:body"/>
                        
                     </xsl:variable>
                     
                     <xsl:value-of select="normalize-space(translate($transcriptionText, '&#xa0;', ' '))"/> 
                    
                     <!--<xsl:message select="normalize-space(translate($transcriptionText, '&#xa0;', ' '))"/>-->
                
                  </transcriptionText>
                  
               </transcriptionPage>
         
      </xsl:for-each>
      
   </xsl:template>
   
   <!--index processing templates-->
   
   <xsl:template match="*" mode="index">
      
      <xsl:apply-templates mode="index"/>
      
   </xsl:template>
   
   <xsl:template match="text()" mode="index">
      
      
      <xsl:copy-of select="."/>
      
      
   </xsl:template>
   
   <!--html processing templates-->
   
   <xsl:template match="*:p" mode="html">
      
      <xsl:text>&lt;p&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/p&gt;</xsl:text> 
      
   </xsl:template>
   
   <xsl:template match="*:list" mode="html">
      
      <xsl:text>&lt;ul&gt;</xsl:text>
         <xsl:apply-templates mode="html"/>
      <xsl:text>&lt;/ul&gt;</xsl:text>
      
      
   </xsl:template>
   
   
   <xsl:template match="*:item" mode="html">
      <xsl:text>&lt;li&gt;</xsl:text>
         <xsl:apply-templates mode="html"/>
      <xsl:text>&lt;/li&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="text()" mode="html">
      
      <xsl:value-of select="."/>
      
   </xsl:template>
   
   <xsl:template match="*:lb" mode="html">
      
      <xsl:text>&lt;br /&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:emph" mode="html">
      
      <xsl:text>&lt;i&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*[@render='bold']" mode="html">
      
      <xsl:text>&lt;b&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/b&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*[@render='italic']" mode="html">
      
      <xsl:text>&lt;i&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*[@render='bolditalic']" mode="html">
      
      <xsl:text>&lt;b&gt;&lt;i&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;&lt;/b&gt;</xsl:text>
      
   </xsl:template>

   <xsl:template match="*:extref[not(*:persname|*:corpname|*:geogname)]" mode="html">
      
      <xsl:apply-templates mode="html" />
      
      <xsl:choose>
         <xsl:when test="normalize-space(@href)">
            <xsl:text> [</xsl:text>
            <xsl:text>&lt;a target=&apos;_blank&apos; class=&apos;externalLink&apos; href=&apos;</xsl:text>
            <xsl:value-of select="normalize-space(@href)" />
            <xsl:text>&apos;&gt;</xsl:text>
            <xsl:choose>
               <xsl:when test="normalize-space(@role)='nmm'">
                  <xsl:text>&lt;img title="Link to RMG" alt=&apos;RMG icon&apos; class=&apos;nmm_icon&apos; src=&apos;/images/general/nmm_small.png&apos;/&gt;</xsl:text>
               </xsl:when>
               <xsl:when test="normalize-space(@role)">
                  <xsl:value-of select="normalize-space(@role)" />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>link</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&lt;/a&gt;</xsl:text>
            <xsl:text>] </xsl:text>
         </xsl:when>
         <xsl:otherwise />
      </xsl:choose>
      
   </xsl:template>
   
   <xsl:template match="*:extref[*:persname|*:corpname|*:geogname]" mode="html">
      
      <xsl:apply-templates select="*:persname|*:corpname|*:geogname" mode="html"/>
      <xsl:choose>
         <xsl:when test="normalize-space(@href)">
            <xsl:text> [</xsl:text>
            <xsl:text>&lt;a target=&apos;_blank&apos; class=&apos;externalLink&apos; href=&apos;</xsl:text>
            <xsl:value-of select="normalize-space(@href)" />
            <xsl:text>&apos;&gt;</xsl:text>
            <xsl:choose>
               <xsl:when test="normalize-space(@role)='nmm'">
                  <xsl:text>&lt;img title="Link to RMG" alt=&apos;NMM icon&apos; class=&apos;nmm_icon&apos; src=&apos;/images/general/nmm_small.png&apos;/&gt;</xsl:text>
               </xsl:when>
               <xsl:when test="normalize-space(@role)">
                  <xsl:value-of select="normalize-space(@role)" />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>link</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&lt;/a&gt;</xsl:text>
            <xsl:text>] </xsl:text>
         </xsl:when>
         <xsl:otherwise />
      </xsl:choose>
      
   </xsl:template>
   
   <xsl:template match="*:scopecontent//*:persname|*:scopecontent//*:corpname|*:scopecontent//*:geogname" mode="html">
      
      <xsl:text>&lt;a href=&apos;/search?keyword=</xsl:text>
      <!-- need to escape * and ? reserved chars for XTF search -->
      <xsl:value-of select="encode-for-uri(replace(replace(normalize-space(.), '\*', '\\*'), '\?', '\\?'))"/>
      <xsl:text>&apos;&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/a&gt;</xsl:text>         
      
   </xsl:template>
   
   
   <!--internal and external link processing-->
   <xsl:template match="*:archref" mode="html">
      
      <!--normalised filename and foliation-->
      <xsl:variable name="identifier" select="@identifier"/>
      
      <!--normalised filename-->
      <xsl:variable name="idFileName">
         
         <xsl:choose>
            <xsl:when test="contains($identifier, ':')">
         
               <xsl:value-of select="normalize-space(substring-before($identifier, ':'))"/>
               
            </xsl:when>
            <xsl:otherwise>
               
               <xsl:value-of select="$identifier"/>
               
            </xsl:otherwise>
         </xsl:choose>
         
      </xsl:variable>
      
      <!--foliation-->
      <xsl:variable name="idFileFoliation">
         
         <xsl:choose>
            <xsl:when test="contains($identifier, ':')">
               
               <xsl:value-of select="normalize-space(substring-after($identifier, ':'))"/>
               
            </xsl:when>
            <xsl:otherwise>
               
               <!--leave as null-->
               
            </xsl:otherwise>
         </xsl:choose>
         
      </xsl:variable>
      
      
      
      
      <!--foliation target for link - first value if a range-->
      <xsl:variable name="idTargetFoliation">
         
         <xsl:choose>
            <xsl:when test="contains($idFileFoliation, '-')">
               
               <xsl:value-of select="normalize-space(substring-before($idFileFoliation, '-'))"/>
               
            </xsl:when>
            
            <xsl:otherwise>
               
               <xsl:value-of select="$idFileFoliation"/>
               
            </xsl:otherwise>
            
         </xsl:choose>
         
      </xsl:variable>
      
      
      <!--label for link href-->
      <xsl:variable name="label">
         
         <xsl:choose>
            
            <!--is it an internal link-->
            <xsl:when test="$idFileName=$fileID">
               
               <xsl:choose>
                  <xsl:when test="contains(*:unitid, ':')">
                     
                     <xsl:value-of select="normalize-space(substring-after(*:unitid,':'))"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="normalize-space(*:unitid)"/>      
                     
                  </xsl:otherwise>
               </xsl:choose>
               
               
               
            </xsl:when>
            
            <xsl:otherwise>
               
               <xsl:value-of select="normalize-space(*:unitid)"/>
               
            </xsl:otherwise>
            
         </xsl:choose>
         
      </xsl:variable>
      
      
      
      <!--and build the link itself-->
      <xsl:choose>
         <xsl:when test="normalize-space(*:unitid)">
            
            <!--start link text-->
            <xsl:if test="text()|*[not(local-name()='unitid')]">
               <xsl:apply-templates mode="html" select="text()|*[not(local-name()='unitid')]"/>                  
               <xsl:text> [</xsl:text>
            </xsl:if>
            
            
            <!--get target page-->
            <xsl:choose>
               
               <!--is it an internal link-->
               <xsl:when test="$idFileName=$fileID">
                  
                  
                  <xsl:variable name="targetPageNo">
                     <xsl:choose>
                        <xsl:when test="normalize-space($idTargetFoliation)">
                           
                           <xsl:choose>
                              <xsl:when test="/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=$idTargetFoliation]">
                                 <!-- match for target label -->
                                 <xsl:value-of select="substring-after(/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=$idTargetFoliation]/@id, '-')"/>                                 
                              </xsl:when>
                              <xsl:when test="/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, 'r')]">
                                 <!-- match for target label + 'r' -->
                                 <xsl:value-of select="substring-after(/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, 'r')]/@id, '-')"/>                                 
                              </xsl:when>
                              <xsl:when test="/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, 'v')]">
                                 <!-- match for target label + 'v' -->
                                 <xsl:value-of select="substring-after(/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, 'v')]/@id, '-')"/>                                 
                              </xsl:when>
                              <xsl:when test="/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, '(r)')]">
                                 <!-- match for target label + '(r)' -->
                                 <xsl:value-of select="substring-after(/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, '(r)')]/@id, '-')"/>                                 
                              </xsl:when>
                              <xsl:when test="/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, '(v)')]">
                                 <!-- match for target label + '(v)' -->
                                 <xsl:value-of select="substring-after(/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, '(v)')]/@id, '-')"/>                                 
                              </xsl:when>
                              <xsl:otherwise>
                                 <!-- meh - can't match target label -->
                              </xsl:otherwise>                                                         
                           </xsl:choose>
                           
                        </xsl:when>
                        <xsl:otherwise>
                           <!-- no label so set target = first page -->
                           <xsl:value-of select="substring-after(/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[1]/@id, '-')"/>                                 
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:variable>
                  
                  
                  <!--build link-->
                  <xsl:text>&lt;a href=&apos;&apos; onclick=&apos;store.loadPage(</xsl:text>
                  <xsl:value-of select="$targetPageNo" />
                  <xsl:text>);return false;&apos;&gt;</xsl:text>
                  
                  <xsl:choose>
                     <xsl:when test="contains(*:unitid, ':')">
                        
                        <xsl:value-of select="normalize-space(normalize-space(substring-after(*:unitid, ':')))"/>
                        
                     </xsl:when>
                     <xsl:otherwise>
                        
                        <xsl:value-of select="normalize-space(normalize-space(*:unitid))"/>
                        
                     </xsl:otherwise>
                     
                  </xsl:choose>
                               
                  <xsl:text>&lt;/a&gt;</xsl:text>    
                  
               </xsl:when>
               
               
               <!--if it is a link to another document-->
               <xsl:otherwise>
                  
                 
                  <xsl:variable name="targetPageNo">
                 
                  <xsl:choose>
                     
                     <xsl:when test="normalize-space($idTargetFoliation)">
                  
                        <xsl:variable name="targetURI" select="replace(base-uri(), concat($fileID, '/', $fileID, '.xml'), concat($idFileName, '/', $idFileName, '.xml'))"/>
                     
                        <xsl:choose>
                              
                           
                           <xsl:when test="unparsed-text-available($targetURI)">
                           
                                 <xsl:choose>
                                    <xsl:when test="document($targetURI, /)/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=$idTargetFoliation]">
                                       <!-- match for target label -->
                                       <xsl:value-of select="substring-after(document($targetURI, /)/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=$idTargetFoliation]/@id, '-')"/>                                 
                                    </xsl:when>
                                    <xsl:when test="document($targetURI, /)/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, 'r')]">
                                       <!-- match for target label + 'r' -->
                                       <xsl:value-of select="substring-after(document($targetURI, /)/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, 'r')]/@id, '-')"/>                                 
                                    </xsl:when>
                                    <xsl:when test="document($targetURI, /)/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, 'v')]">
                                       <!-- match for target label + 'v' -->
                                       <xsl:value-of select="substring-after(document($targetURI, /)/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, 'v')]/@id, '-')"/>                                 
                                    </xsl:when>                                    
                                    <xsl:when test="document($targetURI, /)/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, '(r)')]">
                                       <!-- match for target label + '(r)' -->
                                       <xsl:value-of select="substring-after(document($targetURI, /)/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, '(r)')]/@id, '-')"/>                                 
                                    </xsl:when>
                                    <xsl:when test="document($targetURI, /)/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, '(v)')]">
                                       <!-- match for target label + '(v)' -->
                                       <xsl:value-of select="substring-after(document($targetURI, /)/*:ead/*:archdesc/*:daogrp[@role='download']/*:daoloc[@label=concat($idTargetFoliation, '(v)')]/@id, '-')"/>                                 
                                    </xsl:when>                                                                       
                                    <xsl:otherwise>
                                       <!-- meh - can't match target label -->
                                       <xsl:value-of select="1"/>
                                    </xsl:otherwise>                                                         
                                 </xsl:choose>
                                 
                           </xsl:when>
                           
                           <xsl:otherwise>
                                 
                              <!--tei bit here-->
                              
                              
                              <xsl:variable name="teiTargetURI" select="replace($targetURI, '/ead/', '/tei/')"/>
                              
                              <xsl:choose>
                                 <xsl:when test="document($teiTargetURI, /)//*:text/*:body/*:div[not(@type)]//*:pb[@n=$idTargetFoliation]">
                                    <!-- match for target label -->
                                    <xsl:value-of select="substring-after(document($teiTargetURI, /)//*:text/*:body/*:div[not(@type)]//*:pb[@n=$idTargetFoliation]/@facs, '#i')"/>                                 
                                 </xsl:when>
                                 <xsl:when test="document($teiTargetURI, /)//*:text/*:body/*:div[not(@type)]//*:pb[@n=concat($idTargetFoliation, 'r')]">
                                    <!-- match for target label + 'r' -->
                                    <xsl:value-of select="substring-after(document($teiTargetURI, /)//*:text/*:body/*:div[not(@type)]//*:pb[@n=concat($idTargetFoliation, 'r')]/@ifacs, '#i')"/>                                 
                                 </xsl:when>
                                 <xsl:when test="document($teiTargetURI, /)//*:text/*:body/*:div[not(@type)]//*:pb[@n=concat($idTargetFoliation, 'v')]">
                                    <!-- match for target label + 'v' -->
                                    <xsl:value-of select="substring-after(document($teiTargetURI, /)//*:text/*:body/*:div[not(@type)]//*:pb[@n=concat($idTargetFoliation, 'v')]/@ifacs, '#i')"/>                                 
                                 </xsl:when>                                  
                                 <xsl:when test="document($teiTargetURI, /)//*:text/*:body/*:div[not(@type)]//*:pb[@n=concat($idTargetFoliation, '(r)')]">
                                    <!-- match for target label + '(r)' -->
                                    <xsl:value-of select="substring-after(document($teiTargetURI, /)//*:text/*:body/*:div[not(@type)]//*:pb[@n=concat($idTargetFoliation, '(r)')]/@ifacs, '#i')"/>                                 
                                 </xsl:when> 
                                 <xsl:when test="document($teiTargetURI, /)//*:text/*:body/*:div[not(@type)]//*:pb[@n=concat($idTargetFoliation, '(v)')]">
                                    <!-- match for target label + '(v)' -->
                                    <xsl:value-of select="substring-after(document($teiTargetURI, /)//*:text/*:body/*:div[not(@type)]//*:pb[@n=concat($idTargetFoliation, '(v)')]/@ifacs, '#i')"/>                                 
                                 </xsl:when>                                                                     
                                 <xsl:otherwise>
                                    <!-- meh - can't match target label -->
                                    <xsl:value-of select="1"/>
                                 </xsl:otherwise>                                                         
                              </xsl:choose>
                                 
                           </xsl:otherwise>
                             
                       </xsl:choose>
                     
                     </xsl:when>
                     
                     <xsl:otherwise>
                        <!-- no label so set target = first page -->
                        <xsl:value-of select="1"/>                                 
                     </xsl:otherwise>
                     
                  </xsl:choose>
                     
                  </xsl:variable>
                  
                  <!--build link-->
                  <xsl:text>&lt;a href=&apos;</xsl:text>
                  <xsl:value-of select="concat('/view/', $idFileName, '/', $targetPageNo)"/>
                  <xsl:text>&apos;&gt;</xsl:text>
                  <xsl:value-of select="normalize-space(unitid)"/>                  
                  <xsl:text>&lt;/a&gt;</xsl:text>
                  
               </xsl:otherwise>
               
            </xsl:choose>
            
            
            
            <!--end link text-->
            <xsl:if test="text()|*[not(local-name()='unitid')]">
               <xsl:text>]</xsl:text>
            </xsl:if>
            
            
         </xsl:when>
         <xsl:otherwise>
           
            <xsl:apply-templates mode="html" />
            
         </xsl:otherwise>
      </xsl:choose>
      
      
      
      
      
   </xsl:template>
   
</xsl:stylesheet>
