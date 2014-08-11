<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:FileUtils="java:org.cdlib.xtf.xslt.FileUtils" xmlns:local="http://cdlib.org/local"
   xmlns:mets="http://www.loc.gov/METS/" xmlns:mods="http://www.loc.gov/mods/"
   xmlns:parse="http://cdlib.org/xtf/parse" xmlns:saxon="http://saxon.sf.net/"
   xmlns:scribe="http://archive.org/scribe/xml" xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtf="http://cdlib.org/xtf"
   xmlns:cudl="http://cudl.lib.cam.ac.uk/xtf/" exclude-result-prefixes="#all">

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
   
   Basically, all DCP files are pointed here by docSelector.xsl. A variety of templates are then used
   
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
   <!-- Server URI                                       -->
   <!-- ====================================================================== -->

   <xsl:variable name="serverURI">

      <xsl:variable name="pathToConf" select="'../../../conf/local.conf'"/>

      <xsl:value-of select="document($pathToConf)//uri/@path"/>



   </xsl:variable>
   
   
   <!-- ====================================================================== -->
   <!-- Title - constructed on the fly and used in more than one place   -->
   <!-- ====================================================================== -->
   
   
   <xsl:variable name="title">
      
      <xsl:variable name="titleAuthor">
         
         <xsl:value-of select="//author/names/name/origForm" separator=", "/>
         
      </xsl:variable>
      <xsl:variable name="titleAddressee">
         
         <xsl:value-of select="//addressee/names/name/origForm" separator=", "/>
         
      </xsl:variable>
      
      <xsl:variable name="titleDate" select="//dates[1]"/>
      
      <xsl:value-of select="concat('Letter from ',$titleAuthor, ' to ',$titleAddressee, ' on ', $titleDate)"/>
      
   </xsl:variable>


   <!-- ============================================================================ -->
   <!-- Transcription show/hide flag - unpublished transcription needs to be hidden  -->
   <!-- ============================================================================ -->
   
   
   <xsl:variable name="hideTranscription">
      
      <xsl:value-of select="//status[@type='web']/transcription_view/@hide"/>

   </xsl:variable>
   

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

         <!--should only be one descriptive metadata section-->
         <descriptiveMetadata>

            <xsl:apply-templates select="//data"/>
         </descriptiveMetadata>

         <!--these are to do with the document as a whole-->


         <xsl:call-template name="get-numberOfPages"/>
         <xsl:call-template name="get-transcription-flag"/>

         <!--these are to do with the structure-->
         <xsl:call-template name="get-pages"/>

         <xsl:call-template name="get-logical-structures"/>

         <xsl:if test="//transcription/p and not($hideTranscription='true')">
            <xsl:call-template name="make-transcription-pages"/>
         </xsl:if>
         
      </xsl:variable>

      <!-- calls the add-fields template (which is in preFilterCommon.xsl) which marks out fields for indexing in certain ways-->
      <xsl:call-template name="add-fields">
         <xsl:with-param name="display" select="'dynaxml'"/>
         <xsl:with-param name="meta" select="$meta"/>
      </xsl:call-template>
   </xsl:template>


   <!--DESCRIPTIVE METADATA-->

   <xsl:template match="data">
      <part>

         <!--just need a unique id for top level (no hierarchy)-->
         <xsl:variable name="subdocumentLabel">DCP1</xsl:variable>
         <xsl:attribute name="xtf:subDocument" select="$subdocumentLabel"/>

         <!--and retrieves the descriptive metadata-->
         <!--these are all one-off values, some hard-coded-->
         <xsl:call-template name="get-dmdID"/>
         <xsl:call-template name="get-fileID"/>
         <xsl:call-template name="get-startpage"/>
         <xsl:call-template name="get-thumbnail"/>
         
         
         <!--**Title-->
         <!--title is constructed on the fly - from global variable-->
         <xsl:call-template name="get-title"/>
         
         <!--**Names-->
         <!--names have to be grouped by role-->
         <xsl:if test="//author/names/name">
            
            <xsl:element name="authors">
               <xsl:attribute name="display" select="'true'" />
            
            <xsl:apply-templates select="//author/names/name"/>

            </xsl:element>
         
         </xsl:if>
         
         <xsl:if test="//addressee/names/name">
            
            <xsl:element name="recipients">
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:apply-templates select="//addressee/names/name"/>
               
            </xsl:element>
            
         </xsl:if>

         <xsl:if test="//subject[@class='name' or @class='societal']">
            
            <xsl:element name="associated">
               
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:apply-templates select="//subject[@class='name' or @class='societal']"/>
               
            </xsl:element>
            
         </xsl:if>
         
         <!--**Associated Places-->
         
         <xsl:if test="//subject[@class='place']">
            
            <xsl:element name="places">
               
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:apply-templates select="//subject[@class='place']"/>
               
            </xsl:element>
            
         </xsl:if>
         
         <!--**Associated Places-->
         
         <xsl:if test="normalize-space(//postmark)">
            
            <xsl:element name="destinations">
               
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:apply-templates select="//postmark"/>
               
            </xsl:element>
            
         </xsl:if>
         
         
         <!--**Abstract-->
         <xsl:apply-templates select="//summaries"/>
         
         
         <!--**Subjects-->
         <xsl:if test="//subject[@class='scientific' or @class='flora' or @class='fauna' or @class='geological']">
            <subjects>
               
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:apply-templates select="//subject[@class='scientific' or @class='flora' or @class='fauna' or @class='geological']"/>
            </subjects>
         </xsl:if>

         
         <!--**Creation-->
         <!--this needs to be call template as it picks out bits from all over the place-->
         <xsl:call-template name="get-creation"/>

         <!--**Languages-->
         <xsl:call-template name="get-languages"/>
         
         <!--**Classmark and repository-->
         <xsl:apply-templates select="//location"/>

         <!--Physical description-->
         <xsl:apply-templates select="//physdescs"/>

         <!--Calendar number-->
         <xsl:apply-templates select="//caldata/entry/calendarnum"/>

         <!--Data Sources - hardcoded-->
         <xsl:call-template name="get-data-sources"/>
         
         
         <!--HARDCODED TEMPLATES-->
      
         <!--Material - hardcoded-->
         <xsl:call-template name="get-material"/>
         
         <!--Record Author - hardcoded-->
         <xsl:call-template name="get-record-author"/>

         <!--Image Rights - hardcoded-->
         <xsl:call-template name="get-image-rights"/>
         
         <!--Metadata Rights - hardcoded-->
         <xsl:call-template name="get-metadata-rights"/>
         
         <!--Type - hardcoded-->
         <xsl:call-template name="get-type"/>         
         
         <!--Collection membership-->
         <xsl:call-template name="get-collection-memberships"/>

      </part>

   </xsl:template>

   <!-- ***************************************************************************************************-->
   <!-- These are descriptive metadata templates called by get-parts-->

   <xsl:template name="get-dmdID">
      <ID>
         <xsl:text>DCP1</xsl:text>
      </ID>

   </xsl:template>

   <xsl:template name="get-fileID">
      <!-- Not currently in JSON -->
      <fileID>
         <xsl:value-of select="substring-before(tokenize(document-uri(/), '/')[last()], '.xml')"/>
      </fileID>

   </xsl:template>

   <xsl:template name="get-startpage">

      <xsl:variable name="dmdID" select="normalize-space(./@ID)"/>

      <!--startpage for linking to document-->
      <startPage>

         <xsl:value-of select="//addmat[type='download'][1]/sequence"/>

      </startPage>

      <!--and this is the label for the startPage-->
      <startPageLabel>

         <xsl:value-of select="//addmat[type='download'][1]/label"/>

      </startPageLabel>


   </xsl:template>

   <!-- title -->
   <!--title constructed on the fly for dcp metadata-->
   <xsl:template name="get-title">

      <title>
         
         <xsl:attribute name="display" select="'false'" />
         
         <xsl:attribute name="displayForm" select="$title" />         
         
         <xsl:value-of select="$title" />
      </title>

   </xsl:template>


   <!-- names-->
   <xsl:template match="name|subject[@class='name' or @class='societal']">

      <xsl:variable name="origForm" select="origForm"/>

      <xsl:variable name="authForm">
         
         <xsl:if test="authForms/authForm[@authority='viaf']">
            <xsl:value-of select="authForms/authForm[@authority='viaf']"/>
         </xsl:if>
         
      </xsl:variable>

      
      <xsl:variable name="displayForm">
         <xsl:choose>
            <xsl:when test="normalize-space($authForm)">
               <xsl:value-of select="$authForm"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$origForm"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      

      
      
      <xsl:variable name="roleFull">
         <xsl:choose>
            <xsl:when test="name()='name'">
               <xsl:value-of select="name(../..)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>associated</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <!--role - if it's not an author or an addressee it must be oth (i.e. subject)-->
      <xsl:variable name="role">
         <xsl:choose>
            <xsl:when test="$roleFull='author'">
               <xsl:text>aut</xsl:text>
            </xsl:when>
            <xsl:when test="$roleFull='addressee'">
               <xsl:text>rcp</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>oth</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
            
      <xsl:variable name="authority">

         <xsl:if test="authForms/authForm[@authority='viaf']">
            <xsl:text>viaf</xsl:text>
         </xsl:if>
      
      </xsl:variable>

      <xsl:variable name="authID">
         <xsl:if test="authForms/authForm[@authority='viaf']">
            <xsl:value-of select="authForms/authForm[@authority='viaf']/@id"/>
         </xsl:if>
      </xsl:variable>
      

      <name>

         <xsl:attribute name="display" select="'true'"/>

         <xsl:attribute name="displayForm" select="normalize-space($displayForm)"/>

         <fullForm>
            <xsl:value-of select="normalize-space($displayForm)"/>
         </fullForm>

         <shortForm>
            <xsl:value-of select="normalize-space($origForm)"/>
         </shortForm>
         
         <xsl:if test="normalize-space($authority)">
         
            <authority>
               <xsl:value-of select="normalize-space($authority)"/>
            </authority>

            <authorityURI>
               <xsl:text>http://viaf.org/</xsl:text>
            </authorityURI>
            
            <valueURI>
               <xsl:value-of select="concat('http://viaf.org/viaf/', $authID)"/>
            </valueURI>
            

         </xsl:if>

         <!--personal names except for subject class='societal'-->
         <type>
            
            <xsl:choose>
               <xsl:when test="@class='societal'">
                  <xsl:text>corporate</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>personal</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </type>

         <role>
            <xsl:value-of select="normalize-space($role)"/>
         </role>

      </name>


   </xsl:template>

   <!--abstract-->
   <xsl:template match="summaries">
      

      <abstract>
         
         <xsl:variable name="abstract">
            <xsl:apply-templates select="summaryitem/p" mode="html" />
         </xsl:variable>
         
         <xsl:attribute name="display" select="'false'" />
         
         <xsl:attribute name="displayForm" select="normalize-space($abstract)" />         
         
         <!-- html stripped from value for indexing -->
         <xsl:value-of select="normalize-space(replace($abstract, '&lt;[^&gt;]+&gt;', ''))"/>
         
      </abstract>


   </xsl:template>

   <xsl:template match="summaryitem/p" mode="html">
      
      
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:text> </xsl:text>
      
   </xsl:template>

   <!-- Subjects -->
   
   <xsl:template match="subject[@class='scientific' or @class='flora' or @class='fauna' or @class='geological']">
      
      
      <xsl:variable name="origForm" select="origForm"/>
      
      <xsl:variable name="authForm">
         
         <xsl:if test="authForms/authForm[@authority='lcsh']">
            <xsl:value-of select="authForms/authForm[@authority='lcsh']"/>
         </xsl:if>
         
      </xsl:variable>
      
      
      <xsl:variable name="displayForm">
         <xsl:choose>
            <xsl:when test="normalize-space($authForm)">
               <xsl:value-of select="$authForm"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$origForm"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      
      <xsl:variable name="authority">
         
         <xsl:if test="authForms/authForm[@authority='lcsh']">
            <xsl:text>lcsh</xsl:text>
         </xsl:if>
         
      </xsl:variable>
      
      <xsl:variable name="authID">
         <xsl:if test="authForms/authForm[@authority='lcsh']">
            <xsl:value-of select="authForms/authForm[@authority='lcsh']/@id"/>
         </xsl:if>
      </xsl:variable>
      
      
      <subject>
         
         <xsl:attribute name="display" select="'true'"/>
      
         <xsl:attribute name="displayForm" select="normalize-space($displayForm)"/>
      
      
         <!--TODO is this right??-->
         <fullForm>
            <xsl:value-of select="normalize-space($displayForm)"/>
         </fullForm>
      
         <shortForm>
            <xsl:value-of select="normalize-space($origForm)"/>
         </shortForm>
      
         <xsl:if test="normalize-space($authority)">
            
            <authority>
               <xsl:value-of select="normalize-space($authority)"/>
            </authority>
            
            <authorityURI>
               <xsl:text>http://id.loc.gov/</xsl:text>
            </authorityURI>
            
            <valueURI>
               <xsl:value-of select="concat('http://id.loc.gov/authorities/subjects/', $authID)"/>
            </valueURI>
            
            
         </xsl:if>
      
      
      </subject>
      
   </xsl:template>



   <!--thumbnail-->
   <xsl:template name="get-thumbnail">
      <thumbnailUrl>

         <xsl:variable name="thumbnailUrlOrig"
            select="//addmats/addmat[type='document-thumbnail'][1]/url"/>
         <xsl:variable name="thumbnailUrlShort"
            select="replace($thumbnailUrlOrig, 'http://cudl.lib.cam.ac.uk/(newton|content)','/content')"/>

         <xsl:value-of select="normalize-space($thumbnailUrlShort)"/>
      </thumbnailUrl>
      <thumbnailOrientation>
         <xsl:value-of
            select="normalize-space(//addmats/addmat[type='document-thumbnail'][1]/orientation)"/>
      </thumbnailOrientation>
   </xsl:template>


   <!--creation-->
   <!--a letter has only one creation event-->
   <xsl:template name="get-creation">
      
   <creations>
      <xsl:attribute name="display" select="'true'" />
      
      <event>
         
         <xsl:attribute name="display" select="'true'" />
         
         <type>creation</type>
         
         <xsl:if test="//address">
         
            <places>
               
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:apply-templates select="//address"/>
            
            </places>
            
         </xsl:if>
         
         <!--should only be one dates field-->
         <xsl:if test="//dates">
            
            <dateDisplay>
               
               <xsl:attribute name="display" select="'true'" />
               
               <xsl:attribute name="displayForm" select="normalize-space(//dates)"/>            
               
               
               <xsl:value-of select="normalize-space(//dates)"/>
               
            </dateDisplay>
         
         </xsl:if>
         
         <xsl:if test="//expansion/@from">
            
            <dateStart>
               <xsl:value-of select="//expansion/@from"/>
            </dateStart>
         
         </xsl:if>

         <xsl:if test="//expansion/@to">
            
            <dateEnd>
               <xsl:value-of select="//expansion/@to"/>
            </dateEnd>
            
         </xsl:if>
         
      </event>
      
   </creations>
      
 
   </xsl:template>

   <!--Places template for address in creations, associated places and destinations-->
   <xsl:template match="address|subject[@class='place']|postmark">
      
      <xsl:variable name="origForm" select="origForm"/>
      
      <xsl:variable name="authForm">
         
         <xsl:if test="authForms/authForm[@authority='getty']">
            <xsl:value-of select="authForms/authForm[@authority='getty']"/>
         </xsl:if>
         
      </xsl:variable>
      
      
      <xsl:variable name="displayForm">
         <xsl:choose>
            <xsl:when test="normalize-space($authForm)">
               <xsl:value-of select="$authForm"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$origForm"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="authority">
         
         <xsl:if test="authForms/authForm[@authority='getty']">
            <xsl:text>Getty_thesaurus</xsl:text>
         </xsl:if>
         
      </xsl:variable>
      
      <xsl:variable name="authID">
         <xsl:if test="authForms/authForm[@authority='getty']">
            <xsl:value-of select="authForms/authForm[@authority='getty']/@id"/>
         </xsl:if>
      </xsl:variable>
      
      
      <place>
         
         <xsl:attribute name="display" select="'true'"/>
         
         <xsl:attribute name="displayForm" select="normalize-space($displayForm)"/>
         
         <fullForm>
            <xsl:value-of select="normalize-space($displayForm)"/>
         </fullForm>
         
         <shortForm>
            <xsl:value-of select="normalize-space($origForm)"/>
         </shortForm>
         
         <xsl:if test="normalize-space($authority)">
            
            <authority>
               <xsl:value-of select="normalize-space($authority)"/>
            </authority>
            
            <authorityURI>
               <xsl:text>http://www.getty.edu/research/tools/vocabularies/tgn/</xsl:text>
            </authorityURI>
            
            <valueURI>
               <xsl:value-of select="$authID"/>
            </valueURI>
            
            
         </xsl:if>
         
      </place>
   </xsl:template>

   <!--language codes - if no translation, assumed to be English - hardcoded-->
   <xsl:template name="get-languages">
      
      <xsl:variable name="translation">
         <xsl:value-of select="//translation"/>
      </xsl:variable>
      
      
      <xsl:choose>
         <xsl:when test="normalize-space($translation)">
            
         </xsl:when>
         
         <xsl:otherwise>
            
            <languageCodes>
               <languageCode>
                  <xsl:value-of select="'eng'"/>
               </languageCode>
            </languageCodes>
            
            
            <languageStrings>
               <languageString>
                  <xsl:attribute name="display" select="'true'" />
                  <xsl:attribute name="displayForm" select="'English'" />
                  <xsl:text>English</xsl:text>
                  
               </languageString>
            </languageStrings>
         </xsl:otherwise>
         
      </xsl:choose>
      
   </xsl:template>

   <!--Location and classmark-->
   <xsl:template match="location">
      
      <xsl:if test="repository">
         
         <physicalLocation>
            
            <xsl:attribute name="display" select="'true'" />
      
            <xsl:variable name="repository">
               <xsl:choose>
                  <xsl:when test="repository='CUL'">
                     
                     <xsl:value-of select="'Cambridge University Library'"/>
                     
                  </xsl:when>
               <xsl:otherwise>
                  
                  <xsl:value-of select="normalize-space(repository)"/>
                  
               </xsl:otherwise>
               
               </xsl:choose>
               
            </xsl:variable>
      
            <xsl:attribute name="displayForm" select="$repository"/>
            
            <xsl:value-of select="$repository"/>
      
         </physicalLocation>
      
      </xsl:if>
      
      <xsl:if test="collection and idno">
         
         <shelfLocator>
            
            <xsl:attribute name="display" select="'true'" />
         
            <xsl:variable name="collection" select="normalize-space(collection)"/>
            <xsl:variable name="idno" select="normalize-space(idno)"/>
            <xsl:variable name="shelfLocator" select="concat('MS ',$collection,' ',$idno)"/>
            
            <xsl:attribute name="displayForm" select="$shelfLocator"/>
            
            <xsl:value-of select="$shelfLocator"/>
            
         </shelfLocator>
         
         
     </xsl:if>
      
      
   </xsl:template>
   
   <!--Extent-->
   <!--just concats together multiple physdesc fields-->
   <xsl:template match="physdescs">
      
         <extent>
            
            <xsl:attribute name="display" select="'true'"/>
            
            <xsl:attribute name="displayForm" select="normalize-space(.)"/>
            <xsl:value-of select="normalize-space(.)"/>
            
         </extent>
      
   </xsl:template>
   
   <!--Calendar number-->
   <xsl:template match="calendarnum">
      
      <calendarnum>
         
         <xsl:attribute name="display" select="'true'"/>
         
         <xsl:attribute name="displayForm" select="normalize-space(.)"/>
         <xsl:value-of select="normalize-space(.)"/>
         
      </calendarnum>
      
   </xsl:template>
   
   
   <!--Material-->
   <!--This is hardcoded-->
   <xsl:template name="get-material">
      
      <material>
         
         <xsl:attribute name="display" select="'true'" />
         <xsl:attribute name="displayForm">Paper</xsl:attribute>
         
         <xsl:value-of select="'Paper'"/>
         
      </material>
      
   </xsl:template>
   
  
   <!-- data sources -->
   <xsl:template name="get-data-sources">
      
      <dataSources>
         
         <xsl:attribute name="display" select="'true'" />
         
         <dataSource>
            
            <xsl:attribute name="display" select="'true'"/>
            
            <xsl:variable name="dsStatement">
               
               <xsl:variable name="volume" select="//caldata/entry/volume"/>
               
               <xsl:choose>
                  <xsl:when test="normalize-space($volume)">
                     
                     <xsl:value-of select="concat('Published in volume ', $volume, ' of the Correspondence of Charles Darwin, Cambridge University Press')"/>
                     
                  </xsl:when>
                  <xsl:otherwise>
                     
                     <xsl:text>Darwin Correspondence Project</xsl:text>
                     
                  </xsl:otherwise>
               </xsl:choose>
               
            </xsl:variable>
            
            
            <xsl:attribute name="displayForm" select="normalize-space($dsStatement)"/>
            <xsl:value-of select="normalize-space(replace($dsStatement, '&lt;[^&gt;]+&gt;', ''))"/>
         
         </dataSource>
         
      </dataSources>
      
      
   </xsl:template>


   <!--Record Author-->
  <xsl:template name="get-record-author">
     
     <dataRevisions>
     
        <xsl:attribute name="display" select="'true'"/>
        
        <xsl:variable name="drStatement" select="'Darwin Correspondence Project'"/>
        
        <xsl:attribute name="displayForm" select="normalize-space($drStatement)"/>
        <xsl:value-of select="normalize-space(replace($drStatement, '&lt;[^&gt;]+&gt;', ''))"/>
        
     </dataRevisions>
     
  </xsl:template>
   

   <!-- image rights -->
   
   <xsl:template name="get-image-rights">

      <xsl:element name="displayImageRights">
         <xsl:text>Zooming image © Cambridge University Library, All rights reserved.</xsl:text>
      </xsl:element>
      
      <xsl:element name="downloadImageRights">
         <xsl:text>This image may be used in accord with fair use and fair dealing provisions, including teaching and research. If you wish to reproduce it within publications or on the public web, please make a reproduction request.</xsl:text>
      </xsl:element>

      <xsl:variable name="repository">
         <xsl:choose>
            <xsl:when test="//location/repository='CUL'">               
               <xsl:value-of select="'Cambridge University Library'"/>               
            </xsl:when>
            <xsl:otherwise>               
               <xsl:value-of select="normalize-space(//location/repository)"/>               
            </xsl:otherwise>          
         </xsl:choose>         
      </xsl:variable>
      
      <xsl:element name="imageReproPageURL">
         <xsl:value-of select="cudl:get-imageReproPageURL($repository)"/>
      </xsl:element>
   
   </xsl:template>

   <!-- metadata rights -->
   <xsl:template name="get-metadata-rights">

      <xsl:element name="metadataRights">
         <xsl:text>This metadata is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.</xsl:text>
      </xsl:element>

   </xsl:template>
   

   <!-- type -->
   <!--plus specific types for pages below-->
   <xsl:template name="get-type">
      <!--also deals with whether a manuscript or not-->

      <type>
         <xsl:text>text</xsl:text>
      </type>
      <manuscript>
         <xsl:text>true</xsl:text>
      </manuscript>
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


   <!--transcription-->
   <!--this gets it a page at a time-->
   <xsl:template name="make-transcription-pages">

         <!--DCP metadata doesn't have pagination at the moment - but it might have soon!-->
         
         <!--<xsl:message>Indexing transcription</xsl:message>-->
         
         <xsl:choose>
            <!--when transcription is paginated-->
            <xsl:when test="//transcription//pb">
               
               <!--TODO - page through-->
                        
            </xsl:when>
            <!--otherwise index the whole lot at once-->
            <xsl:otherwise>
               
               <xsl:variable name="startPageLabel" select="//addmats/addmat[type='download'][1]/label"/>
               <xsl:variable name="startPage" select="//addmats/addmat[type='download'][1]/sequence"/>
               
               
               <transcriptionPage xtf:subDocument="letter">
                  
                  <!--debug message-->
                  <!--<xsl:message>Indexing page <xsl:value-of select="$startPageLabel"/></xsl:message>-->
                  
                  <fileID>
                     <xsl:value-of select="$fileID"/>
                  </fileID>
                  
                  <dmdID>
                     <xsl:value-of select="'DCP1'"/>
                  </dmdID>
                  
                  <title>
                     <xsl:value-of select="'Letter'"/>
                  </title>
                  
                  <startPage>
                     <xsl:value-of select="$startPage"/>
                  </startPage>
                  
                  <startPageLabel>
                     <xsl:value-of select="$startPageLabel"/>
                  </startPageLabel>
                  
                  
                  
                  <!-- Map whitespace to single space - non-breaking-spaces need special handling as not mapped by normalize-space -->
                  <transcriptionText>
                     
                     <xsl:variable name="transcriptionText">
                        <xsl:value-of select="//text"/>
                     </xsl:variable>
                     
                     <xsl:variable name="enclosureText">
                        <xsl:value-of select="//enclosure"/>
                     </xsl:variable>
                     
                     <!--<xsl:message select="$transcriptionText"/>
                     <xsl:message select="$enclosureText"/>-->
                     
                     <xsl:value-of select="normalize-space(translate($transcriptionText, '&#xa0;', ' '))"/>
                     <xsl:value-of select="normalize-space(translate($enclosureText, '&#xa0;', ' '))"/>
                     
                     
                  </transcriptionText>
                  
                  
               </transcriptionPage>
               
               
               
            </xsl:otherwise>
            
            
         </xsl:choose>

   </xsl:template>


   <!-- number of pages -->
   <xsl:template name="get-numberOfPages">
      <numberOfPages>
         <xsl:value-of select="count(//addmat[type='download'])"/>
      </numberOfPages>
   </xsl:template>

   <!--pages-->
   <!--Transcription for whole doc rather than for individual pages at present-->
   <xsl:template name="get-pages">

      <pages>
         <xsl:for-each select="//addmats/addmat[type='download']">
            <page>
               
               
               <xsl:variable name="page-id" select="id"/>
               
               <!--we do want to be able to search for the label-->
               <label>
                  <xsl:value-of select="normalize-space(label)"/>
               </label>
               <physID>
                  <xsl:value-of select="normalize-space(id)"/>
               </physID>
               <sequence>
                  
                  <xsl:value-of select="position()"/>
               </sequence>
               <!--both of the image urls need manipulation-->
               <displayImageURL>
                  <xsl:variable name="imageDispUrl" select="url"/>
                  <xsl:variable name="imageDispUrlShort"
                     select="replace($imageDispUrl, 'http://cudl.lib.cam.ac.uk/(newton|content)','/content')"/>
                  <xsl:variable name="imageDispUrlShortDzi"
                     select="replace($imageDispUrlShort, '.jpg','.dzi')"/>
                  <xsl:value-of select="normalize-space($imageDispUrlShortDzi)"/>

               </displayImageURL>
               <downloadImageURL>

                  <xsl:variable name="imageDownUrl" select="url"/>
                  <xsl:variable name="imageDownUrlShort"
                     select="replace($imageDownUrl, 'http://cudl.lib.cam.ac.uk/(newton|content)','/content')"/>
                  <xsl:value-of select="normalize-space($imageDownUrlShort)"/>
               </downloadImageURL>
               
               <xsl:variable name="thumbnailUrl" select="normalize-space(//addmat[type='thumbnail'][id=$page-id][1]/url)"/>
               <xsl:variable name="thumbnailUrlShort" select="replace($thumbnailUrl, 'http://cudl.lib.cam.ac.uk/(newton|content)','/content')"/>
               <xsl:variable name="thumbnailOrientation" select="normalize-space(//addmat[type='thumbnail'][id=$page-id][1]/orientation)"/>
               
               <thumbnailImageURL>
                  <xsl:value-of select="$thumbnailUrlShort"/>
               </thumbnailImageURL>
               <thumbnailImageOrientation>
                  <xsl:value-of select="$thumbnailOrientation"/>
               </thumbnailImageOrientation>
               
               <!--At the moment, transcription for whole thing rather than for individual pages-->
                  
            </page>
         </xsl:for-each>
      </pages>
   </xsl:template>

   <!-- are there any transcriptions -->
   <!--Assumes diplomatic transcription-->
   <xsl:template name="get-transcription-flag">
      <useTranscriptions>
         <xsl:choose>
            <xsl:when test="//transcription/p and not($hideTranscription='true')">
               <xsl:text>true</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>false</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </useTranscriptions>
      <useNormalisedTranscriptions>
         <xsl:text>false</xsl:text>
      </useNormalisedTranscriptions>
      <useDiplomaticTranscriptions>
         <xsl:choose>
            <xsl:when test="//transcription/p  and not($hideTranscription='true')">
               <xsl:text>true</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>false</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </useDiplomaticTranscriptions>

      <!--does the transcription contain page breaks?-->
      <xsl:if test="not(//transcription//pb) and //transcription/p and not($hideTranscription='true')">
         <allTranscriptionDiplomaticURL>
            
            <xsl:value-of select="concat('http://services.cudl.lib.cam.ac.uk/v1/transcription/dcp/diplomatic/internal/',$fileID,'/')"/>
            
         </allTranscriptionDiplomaticURL>
         
      </xsl:if>

   </xsl:template>


   <!--logical structures-->
   <xsl:template name="get-logical-structures">

      <logicalStructures>

         <logicalStructure>
            
            <label>
               <xsl:value-of select="$title"/>
            </label>
            
            <descriptiveMetadataID>
               <xsl:text>DCP1</xsl:text>
            </descriptiveMetadataID>
            
            <startPageLabel>
               <xsl:value-of
                  select="normalize-space(//addmats/addmat[type='download'][1]/label)"/>
            </startPageLabel>
            
            <startPageID>
               <xsl:value-of
                  select="normalize-space(//addmats/addmat[type='download'][1]/id)"
               />
            </startPageID>
            
            <startPagePosition>
               <xsl:value-of
                  select="normalize-space(//addmats/addmat[type='download'][1]/sequence)"
               />
            </startPagePosition>
            
            
            <endPagePosition>
               <xsl:value-of
                  select="normalize-space(//addmats/addmat[type='download'][last()]/sequence)"
               />
            </endPagePosition>
            
            <!--not hierarchical-->
            <!--<children/>-->
            
         </logicalStructure>
            
            
      </logicalStructures>

   </xsl:template>

   <!--**************HTML PROCESSING******************-->

   <xsl:template match="*" mode="html">
      
      <!--deals with legacy tags-->
      <xsl:variable name="tagName">
         <xsl:choose>
            <xsl:when test="name()='super'">
               <xsl:value-of select="'sup'"/>
            </xsl:when>
            <xsl:when test="name()='it'">
               <xsl:value-of select="'i'"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="name()"/>
            </xsl:otherwise>
            
         </xsl:choose>
       </xsl:variable>
         
         
      <!--p tags not processed as direct children of summaryitem-->   
      <xsl:choose>
         <xsl:when test="ancestor::node()[1]/name()='summaryitem' and $tagName='p'">
      
            <xsl:apply-templates mode="html" />
            
         </xsl:when>
         <xsl:otherwise>
            
            <xsl:value-of select="concat('&lt;',$tagName,'&gt;')"/>
            <xsl:apply-templates mode="html" />
            <xsl:value-of select="concat('&lt;/',$tagName,'&gt;')"/>
            
            
         </xsl:otherwise>
      
       </xsl:choose>
      
   </xsl:template>


</xsl:stylesheet>
