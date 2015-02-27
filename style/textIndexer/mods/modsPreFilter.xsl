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

   <!--
      Copyright (c) 2010, Regents of the University of California
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
   
   Basically, all MODS files are pointed here by docSelector.xsl. A variety of templates are then used
   
   1. To create an xml document in an internal format to be passed to style/dynaXML/docFormatter/general/generalDocFormatter.xsl
   2. To index fields and text for search
   
   Here, the conversion to internal format is done by this stylesheet, and the addition of further attributes which affect indexing
   (i.e. marking as metadata, facet or not to be indexed) is done by preFilterCommon.xsl
   
   -->

   <!-- ====================================================================== -->
   <!-- Import Common Templates and Functions                                  -->
   <!-- ====================================================================== -->

   <!--main function of this is to mark different sections of the document for different types of indexing-->
   <xsl:import href="../common/preFilterCommon.xsl"/>

   <!-- ====================================================================== -->
   <!-- Output parameters                                                      -->
   <!-- ====================================================================== -->

   <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

   <!-- ====================================================================== -->
   <!-- Global variables                                                       -->
   <!-- ====================================================================== -->

   <!--general variables containing all the mods and mets metadata-->
   <xsl:variable name="modsMeta" select="//*:mods"/>
   <xsl:variable name="metsMeta" select="//*:mets"/>
   
   

   
   <!-- ====================================================================== -->
   <!-- Root Template                                                          -->
   <!-- ====================================================================== -->

   <xsl:template match="/">
      <!--the whole output document is always wrapped up in xtf-converted-->
      <xtf-converted>
         <xsl:namespace name="xtf" select="'http://cdlib.org/xtf'"/>
         <!--and then we get all the fields!-->
         <xsl:call-template name="get-meta"/>
      </xtf-converted>
      
   </xsl:template>

   <!-- ====================================================================== -->
   <!-- Processes fields                                                      -->
   <!-- ====================================================================== -->

   <xsl:template name="get-meta">
      <!--puts everything into the meta variable-->
      <xsl:variable name="meta">

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

      <!-- calls the add-fields template (which is in preFilterCommon.xsl) which marks out fields for indexing in certain ways-->
      <xsl:call-template name="add-fields">
         <xsl:with-param name="display" select="'dynaxml'"/>
         <xsl:with-param name="meta" select="$meta"/>
      </xsl:call-template>
   </xsl:template>


   <!--parts - goes through descriptive metadata sections in METS-->
   <xsl:template match="mets:dmdSec">
            <part>
               
               <xsl:variable name="dmdpos" select="position()" />
                  
               <!--TODO change to dmdid-->
               <xsl:variable name="subdocumentLabel" select="./@ID"/>
               <xsl:attribute name="xtf:subDocument" select="$subdocumentLabel"/>
               
               <!--and retrieves the descriptive metadata-->
               <!--these are all one-off values, some hard-coded-->
               <xsl:variable name="dmdID" select="normalize-space(@ID)"/>
               
               <ID>
                  <xsl:value-of select="$dmdID"/>
               </ID>
               
               
               <xsl:call-template name="get-fileID"/>
               <xsl:call-template name="get-startpage"/>

               
               
               <!--these are handled with apply-templates-->
               <xsl:apply-templates select=".//*:mods/*:titleInfo[not(@type)]">
                  <xsl:with-param name="dmdpos" select="$dmdpos" />
               </xsl:apply-templates>
               
               <xsl:apply-templates select=".//*:titleInfo[@type='uniform']"/>
               
               <xsl:if test=".//*:titleInfo[@type='alternative']">
                  <alternativeTitles>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:apply-templates select=".//*:titleInfo[@type='alternative']"/>
                  </alternativeTitles>
               </xsl:if>
               
               
               <xsl:if test=".//*:name">
                  
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
                  
                  <!-- Group names by relator code in table -->
                  <xsl:for-each-group select=".//*:name[*:role/*:roleTerm[@type='code'][@authority='marcrelator'][.=$rolemap/role/@code]]" group-by="*:role/*:roleTerm[@type='code'][@authority='marcrelator']">
                     
                     <xsl:variable name="rolecode" select="*:role/*:roleTerm[@type='code'][@authority='marcrelator']" />
                     
                     <!-- Look up table entry -->

                     <xsl:variable name="elementName" select="$rolemap/role[@code=$rolecode]/@name" />                                      
                     
                     <xsl:element name="{$elementName}">
                        <xsl:attribute name="display" select="'true'" />
                        
                        <xsl:for-each select="current-group()">
                           <xsl:apply-templates select="."/>
                        </xsl:for-each>
                     </xsl:element>
                     
                  </xsl:for-each-group>
                  
                  <!-- NOW DEAL WITH OTHER ROLES -->
                  
                  <xsl:if test=".//*:name[*:role/*:roleTerm[@type='code'][@authority='marcrelator'][not(.=$rolemap/role/@code)]] or .//*:name[not(*:role)]">
                     <xsl:variable name="elementName" select="'associated'" />
                     
                     <xsl:element name="{$elementName}">
                        <xsl:attribute name="display" select="'true'" />
                        
                        <xsl:apply-templates select=".//*:name[*:role/*:roleTerm[@type='code'][@authority='marcrelator'][not(.=$rolemap/role/@code)]]" />
                        <xsl:apply-templates select=".//*:name[not(*:role)]" />
                           
                     </xsl:element>
                           
                  </xsl:if>
                  
                  
                  
                  
               </xsl:if>
                  
               
               <xsl:apply-templates select=".//*:abstract">
                  <xsl:with-param name="dmdpos" select="$dmdpos" />
               </xsl:apply-templates>
               
               
               <xsl:if test=".//*:subject">
                  <subjects>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:apply-templates select=".//*:subject"/>
                  </subjects>
               </xsl:if>
               
               <xsl:call-template name="get-video"/>
               
               
               <xsl:variable name="thumbnailID">
                  
                  <xsl:choose>
                     <xsl:when test="normalize-space(//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdID]/mets:div[@TYPE='page'][1]/mets:fptr[starts-with(@FILEID, 'THUMB-')]/@FILEID)">
                        
                        <xsl:value-of select="//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdID]/mets:div[@TYPE='page'][1]/mets:fptr[starts-with(@FILEID, 'THUMB-')]/@FILEID"/>
                        
                     </xsl:when>
                     
                     <xsl:when test="normalize-space(//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdID]/mets:div[1]/mets:div[@TYPE='page'][1]/mets:fptr[starts-with(@FILEID, 'THUMB-')]/@FILEID)">
                        
                        <xsl:value-of select="//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdID]/mets:div[1]/mets:div[@TYPE='page'][1]/mets:fptr[starts-with(@FILEID, 'THUMB-')]/@FILEID"/>
                        
                     </xsl:when>
                     
                     <xsl:when test="normalize-space(//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdID]/mets:div[1]/mets:div[1]/mets:div[@TYPE='page'][1]/mets:fptr[starts-with(@FILEID, 'THUMB-')]/@FILEID)">
                        
                        <xsl:value-of select="//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdID]/mets:div[1]/mets:div[1]/mets:div[@TYPE='page'][1]/mets:fptr[starts-with(@FILEID, 'THUMB-')]/@FILEID"/>
                        
                     </xsl:when>
                     
                     
                     
                     <xsl:otherwise>
                        
                        <xsl:value-of select="//mets:fileGrp[@USE='thumbnail']/mets:file[1]/@ID"/>
                        
                        <xsl:message select="$fileID"/>
                        
                        
                     </xsl:otherwise>
                  </xsl:choose>
                  
                  
               </xsl:variable>
               
               
               <thumbnailUrl>
                  
                  <!--<xsl:message select="$thumbnailID"/>-->
                  
                  <xsl:variable name="thumbnailUrlOrig" select="//mets:fileGrp[@USE='thumbnail']/mets:file[@ID=$thumbnailID]/mets:FLocat/@xlink:href"/>
                  <xsl:variable name="thumbnailUrlShort" select="replace($thumbnailUrlOrig, 'http://cudl.lib.cam.ac.uk/(newton|content)','/content')"/>
                  
                  <xsl:value-of
                     select="normalize-space($thumbnailUrlShort)"/>
               </thumbnailUrl>
               <thumbnailOrientation>
                  <xsl:value-of select="normalize-space(//mets:fileGrp[@USE='thumbnail']/mets:file[@ID=$thumbnailID]/@USE)"/>
               </thumbnailOrientation>
            
               
               <xsl:if test=".//*:originInfo[*:dateCreated]">
                  <creations>
                     
                     <xsl:attribute name="display" select="'true'" />
                                         
                     <xsl:apply-templates select=".//*:originInfo[*:dateCreated]"/>
                  </creations>      
               </xsl:if>
               
               <xsl:choose>
                  <xsl:when test=".//*:originInfo[*:dateIssued]">
                     
                     <publications>
                        
                        <xsl:attribute name="display" select="'true'" />
                        
                        <xsl:apply-templates select=".//*:originInfo[*:dateIssued]"/>
                     </publications>   
                     
                  </xsl:when>
                  <xsl:when test=".//*:originInfo[*:copyrightDate]">
                     <publications>
                        
                        <xsl:attribute name="display" select="'true'" />
                        
                        <xsl:apply-templates select=".//*:originInfo[*:copyrightDate]"/>
                     </publications>     
                  </xsl:when>
                  
               </xsl:choose>
              
               
               
               
               <xsl:if test=".//*:language/*:languageTerm">
                  <languageCodes>
                     <xsl:apply-templates select=".//*:language/*:languageTerm"/>
                  </languageCodes>
               </xsl:if>
               
               <xsl:if test=".//*:note[@type='language']">
                  <languageStrings>
                     
                     <xsl:attribute name="display" select="'true'" />
                                          
                     <xsl:apply-templates select=".//*:note[@type='language']"/>
                  </languageStrings>
               </xsl:if>
               
               <xsl:if test=".//*:note[not(@type)]">
                  <notes>
                     
                     <xsl:attribute name="display" select="'true'" />
                                                               
                     <xsl:apply-templates select=".//*:note[not(@type)]"/>
                  </notes>
               </xsl:if>
               
               <xsl:if test=".//*:note[@type='ownership']">
                  <ownerships>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:apply-templates select=".//*:note[@type='ownership']"/>
                  </ownerships>
               </xsl:if>
               
               <xsl:if test=".//*:note[@type='binding']">
                  <bindings>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:apply-templates select=".//*:note[@type='binding']"/>
                  </bindings>
               </xsl:if>
               
               <xsl:if test=".//*:note[@type='support']">
                  <supports>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:apply-templates select=".//*:note[@type='support']"/>
                  </supports>
               </xsl:if>
               
               <xsl:if test=".//*:note[@type='script']">
                  <scripts>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:apply-templates select=".//*:note[@type='script']"/>
                  </scripts>
               </xsl:if>
               
               <xsl:if test=".//*:note[@type='decoration']">
                  <decorations>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:apply-templates select=".//*:note[@type='decoration']"/>
                  </decorations>
               </xsl:if>
               
               <xsl:if test=".//*:note[@type='layout']">
                  <layouts>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:apply-templates select=".//*:note[@type='layout']"/>
                  </layouts>
               </xsl:if>
               
               <xsl:if test=".//*:note[@type='funding']">
                  <fundings>
                     
                     <xsl:attribute name="display" select="'true'" />
                                          
                     <xsl:apply-templates select=".//*:note[@type='funding']"/>
                  </fundings>
               </xsl:if>
               
               <xsl:if test=".//*:note[@type='condition']">
                  <conditions>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:apply-templates select=".//*:note[@type='condition']"/>
                  </conditions>
               </xsl:if>
               
               <xsl:if test=".//*:note[@type='source']">
                  <dataSources>
                     
                     <xsl:attribute name="display" select="'true'" />
                     
                     <xsl:apply-templates select=".//*:note[@type='source']"/>
                  </dataSources>
               </xsl:if>
               
               <xsl:if test=".//*:relatedItem[@type='isReferencedBy'][*:genre='exhibition']">
                  <relatedResources>
                     
                     <xsl:attribute name="display" select="'false'" />
                     
                     <xsl:apply-templates select=".//*:relatedItem[@type='isReferencedBy'][*:genre='exhibition']"/>
                  </relatedResources>
               </xsl:if>
               
               
               <xsl:if test=".//*:note[@type='recordAuthor']">
                     
                     <xsl:apply-templates select=".//*:note[@type='recordAuthor']"/>
                  
               </xsl:if>
               
               <xsl:apply-templates select=".//*:location/*:physicalLocation"/>
               <xsl:apply-templates select=".//*:location/*:shelfLocator"/>

               <xsl:call-template name="get-image-rights"/>
               <xsl:call-template name="get-metadata-rights"/>

               <xsl:apply-templates select=".//*:mods/*:typeOfResource"/>
              

               <xsl:apply-templates select=".//*:physicalDescription/*:extent"/>
               
               <xsl:call-template name="get-collection-memberships"/> 
               
            </part>

   </xsl:template>
   
   <!-- ***************************************************************************************************-->
   <!-- These are descriptive metadata templates called by get-parts-->

   <!--to be indexed etc correctly, DESCRIPTIVE METADATA ELEMENTS CANNOT HAVE ANY INTERNAL STRUCTURE-->
   <!--i.e. if you're setting xtf:meta="true", no internal structure-->

   
   
   <xsl:template name="get-fileID">
      <!-- Not currently in JSON -->
      <fileID>
         <xsl:value-of select="substring-before(tokenize(document-uri(/), '/')[last()], '.xml')"/>        
      </fileID>
      
   </xsl:template>

   <xsl:template name="get-startpage">
      
      <xsl:variable name="dmdID" select="normalize-space(./@ID)"></xsl:variable>
       
      <!-- Not currently in JSON -->
      <!--startpage for linking to document-->
      <startPage>
         
         <!--if this is the descriptive metadata for the whole document, start at first page-->
         <xsl:choose>
            <!--
            <xsl:when test="$dmdID='DMD1'">
            -->
            <xsl:when test="count(preceding-sibling::mets:dmdSec) = 0">
               <xsl:value-of select="//mets:structMap[@TYPE='PHYSICAL']//mets:div[@TYPE='page'][1]/@ORDER"/> 
            </xsl:when>
            <!--otherwise, look in the logical structure for the startpage-->
            <xsl:otherwise>
               <xsl:value-of select="//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdID]/descendant::mets:div[@TYPE='page'][1]/@ORDER"/>     
            </xsl:otherwise>
         </xsl:choose>
      
      </startPage>
      
      <!--and this is the label for the startPage-->
      <startPageLabel>
         <xsl:choose>
            <!--if this is the descriptive metadata for the whole document, start at first page-->
         <!--
            <xsl:when test="$dmdID='DMD1'">
         -->
            <xsl:when test="count(preceding-sibling::mets:dmdSec) = 0">
               <xsl:value-of select="//mets:structMap[@TYPE='PHYSICAL']//mets:div[@TYPE='page'][1]/@LABEL"/> 
            </xsl:when>
         <!--otherwise, look in the logical structure for the startpage-->
            <xsl:otherwise>
               <xsl:value-of select="//mets:structMap[@TYPE='LOGICAL']//mets:div[@DMDID=$dmdID]/descendant::mets:div[@TYPE='page'][1]/@LABEL"/>     
            </xsl:otherwise>
         </xsl:choose>
         
      </startPageLabel>
      
      
   </xsl:template>

   <!-- title -->
   <!--TODO: go through all and get parent to see if a subject?-->
   <xsl:template match="*:mods/*:titleInfo[not(@type)]">
      <xsl:param name="dmdpos" />
      
      <!--do more than one type of title here?-->
      
      
      <title>        
         
         <xsl:variable name="title">
            <xsl:if test="./*:nonSort">
               <xsl:value-of select="normalize-space(./*:nonSort)"/>
               <xsl:text> </xsl:text>
            </xsl:if>
            
            <xsl:value-of select="normalize-space(./*:title)"/>
            <xsl:choose>
               <xsl:when test="./*:subTitle">
                  <xsl:text> : </xsl:text>
                  <xsl:value-of select="normalize-space(./*:subTitle)"/>
               </xsl:when>
            </xsl:choose>
            <xsl:choose>
               <xsl:when test="./*:partName">
                  <xsl:text>. </xsl:text>
                  <xsl:value-of select="normalize-space(./*:partName)"/>
               </xsl:when>
            </xsl:choose>
            <xsl:choose>
               <xsl:when test="./*:partNumber">
                  <xsl:text>. </xsl:text>
                  <xsl:value-of select="./*:partNumber"/>
               </xsl:when>
            </xsl:choose>
         </xsl:variable>
         
         <xsl:choose>
            <xsl:when test="$dmdpos > 1">
            <!-- only display if not document-level -->
               <xsl:attribute name="display" select="'true'" />
            <!--   <xsl:attribute name="display" select="'false'" /> -->
            </xsl:when>
            <xsl:otherwise>
               <xsl:attribute name="display" select="'false'" />
            </xsl:otherwise>
         </xsl:choose>
                       
         <xsl:attribute name="displayForm" select="$title" />
                     
         <xsl:value-of select="$title" />
         
      </title>
   </xsl:template>

   <!-- uniform title -->
   <xsl:template match="*:titleInfo[@type='uniform']">
      <uniformTitle>
         
         <xsl:attribute name="display" select="'true'" />
         
         <xsl:variable name="uniformTitle">
            <xsl:value-of select="normalize-space(./*:title)"/>
            <xsl:choose>
               <xsl:when test="./*:subTitle">
                  <xsl:text> : </xsl:text>
                  <xsl:value-of select="normalize-space(./*:subTitle)"/>
               </xsl:when>
            </xsl:choose>
            <xsl:choose>
               <xsl:when test="./*:partName">
                  <xsl:text>. </xsl:text>
                  <xsl:value-of select="normalize-space(./*:partName)"/>
               </xsl:when>
            </xsl:choose>
            <xsl:choose>
               <xsl:when test="./*:partNumber">
                  <xsl:text>. </xsl:text>
                  <xsl:value-of select="normalize-space(./*:partNumber)"
                  />
               </xsl:when>
            </xsl:choose>            
         </xsl:variable>
         
         <xsl:attribute name="displayForm" select="$uniformTitle" />
         <xsl:value-of select="$uniformTitle" />
         
      </uniformTitle>
   </xsl:template>

   <!-- alternative title -->
   <xsl:template match="*:titleInfo[@type='alternative']">
      <alternativeTitle>         
         
         <xsl:attribute name="display" select="'true'" />
                  
         <xsl:variable name="altTitle">
            <xsl:value-of select="normalize-space(./*:title)"/>
            <xsl:choose>
               <xsl:when test="./*:subTitle">
                  <xsl:text> : </xsl:text>
                  <xsl:value-of select="normalize-space(./*:subTitle)"/>
               </xsl:when>
            </xsl:choose>
            <xsl:choose>
               <xsl:when test="./*:partName">
                  <xsl:text>. </xsl:text>
                  <xsl:value-of select="normalize-space(./*:partName)"/>
               </xsl:when>
            </xsl:choose>
            <xsl:choose>
               <xsl:when test="./*:partNumber">
                  <xsl:text>. </xsl:text>
                  <xsl:value-of select="normalize-space(./*:partNumber)"
                  />
               </xsl:when>
            </xsl:choose>           
         </xsl:variable>
         
         <xsl:attribute name="displayForm" select="$altTitle" />
         <xsl:value-of select="$altTitle" />
         
      </alternativeTitle>
   </xsl:template>
   

   <!-- names-->
   <xsl:template match="*:name">
      <name>
         
         <xsl:attribute name="display" select="'true'" />
         
         <!--there can be multiple nameparts-->
         <xsl:variable name="nameParts">
            <xsl:value-of select="./*:namePart" separator=" "/>
         </xsl:variable>
         
         
         <xsl:attribute name="displayForm" select="normalize-space($nameParts)"/>
         
         <fullForm>
            <xsl:value-of select="normalize-space($nameParts)"/>
         </fullForm>
            
         <shortForm>
            
            <xsl:choose>
               <xsl:when test="normalize-space(./*:displayForm)">
                  <xsl:value-of select="normalize-space(./*:displayForm)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="normalize-space($nameParts)"/>
               </xsl:otherwise>
            </xsl:choose>
            
            
            
         </shortForm>
            
         <authority>
            <xsl:value-of select="normalize-space(./@authority)"/>
         </authority>
            
         <authorityURI>
            <xsl:value-of select="normalize-space(./@authorityURI)"/>
         </authorityURI>
            
         <valueURI>
            <xsl:value-of select="normalize-space(./@valueURI)"/>
         </valueURI>
            
         <type>
            <xsl:value-of select="normalize-space(./@type)"/>
         </type>
            
         <role>
            <xsl:value-of select="normalize-space(./*:role/*:roleTerm)"/>
         </role>
            
      </name>
   </xsl:template>

   <!--abstract-->
   <xsl:template match="*:abstract">
      <xsl:param name="dmdpos" />
      
      <abstract>
         
         
         <xsl:choose>
            <xsl:when test="$dmdpos > 1">
               <!-- only display if not document-level -->
               <xsl:attribute name="display" select="'true'" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:attribute name="display" select="'false'" />
            </xsl:otherwise>
         </xsl:choose>
                  
         
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
                     
         <!-- <xsl:value-of select="normalize-space(.)"/> -->
         <xsl:value-of select="normalize-space(replace(., '&lt;[^&gt;]+&gt;', ''))"/>
         
      </abstract>
      
   </xsl:template>

   <!--video-->
   <!--this is video for the whole document - video related to pages or sections will go in the logical structure-->
   <!--TODO: is this being deprecated in favour of video embedded in the abstract with html?-->
   <xsl:template name="get-video">
      
      <xsl:variable name="mediaURL"
      select="normalize-space(//mets:file[@ID='VIDEO-WHOLE']/mets:FLocat/@xlink:href)"/>
      
      <xsl:if test="not(normalize-space($mediaURL)='')">         
         <mediaUrl>
            <xsl:value-of select="normalize-space($mediaURL)"/>
         </mediaUrl>
      </xsl:if>
      
   </xsl:template>

   
   


   <!-- subject -->
   <!-- Subjects as objects with component parts 
      Still excludes names as subjects? -->

   <xsl:template match="*:subject">
      <xsl:choose>
         <xsl:when test="./*:topic|./*:genre|./*:geographic|./*:temporal">
            <subject>
               
               <xsl:attribute name="display" select="'true'" />
                              
               <xsl:attribute name="displayForm">          
                  <xsl:value-of separator=" - " select="./*:topic|./*:genre|./*:geographic|./*:temporal"/>                  
               </xsl:attribute>
                  
               <fullForm>
                  <xsl:value-of separator=" - " select="./*:topic|./*:genre|./*:geographic|./*:temporal"/>                  
               </fullForm>
               
               <components>
                  <xsl:for-each select="./*:topic|./*:genre|./*:geographic|./*:temporal">
                     <component>
                        <type><xsl:value-of select="local-name(.)"/></type>
                        <fullForm><xsl:value-of select="."/></fullForm>
                     </component>
                  </xsl:for-each>
               </components>
               
               <authority>
                  <xsl:value-of select="normalize-space(./@authority)"/>
               </authority>
               
               <authorityURI>
                  <xsl:value-of select="normalize-space(./@authorityURI)"/>
               </authorityURI>
               
               <valueURI>
                  <xsl:value-of select="normalize-space(./@valueURI)"/>
               </valueURI>
            </subject>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   
  

   <!-- Creation and Publication as Events occurring at place and date -->

   <!-- dates -->
   <!--indexer is expecting straight 'date' values-->
   <!--TODO: do we want to distinguish between different encodings i.e. marc, iso - or convert to iso on the fly?-->
   <!--we need to be able to handle date ranges here! always a range?-->
  
   <xsl:template match="*:originInfo[*:dateCreated]">
      
      <event>
         
         <type>creation</type>
         
         <xsl:if test="*:place/*:placeTerm[@type='text']">
            <places>
               
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:for-each select="*:place/*:placeTerm[@type='text']" >
                  <xsl:call-template name="make-event-place">
                     <xsl:with-param name="placeTerm" select="." />
                  </xsl:call-template>
               </xsl:for-each>
            </places>
         </xsl:if>
         
         <xsl:for-each select="*:dateCreated" >
            <xsl:call-template name="make-event-date">
               <xsl:with-param name="date" select="." />
               <xsl:with-param name="eventType" select="'creation'" />
            </xsl:call-template>
         </xsl:for-each>
         
         <xsl:if test="not(*:dateIssued)">
         
            <!-- i.e. case where publisher associated with date created rather than date issued -->
            <xsl:if test="*:publisher">
               
               <publishers>
                  
                  <xsl:attribute name="display" select="'true'" />
                  
                  <!--
                  <xsl:attribute name="displayForm" select="normalize-space(.)"/>
                  
                  
                  <xsl:value-of select="normalize-space(.)"/> 
                  -->
                  <xsl:apply-templates select="*:publisher" />
                  
               </publishers>
               
            </xsl:if>
            
         </xsl:if>
         
      </event>
      
   </xsl:template>
   
   <xsl:template match="*:originInfo[*:dateIssued]">
      
      <event>
         
         <type>publication</type>
         
         <xsl:if test="*:place/*:placeTerm[@type='text']">
            <places>
               
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:for-each select="*:place/*:placeTerm[@type='text']" >
                  <xsl:call-template name="make-event-place">
                     <xsl:with-param name="placeTerm" select="." />
                  </xsl:call-template>
               </xsl:for-each>
            </places>
         </xsl:if>
         
         <xsl:for-each select="*:dateIssued" >
            <xsl:call-template name="make-event-date">
               <xsl:with-param name="date" select="." />
               <xsl:with-param name="eventType" select="'publication'" />
            </xsl:call-template>
         </xsl:for-each>
         
         <xsl:if test="*:publisher">
            
            <publishers>
               
               <xsl:attribute name="display" select="'true'" />
                              
               <!--
                  <xsl:attribute name="displayForm" select="normalize-space(.)"/>
                  
                  
                  <xsl:value-of select="normalize-space(.)"/> 
               -->
               <xsl:apply-templates select="*:publisher" />
               
            </publishers>
            
         </xsl:if>
         
      </event>
      
   </xsl:template>
   
   
   <xsl:template match="*:originInfo[*:copyrightDate]">
      
      <event>
         
         <type>publication</type>
         
         <xsl:if test="*:place/*:placeTerm[@type='text']">
            <places>
               
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:for-each select="*:place/*:placeTerm[@type='text']" >
                  <xsl:call-template name="make-event-place">
                     <xsl:with-param name="placeTerm" select="." />
                  </xsl:call-template>
               </xsl:for-each>
            </places>
         </xsl:if>
         
         <xsl:for-each select="*:copyrightDate" >
            <xsl:call-template name="make-event-date">
               <xsl:with-param name="date" select="." />
               <xsl:with-param name="eventType" select="'publication'" />
            </xsl:call-template>
         </xsl:for-each>
         
         <xsl:if test="*:publisher">
            
            <publishers>
               
               <xsl:attribute name="display" select="'true'" />
               
               <!--
                  <xsl:attribute name="displayForm" select="normalize-space(.)"/>
                  
                  
                  <xsl:value-of select="normalize-space(.)"/> 
               -->
               <xsl:apply-templates select="*:publisher" />
               
            </publishers>
            
         </xsl:if>
         
      </event>
      
   </xsl:template>
   
   
   <xsl:template name="make-event-place">
      <xsl:param name="placeTerm" />
      
      <place>
         
         <xsl:attribute name="display" select="'true'" />
         
         <xsl:choose>
            <xsl:when test="not(normalize-space($placeTerm/@authority) = '')">
               
               <xsl:attribute name="displayForm" select="normalize-space($placeTerm)"/>
               
               <fullForm>
                  <xsl:value-of select="normalize-space($placeTerm)"/>
               </fullForm>
               <authority>
                  <xsl:value-of select="normalize-space($placeTerm/@authority)"/>
               </authority>
               
               <xsl:if test="not(normalize-space($placeTerm/@authorityURI) = '')">
                  <authorityURI>
                     <xsl:value-of select="normalize-space($placeTerm/@authorityURI)"/>
                  </authorityURI>            
               </xsl:if>
               
               <xsl:if test="not(normalize-space($placeTerm/@valueURI) = '')">
                  <valueURI>
                     <xsl:value-of select="normalize-space($placeTerm/@valueURI)"/>
                  </valueURI>            
               </xsl:if>
               
            </xsl:when>
            <xsl:otherwise>
               
               <xsl:attribute name="displayForm" select="normalize-space($placeTerm)"/>
               
               <shortForm>
                  <xsl:value-of select="normalize-space($placeTerm)"/>
               </shortForm>
               
            </xsl:otherwise>
         </xsl:choose>         
         
      </place>
      
   </xsl:template>
   
   <xsl:template match="*:originInfo/*:publisher">
      
      <publisher>
         
         <xsl:attribute name="display" select="'true'" />         
         
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         
         <xsl:value-of select="normalize-space(.)"/>               
         
      </publisher>
   
   </xsl:template>

   <xsl:template name="make-event-date">
      <xsl:param name="date" />
      <xsl:param name="eventType" />
      
      <!--always a range here - if one date, both have same value-->
      <xsl:choose>
         <xsl:when test=".[@encoding='iso8601']">
            <xsl:choose>
               <xsl:when test=".[not(@point)]">
                  <dateStart>
                     <xsl:value-of
                        select="normalize-space(.)"
                     />
                  </dateStart>
                  <dateEnd>
                     <xsl:value-of
                        select="normalize-space(.)"
                     />
                  </dateEnd>
               </xsl:when>
               <xsl:when test=".[@point='start']">
                  <dateStart>
                     <xsl:value-of
                        select="normalize-space(.)"
                     />
                  </dateStart>
               </xsl:when>
               <xsl:when test=".[@point='end']">
                  <dateEnd>
                     <xsl:value-of
                        select="normalize-space(.)"
                     />
                  </dateEnd>
               </xsl:when>
            </xsl:choose>
            
         </xsl:when>
         <xsl:when test=".[not(@encoding)]">
            <dateDisplay>
               
               <xsl:attribute name="display" select="'true'" />

               <xsl:attribute name="displayForm" select="normalize-space(.)"/>               
               
               <xsl:value-of select="normalize-space(.)" />
            </dateDisplay>
         </xsl:when>
      </xsl:choose>
      
   </xsl:template>
   
   <!-- notes -->
   <xsl:template match="*:note[not(@type)]">
      
      <note>
         <xsl:attribute name="display" select="'true'" />
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
      </note>
   
   </xsl:template>

   <!-- ownership -->
   <xsl:template match="*:note[@type='ownership']">
      
      <ownership>
         <xsl:attribute name="display" select="'true'" />
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
      </ownership>
   
   </xsl:template>
   
   <!-- binding -->
   <xsl:template match="*:note[@type='binding']">
      
      <binding>
         <xsl:attribute name="display" select="'true'" />
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
      </binding>
      
   </xsl:template>
   
   <!-- support -->
   <xsl:template match="*:note[@type='support']">
      
      <support>
         <xsl:attribute name="display" select="'true'" />
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
      </support>
      
   </xsl:template>
   
   <!-- script -->
   <xsl:template match="*:note[@type='script']">
      
      <script>
         <xsl:attribute name="display" select="'true'" />
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
      </script>
      
   </xsl:template>
   
   <!-- decoration -->
   <xsl:template match="*:note[@type='decoration']">
      
      <decoration>
         <xsl:attribute name="display" select="'true'" />
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
      </decoration>
      
   </xsl:template>
   
   <!-- layout -->
   <xsl:template match="*:note[@type='layout']">
      
      <layout>
         <xsl:attribute name="display" select="'true'" />
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
      </layout>
      
   </xsl:template>

   <!-- funding -->
   <xsl:template match="*:note[@type='funding']">
      
      <funding>
         <xsl:attribute name="display" select="'true'" />
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
      </funding>
      
   </xsl:template>
   
   <!-- condition -->
   <xsl:template match="*:note[@type='condition']">
      
      <condition>
         <xsl:attribute name="display" select="'true'" />
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
      </condition>
      
   </xsl:template>
   
   <!-- source -->
   <xsl:template match="*:note[@type='source']">
      
      <dataSource>
         <xsl:attribute name="display" select="'true'" />
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
      </dataSource>
      
   </xsl:template>
   
   
   <!-- related resources -->
   <xsl:template match="*:relatedItem[@type='isReferencedBy'][*:genre='exhibition']">
      
      <relatedResource>
         <xsl:attribute name="display" select="'false'" />
         <xsl:attribute name="displayForm" select="normalize-space(./*:titleInfo/*:title)"/>
         <resourceTitle><xsl:value-of select="normalize-space(./*:titleInfo/*:title)"/></resourceTitle>
         <resourceUrl><xsl:value-of select="normalize-space(./*:location/*:url)"/></resourceUrl>
      </relatedResource>
      
   </xsl:template>
   
   <!-- record author -->
   <xsl:template match="*:note[@type='recordAuthor']">
      
      <xsl:element name="dataRevisions">
         
         <xsl:attribute name="display" select="'true'" />
         
         <xsl:attribute name="displayForm" select="normalize-space(.)" />
         <xsl:value-of select="normalize-space(.)" />
         
      </xsl:element>
      
   </xsl:template>
   
   
   <!--language codes-->
   <xsl:template match="*:language/*:languageTerm">
      
      <languageCode>
         <xsl:value-of select="normalize-space(.)"/>
      </languageCode>

   </xsl:template>

   <!-- language string -->
   <xsl:template match="*:note[@type='language']">      
      <languageString>
         <xsl:attribute name="display" select="'true'" />
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
      </languageString>
   </xsl:template>
   
   <xsl:template match="*:note[@type='completeness']">
      <completeness>
         
         <xsl:value-of select="normalize-space(.)"/>
      </completeness>
   </xsl:template>
   

   <!--physicalLocation-->
   <xsl:template match="*:location/*:physicalLocation">
      <physicalLocation>
         
         <xsl:attribute name="display" select="'true'" />
         
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
      </physicalLocation>
   </xsl:template>

   <!--shelfLocator-->
   <xsl:template match="*:location/*:shelfLocator">
      <shelfLocator>
         
         <xsl:attribute name="display" select="'true'" />
         
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
      </shelfLocator>
   </xsl:template>

   <!-- image rights -->
   <!---->
   <xsl:template name="get-image-rights">

      <!--these come from the mets-->
      <displayImageRights>
         <xsl:value-of
            select="normalize-space(//mets:amdSec/mets:rightsMD/mets:mdWrap[@LABEL='Display Image Rights']//RightsDeclaration)"
         />
      </displayImageRights>
      
      
      <xsl:variable name="imagesAdmID" select="//mets:fileGrp[@USE='download']/@ADMID"/>

      <downloadImageRights>
         <xsl:value-of
            select="normalize-space(//mets:amdSec[@ID=$imagesAdmID]/mets:rightsMD//RightsDeclaration)"
         />
      </downloadImageRights>
      
      <imageReproPageURL>
         <xsl:value-of select="cudl:get-imageReproPageURL(normalize-space(//*:location/*:physicalLocation))"/>
      </imageReproPageURL>
      

   </xsl:template>
   
   <!-- metadata rights -->
   <xsl:template name="get-metadata-rights">
  
      <!--these come from the mets-->
      <xsl:variable name="AdmID" select="./@ADMID"/>
      
      <metadataRights>
         <xsl:value-of
            select="normalize-space(//mets:amdSec[@ID=$AdmID]/mets:rightsMD//RightsDeclaration)"
         />
      </metadataRights>
      
   </xsl:template>

   <!-- type -->
   <!--plus specific types for pages below-->
   <xsl:template match="*:mods/*:typeOfResource">
      <!--also deals with whether a manuscript or not-->

      <type>
         <xsl:value-of select="normalize-space(.)"/>
      </type>
      <manuscript>
         <xsl:choose>
            <xsl:when test="./@manuscript='yes'">
               <xsl:text>true</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>false</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </manuscript>
   </xsl:template>

   <!--extent-->
   <xsl:template match="*:physicalDescription/*:extent">
      <extent>
         
         <xsl:attribute name="display" select="'true'" />
         
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
      </extent>
   </xsl:template>
   
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
   
   
   <!-- ********************************************************************************************************-->
   <!-- These are structural templates to do with the document as a whole -->
   <!--NB non-metadata fields can be structured-->
   

   <!--transcription indexing-->
   <!--this gets it a page at a time-->
   <xsl:template match="mets:file[@USE='NORM-PAGE' or @USE='DIPL-PAGE']">
      
      <xsl:variable name="pageID" select="@ID"/>
      <xsl:variable name="startPage" select="//mets:structMap[@TYPE='LOGICAL']//mets:div[mets:fptr[@FILEID=$pageID]]/@ORDER"/>
      <xsl:variable name="startPageLabel" select="//mets:structMap[@TYPE='LOGICAL']//mets:div[mets:fptr[@FILEID=$pageID]]/@LABEL"/>
      <xsl:variable name="subdocumentlabel" select="//mets:structMap[@TYPE='LOGICAL']//mets:div[mets:fptr[@FILEID=$pageID]]/@ID"/>
      <xsl:variable name="dmdID" select="//mets:structMap[@TYPE='LOGICAL']//mets:div[mets:fptr[@FILEID=$pageID]]/ancestor::mets:div[@DMDID][1]/@DMDID"/>
      
      <xsl:if test="$dmdID">
         
         
         <!--may need to exclude some elements here-->
         
         <transcriptionPage xtf:subDocument="{$subdocumentlabel}">
            
            <!--debug message-->
            <!--<xsl:message>Indexing page <xsl:value-of select="$startPageLabel"/></xsl:message>-->
            
            <fileID>
               <xsl:value-of select="$fileID"/>          
            </fileID>
            
            <dmdID>
               <xsl:value-of select="$dmdID"/>
            </dmdID>
            
            <title>
               <xsl:value-of select="$startPageLabel"/>
            </title>
            
            <startPage>
               <xsl:value-of select="$startPage"/>
            </startPage>
            
            <startPageLabel>
               <xsl:value-of select="$startPageLabel"/>
            </startPageLabel>
            
            <xsl:variable name="transcriptionURI" select="cudl:transcription-uri(./mets:FLocat/@xlink:href)"/>
            
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
         
      </xsl:if>
      
      
      
   </xsl:template>


   <!-- number of pages -->
   <xsl:template name="get-numberOfPages">
      <numberOfPages>
         <xsl:value-of select="count(//mets:structMap[@TYPE='PHYSICAL']//mets:div[@TYPE='page'])"/>
      </numberOfPages>
   </xsl:template>
   
   <!-- embeddable -->
   <xsl:template name="get-embeddable">
      
      <xsl:variable name="imagesAdmID" select="//mets:fileGrp[@USE='download']/@ADMID"/>
      
      <xsl:variable name="downloadImageRights" select="normalize-space(//mets:amdSec[@ID=$imagesAdmID]/mets:rightsMD//RightsDeclaration)"/>
      
      <embeddable>
         <xsl:choose>
            <xsl:when test="normalize-space($downloadImageRights)">true</xsl:when>
            <xsl:otherwise>false</xsl:otherwise>
         </xsl:choose>
      </embeddable>
      
   </xsl:template>
   
  

   <!--pages-->
   <!--relies on us consistently using the same prefixes to our FILEID attributes, i.e. IMAGE, NORM, DIPL-->
   <xsl:template name="get-pages">

      <pages>
         <xsl:for-each select="//mets:structMap[@TYPE='PHYSICAL']//mets:div[@TYPE='page']">
            <page>
               <!--we do want to be able to search for the label-->
               <label>
                  <xsl:value-of select="normalize-space(@LABEL)"/>
               </label>
               <physID>
                  <xsl:value-of select="normalize-space(@ID)"/>
               </physID>
              
               <sequence>
                  
                  <xsl:value-of select="position()"/>
               </sequence>
               
               <!--both of the image urls need manipulation-->
               <displayImageURL>
                  <xsl:variable name="imageDispFileID"
                     select="./mets:fptr[starts-with(@FILEID, 'IMAGE')]/@FILEID"/>
                  <xsl:variable name="imageDispUrl"
                     select="//mets:file[@ID=$imageDispFileID]/mets:FLocat/@xlink:href"/>
                  <xsl:variable name="imageDispUrlShort"
                     select="replace($imageDispUrl, 'http://cudl.lib.cam.ac.uk/(newton|content)','/content')"/>
                  <xsl:variable name="imageDispUrlShortDzi"
                     select="replace($imageDispUrlShort, '.jpg','.dzi')"/>
                  <xsl:value-of select="normalize-space($imageDispUrlShortDzi)"/>

               </displayImageURL>
               <downloadImageURL>
                  <xsl:variable name="imageDownFileID"
                     select="./mets:fptr[starts-with(@FILEID, 'IMAGE')]/@FILEID"/>
                  <xsl:variable name="imageDownUrl"
                     select="//mets:file[@ID=$imageDownFileID]/mets:FLocat/@xlink:href"/>
                  <xsl:variable name="imageDownUrlShort"
                     select="replace($imageDownUrl, 'http://cudl.lib.cam.ac.uk/(newton|content)','/content')"/>
                  <xsl:value-of select="normalize-space($imageDownUrlShort)"/>
               </downloadImageURL>
               
               
               <!--thumbnail stuff-->
               <xsl:variable name="thumbnailFileID"
                  select="./mets:fptr[starts-with(@FILEID, 'THUMB')]/@FILEID"/>
               <xsl:variable name="thumbnailUrl"
                  select="//mets:file[@ID=$thumbnailFileID]/mets:FLocat/@xlink:href"/>
               <xsl:variable name="thumbnailOrientation"
                  select="//mets:file[@ID=$thumbnailFileID]/@USE"/>
               
               <xsl:variable name="thumbnailUrlShort"
                  select="replace($thumbnailUrl, 'http://cudl.lib.cam.ac.uk/(newton|content)','/content')"/>
               
               <thumbnailImageURL>
                  <xsl:value-of select="normalize-space($thumbnailUrlShort)"/>
               </thumbnailImageURL>
               
               <thumbnailImageOrientation>
                  <xsl:value-of select="normalize-space($thumbnailOrientation)"/>
               </thumbnailImageOrientation>

               <!-- take the stem off transcription links -->
               
               <xsl:variable name="transNormFileID"
                  select="./mets:fptr[starts-with(@FILEID, 'NORM')]/@FILEID"/>
               <xsl:variable name="transNormUrl"
                  select="normalize-space(//mets:file[@ID=$transNormFileID]/mets:FLocat/@xlink:href)"/>
               <xsl:variable name="transNormUrlShort" select="replace($transNormUrl, 'http://services.cudl.lib.cam.ac.uk','')"/>
               
               
               <xsl:if test="normalize-space($transNormUrlShort)">
                  <transcriptionNormalisedURL>
                     <xsl:value-of select="normalize-space($transNormUrlShort)"/>

                  </transcriptionNormalisedURL>
               </xsl:if>   
               
               <xsl:variable name="transDiplFileID"
                  select="./mets:fptr[starts-with(@FILEID, 'DIPL')]/@FILEID"/>
               <xsl:variable name="transDiplUrl"
                  select="normalize-space(//mets:file[@ID=$transDiplFileID]/mets:FLocat/@xlink:href)"/>
               <xsl:variable name="transDiplUrlShort" select="replace($transDiplUrl, 'http://services.cudl.lib.cam.ac.uk','')"/>
               
               <xsl:if test="normalize-space($transDiplUrlShort)">
                  <transcriptionDiplomaticURL>
                     <xsl:value-of
                        select="normalize-space($transDiplUrlShort)"/>
                     
                  </transcriptionDiplomaticURL>
               </xsl:if>
               

               <pageType>
                  <!-- this is pretty tortuous as it needs to find out which (if any) logical structure pages are equivalent to the physical structure page,
                  then grab the nearest ancestor of that logical page which has a DMDID, then grab the relevant type value from that dmdSec
                  this is the only way at the moment to ensure that physical pages have the appropriate type as denoted by their logical structure-->

                  <!--gets the FILEID of the physical page-->
                  <xsl:variable name="imageFileID"
                     select="./mets:fptr[starts-with(@FILEID, 'IMAGE')]/@FILEID"/>
                  <!--gets the ID value of any equivalent logical page-->
                  <xsl:variable name="logStructPageID"
                     select="//mets:structMap[@TYPE='LOGICAL']//mets:div[mets:fptr/@FILEID=$imageFileID]/@ID"/>
                  <!--gets the nearest DMDID up the hierarchy from that logical page-->
                  <xsl:variable name="dmdID"
                     select="//mets:structMap[@TYPE='LOGICAL']//mets:div[@ID=$logStructPageID]/ancestor-or-self::mets:div[@DMDID][1]/@DMDID"/>

                  <!--if there is a dmdSec equivalent, grabs the relevant values from it
                  otherwise (as some physical pages do not appear in a logical structure) just uses first dmdSec on 
                  the assumption this will be for the volume as a whole-->
                     <xsl:choose>
                        <xsl:when test="$dmdID">
                           <xsl:value-of select="//mets:dmdSec[@ID=$dmdID]//*:mods/*:typeOfResource"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="//mets:dmdSec[1]//*:mods/*:typeOfResource"/>
                        </xsl:otherwise>
                     </xsl:choose>                 
               </pageType>
               
            </page>
         </xsl:for-each>
      </pages>
   </xsl:template>

   <!-- are there any transcriptions -->
   <!--relies on transcription file ids being consistently prefixed with NORM or DIPL-->
   <xsl:template name="get-transcription-flag">
      <useTranscriptions>
         <xsl:choose>
            <xsl:when
            test="(//mets:fptr[starts-with(@FILEID, 'NORM')]) or (//mets:fptr[starts-with(@FILEID, 'DIPL')])">
               <xsl:text>true</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>false</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </useTranscriptions>
      <useNormalisedTranscriptions>
         <xsl:choose>
            <xsl:when test="(//mets:fptr[starts-with(@FILEID, 'NORM')])">
               <xsl:text>true</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>false</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </useNormalisedTranscriptions>
      <useDiplomaticTranscriptions>
         <xsl:choose>
            <xsl:when test="(//mets:fptr[starts-with(@FILEID, 'DIPL')])">
               <xsl:text>true</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>false</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </useDiplomaticTranscriptions>
   </xsl:template>


   <!--logical structures-->
   <xsl:template name="get-logical-structures">

      <logicalStructures>

         <xsl:apply-templates select="//mets:structMap[@TYPE='LOGICAL']/mets:div[not (@TYPE)]"/>

      </logicalStructures>

   </xsl:template>

   <xsl:template match="mets:div">

      <logicalStructure>
                  
         
         <xsl:variable name="dmdID" select="./@DMDID"/>
         
         <!--we do want to be able to search for the label-->
         <label>
            <xsl:choose>
               
               <xsl:when test="not(normalize-space($dmdID) = '')">
                  
                  <xsl:value-of select="normalize-space(//mets:dmdSec[@ID=$dmdID]//*:mods/*:titleInfo[not(@type)]/*:title)"/>
                  
               </xsl:when>
               <xsl:otherwise>
                  
                  <xsl:value-of select="normalize-space(./@LABEL)"/>      
                  
               </xsl:otherwise>
               
            </xsl:choose>
            
            
         </label>

         <xsl:choose>
            
            <!--special case if it's the first dmd-->
            <!--get the first and last pages from the physical structure-->
            
            <!--
            <xsl:when test="$dmdID='DMD1'">
            -->
            <xsl:when test="(local-name(..)='structMap') and (count(preceding-sibling::mets:div) = 0)">
                              
               <descriptiveMetadataID>
                  <xsl:value-of select="normalize-space($dmdID)"/>
               </descriptiveMetadataID>            
               
               <xsl:if test="not(normalize-space(//mets:structMap[@TYPE='PHYSICAL']//mets:div[@TYPE='page'][1]/@LABEL) = '')">
                  <startPageLabel>
                     <xsl:value-of select="normalize-space(//mets:structMap[@TYPE='PHYSICAL']//mets:div[@TYPE='page'][1]/@LABEL)"/>
                  </startPageLabel>
               </xsl:if>

               <xsl:if test="not(normalize-space(//mets:structMap[@TYPE='PHYSICAL']//mets:div[@TYPE='page'][1]/@ID) = '')">
                  <startPageID>
                     <xsl:value-of select="normalize-space(//mets:structMap[@TYPE='PHYSICAL']//mets:div[@TYPE='page'][1]/@ID)"/>
                  </startPageID>            
               </xsl:if>
               
               <xsl:if test="not(normalize-space(//mets:structMap[@TYPE='PHYSICAL']//mets:div[@TYPE='page'][1]/@ORDER) = '')">
                  <startPagePosition>
                     <xsl:value-of select="normalize-space(//mets:structMap[@TYPE='PHYSICAL']//mets:div[@TYPE='page'][1]/@ORDER)"/>
                  </startPagePosition>        
               </xsl:if>
               
               <xsl:if test="not(normalize-space(//mets:structMap[@TYPE='PHYSICAL']//mets:div[@TYPE='page'][last()]/@ORDER) = '')">
                  <endPagePosition>
                     <xsl:value-of select="normalize-space(//mets:structMap[@TYPE='PHYSICAL']//mets:div[@TYPE='page'][last()]/@ORDER)"/>
                  </endPagePosition>        
               </xsl:if>
               
               
            </xsl:when>
            <!--otherwise, go from the logical to the physical structure to pick up IDs of first and last pages of section-->
            <!--but take the label from the logical structure-->
            <xsl:otherwise>
               
               <xsl:variable name="startPagePosition" select="descendant::mets:div[@TYPE='page'][1]/@ORDER"/>
               <xsl:variable name="endPagePosition" select="descendant::mets:div[@TYPE='page'][last()]/@ORDER"/>
               <xsl:variable name="startPhysicalID" select="//mets:structMap[@TYPE='PHYSICAL']//mets:div[@TYPE='page' and @ORDER=$startPagePosition]/@ID"/>
               <xsl:variable name="endPhysicalID" select="//mets:structMap[@TYPE='PHYSICAL']//mets:div[@TYPE='page' and @ORDER=$endPagePosition]/@ID"/>
               
               <xsl:variable name="startPageLabel" select="descendant::mets:div[@TYPE='page'][1]/@LABEL"/>
              

               <xsl:if test="not(normalize-space($dmdID) = '')">
                  <descriptiveMetadataID>
                     <xsl:value-of select="normalize-space($dmdID)"/>
                  </descriptiveMetadataID>            
               </xsl:if>
               
               <xsl:if test="not(normalize-space($startPageLabel) = '')">
                  <startPageLabel>
                     <xsl:value-of select="normalize-space($startPageLabel)"/>
                  </startPageLabel>
               </xsl:if>
               
               <xsl:if test="not(normalize-space($startPhysicalID) = '')">
                  <startPageID>
                     <xsl:value-of select="normalize-space($startPhysicalID)"/>
                  </startPageID>            
               </xsl:if>
               
               <xsl:if test="not(normalize-space($startPagePosition) = '')">
                  <startPagePosition>
                     <xsl:value-of select="normalize-space($startPagePosition)"/>
                  </startPagePosition>        
               </xsl:if>
               
               <xsl:if test="not(normalize-space($endPagePosition) = '')">
                  <endPagePosition>
                     <xsl:value-of select="normalize-space($endPagePosition)"/>
                  </endPagePosition>        
               </xsl:if>
               
               
               
            </xsl:otherwise>
         
         </xsl:choose>
         
                  
         <xsl:if test="./mets:div[not (@TYPE)]">
            <children>
               <xsl:apply-templates select="./mets:div[not (@TYPE)]"/>
            </children>
         </xsl:if>


      </logicalStructure>

   </xsl:template>

  


</xsl:stylesheet>
