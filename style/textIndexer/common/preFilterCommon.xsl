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
   <!-- ====================================================================== -->
   <!-- Variables                                                              -->
   <!-- ====================================================================== -->

   <xsl:variable name="pathToConf" select="'../../../conf/local.conf'"/>
   
   
   <!-- ====================================================================== -->
   <!-- Services URI and api key                                    -->
   <!-- ====================================================================== -->   
   
   <xsl:variable name="servicesURI" select="document($pathToConf)//services/@path"/>
   
   <xsl:variable name="apiKey" select="document($pathToConf)//services/@key"/>
   
   <!-- ====================================================================== -->
   <!-- Server URI                                       -->
   <!-- ====================================================================== -->   
   
   <xsl:variable name="serverURI" select="document($pathToConf)//uri/@path"/>
      
   <!-- ====================================================================== -->
   <!-- XTF Server URI                                       -->
   <!-- ====================================================================== -->
   
   <xsl:variable name="xtfServerURI" select="document($pathToConf)//xtf/@path"/>           
         
   <!-- ====================================================================== -->
   <!-- File ID                                       -->
   <!-- ====================================================================== -->
      
   <xsl:variable name="fileID" select="substring-before(tokenize(document-uri(/), '/')[last()], '.xml')"/>
      
   <!-- ====================================================================== -->
   <!-- Centuries lookup for date faceting                                 -->
   <!-- ====================================================================== -->

   <my:centuries>
      <my:century key="-10">0900s B.C.E.</my:century>
      <my:century key="-9">0800s B.C.E.</my:century>
      <my:century key="-8">0700s B.C.E.</my:century>
      <my:century key="-7">0600s B.C.E.</my:century>
      <my:century key="-6">0500s B.C.E.</my:century>
      <my:century key="-5">0400s B.C.E.</my:century>
      <my:century key="-4">0300s B.C.E.</my:century>
      <my:century key="-3">0200s B.C.E.</my:century>
      <my:century key="-2">0100s B.C.E.</my:century>
      <my:century key="-1">0000s B.C.E.</my:century>
      <my:century key="0">0000s C.E.</my:century>
      <my:century key="1">0100s C.E.</my:century>
      <my:century key="2">0200s C.E.</my:century>
      <my:century key="3">0300s C.E.</my:century>
      <my:century key="4">0400s C.E.</my:century>
      <my:century key="5">0500s C.E.</my:century>
      <my:century key="6">0600s C.E.</my:century>
      <my:century key="7">0700s C.E.</my:century>
      <my:century key="8">0800s C.E.</my:century>
      <my:century key="9">0900s C.E.</my:century>
      <my:century key="10">1000s C.E.</my:century>
      <my:century key="11">1100s C.E.</my:century>
      <my:century key="12">1200s C.E.</my:century>
      <my:century key="13">1300s C.E.</my:century>
      <my:century key="14">1400s C.E.</my:century>
      <my:century key="15">1500s C.E.</my:century>
      <my:century key="16">1600s C.E.</my:century>
      <my:century key="17">1700s C.E.</my:century>
      <my:century key="18">1800s C.E.</my:century>
      <my:century key="19">1900s C.E.</my:century>
      <my:century key="20">2000s C.E.</my:century>
      <my:century key="21">2100s C.E.</my:century>
   </my:centuries>

   <!-- ====================================================================== -->
   <!-- Templates                                                              -->
   <!-- ====================================================================== -->

   <!-- Fetch metadata from a Dublin Core record, if present -->
   <xsl:template name="get-dc-meta">
      <xsl:variable name="docpath" select="saxon:system-id()"/>
      <xsl:variable name="base" select="replace($docpath, '(.*)\.[^\.]+$', '$1')"/>
      <xsl:variable name="dcpath" select="concat($base, '.dc.xml')"/>
      <xsl:if test="FileUtils:exists($dcpath)">
         <xsl:apply-templates select="document($dcpath)" mode="inmeta"/>
         <xsl:if test="not(document($dcpath)//*:identifier)">
            <identifier xtf:meta="true" xtf:tokenize="no">
               <xsl:value-of select="replace(replace($docpath,'^.+/',''),'\.[A-Za-z]+$','')"/>
            </identifier>
         </xsl:if>
         <!-- special field for OAI -->
         <set xtf:meta="true">
            <xsl:value-of select="'public'"/>
         </set>
      </xsl:if>
   </xsl:template>

   <!-- Process DC -->
   <xsl:template match="*" mode="inmeta">

      <!-- Copy all metadata fields -->
      <xsl:for-each select="*">
         <xsl:choose>
            <xsl:when test="matches(name(),'identifier')">
               <identifier xtf:meta="true" xtf:tokenize="no">
                  <xsl:copy-of select="@*"/>
                  <xsl:value-of select="replace(replace(string(),'^.+/',''),'\.[A-Za-z]+$','')"/>
               </identifier>
            </xsl:when>
            <xsl:otherwise>
               <xsl:element name="{name()}">
                  <xsl:attribute name="xtf:meta" select="'true'"/>
                  <xsl:copy-of select="@*"/>
                  <xsl:value-of select="string()"/>
               </xsl:element>
            </xsl:otherwise>
         </xsl:choose>
         <!-- special fields for OAI -->
         <xsl:choose>
            <xsl:when test="matches(name(),'date')">
               <dateStamp xtf:meta="true" xtf:tokenize="no">
                  <xsl:value-of select="concat(parse:year(string(.)),'-01-01')"/>
               </dateStamp>
            </xsl:when>
            <xsl:when test="matches(name(),'subject')">
               <set xtf:meta="true">
                  <xsl:value-of select="string()"/>
               </set>
            </xsl:when>
         </xsl:choose>
      </xsl:for-each>

   </xsl:template>


   <!--************MAIN TEMPLATE******************-->
   <!--WE USE THIS-->
   <!-- Adds meta=true, sort fields and facets to meta-data -->
   <!--called by document-specific preFilters-->
   <xsl:template name="add-fields">
      <xsl:param name="meta"/>
      <xsl:param name="display"/>

      <xtf:meta>


         <!-- Add a field to record the document kind -->
         <display xtf:meta="true" xtf:tokenize="no">
            <xsl:value-of select="$display"/>
         </display>

         <xsl:apply-templates select="$meta/*" mode="meta"/>

      </xtf:meta>
   </xsl:template>

   <!--default to copy everything-->
   <xsl:template match="@*|node()" mode="meta">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="meta"/>
      </xsl:copy>
   </xsl:template>

   

   <!--*******MARKS AS METADATA, GENERATES FACET AND SORT ELEMENTS************-->
   <!--add xtf:meta =true attribute to the metadata fields-->

   <!-- Simple fields (text content) - maintain element name -->
   <!--type and startPageLabel are used in more than one place, so need to specify which we mean-->
   <xsl:template
      match="*:fileID
      |*:uniformTitle|*:alternativeTitle|*:descriptiveTitle
      |*:part/*:startPage
      |*:transcriptionPage/*:startPage
      |*:listItemPage/*:startPage
      |*:languageCode|*:languageString
      |*:physicalLocation
      |*:part/*:type
      |*:part/*:startPageLabel
      |*:transcriptionPage/*:startPageLabel
      |*:listItemPage/*:startPageLabel"
      mode="meta">


      <!--copies with extra attribute xtf:meta=true and also boosts search relevance for metadata-->
      <xsl:copy>
         <xsl:attribute name="xtf:meta">true</xsl:attribute>
         <xsl:attribute name="xtf:wordboost" select="1.5"/>
         <xsl:apply-templates select="node()|@*" mode="meta"/>
      </xsl:copy>
   </xsl:template>
   
   <!-- title needs sort value as well as xtf:meta -->
   <xsl:template match="*:title" mode="meta">
      
      <xsl:copy>
         <xsl:attribute name="xtf:meta">true</xsl:attribute>
         <xsl:attribute name="xtf:wordboost" select="1.5"/>
         <xsl:apply-templates select="node()|@*" mode="meta"/>
      </xsl:copy>
      
      <xsl:element name="{concat('sort-',local-name(.))}">
         <xsl:attribute name="xtf:meta">true</xsl:attribute>
         <xsl:attribute name="xtf:tokenize">no</xsl:attribute>
         <xsl:value-of select="parse:title(string(.))"/>
      </xsl:element>
      
   </xsl:template>
   
   <!--a special case for classmarks where we need to throw a version to the indexer where parts are separated with whitespace
   instead of full stops, so parts of the classmark are separately searchable~-->
   <xsl:template match="*:shelfLocator" mode="meta">
      
      <xsl:variable name="search-shelfLocator" select="replace(.,'\.',' ')"/>
      
      <xsl:copy>
         <xsl:attribute name="xtf:meta">true</xsl:attribute>
         <xsl:attribute name="xtf:wordboost" select="1.5"/>
         <xsl:apply-templates select="node()|@*" mode="meta"/>
      </xsl:copy>
      
      <xsl:element name="{concat('search-',local-name(.))}">
         <xsl:attribute name="xtf:meta">true</xsl:attribute>
         
         <xsl:value-of select="$search-shelfLocator"/>
      </xsl:element>
      
   </xsl:template>
   

   <!-- "Nested" fields - generate camel-case "composite" element name using parent element name -->
   <!--names and places don't need facet-->
   <xsl:template
      match="*:place/*:fullForm
      |*:name/*:fullForm"
      mode="meta">

      <!--TODO - do we need these original values at all?-->
      <!--copies with extra attribute xtf:noindex=true-->
      <xsl:copy>
         <xsl:attribute name="xtf:noindex">true</xsl:attribute>
         <xsl:apply-templates select="node()|@*" mode="meta"/>
      </xsl:copy>

      <!--and then adds new one-->
      <xsl:variable name="camelThisName">
         <xsl:value-of
            select="concat(upper-case(substring(local-name(.), 1, 1)), substring(normalize-space(local-name(.)), 2, (string-length(local-name(.)) - 1)))"
         />
      </xsl:variable>

      <xsl:element name="{concat(local-name(..), $camelThisName)}">
         <xsl:attribute name="xtf:meta">true</xsl:attribute>
         <xsl:apply-templates mode="meta"/>
      </xsl:element>
   </xsl:template>

   <!-- subjects are nested AND need facets -->
   <xsl:template
      match="*:subject/*:fullForm"
      mode="meta">
      
      <!--TODO - do we need these original values at all?-->
      <!--copies with extra attribute xtf:noindex=true-->
      <xsl:copy>
         <xsl:attribute name="xtf:noindex">true</xsl:attribute>
         <xsl:apply-templates select="node()|@*" mode="meta"/>
      </xsl:copy>
      
      <!--generates facet-->
      <xsl:element name="{concat('facet-',local-name(..))}">
         <xsl:attribute name="xtf:meta" select="'true'"/>
         <xsl:attribute name="xtf:facet" select="'yes'"/>
         <xsl:value-of select="normalize-unicode(string(.))"/>
      </xsl:element>
      
      <!--and then adds new element-->
      <xsl:variable name="camelThisName">
         <xsl:value-of
            select="concat(upper-case(substring(local-name(.), 1, 1)), substring(normalize-space(local-name(.)), 2, (string-length(local-name(.)) - 1)))"
         />
      </xsl:variable>
      
      <xsl:element name="{concat(local-name(..), $camelThisName)}">
         <xsl:attribute name="xtf:meta">true</xsl:attribute>
         <xsl:apply-templates mode="meta"/>
      </xsl:element>
   </xsl:template>
   

   <!-- "Nested" fields - generate camel-case "composite" element name using parent element name and type attribute -->
   <xsl:template match="*:event/*:dateStart|*:event/*:dateEnd|*:event/*:dateDisplay" mode="meta">


      <!--TODO - do we need these original values at all?-->
      <!--copies with extra attribute xtf:noindex=true-->
      <xsl:copy>
         <xsl:attribute name="xtf:noindex">true</xsl:attribute>
         <xsl:apply-templates select="node()|@*" mode="meta"/>
      </xsl:copy>

      <xsl:variable name="camelType">
         <xsl:if test="not(normalize-space(../*:type) = '')">
            <xsl:value-of
               select="concat(upper-case(substring(normalize-space(../*:type), 1, 1)), substring(normalize-space(../*:type), 2, (string-length(../*:type) - 1)))"
            />
         </xsl:if>
      </xsl:variable>
      
      <!--and then adds new one-->
      <xsl:variable name="camelThisName">
         <xsl:value-of
            select="concat(upper-case(substring(local-name(.), 1, 1)), substring(normalize-space(local-name(.)), 2, (string-length(local-name(.)) - 1)))"
         />
      </xsl:variable>

      <xsl:element name="{concat(local-name(..), $camelType, $camelThisName)}">
         <xsl:attribute name="xtf:meta">true</xsl:attribute>
         <xsl:apply-templates mode="meta"/>
      </xsl:element>
   </xsl:template>

   <!-- Publisher as special case - generate camel-case "composite" element name using "role" -->
   <xsl:template match="*:name[role='pbl']/*:displayForm" mode="meta">

      <!--copies original element-->
      <xsl:copy-of select="."/>


      <xsl:variable name="camelThisName">
         <xsl:value-of
            select="concat(upper-case(substring(local-name(.), 1, 1)), substring(normalize-space(local-name(.)), 2, (string-length(local-name(.)) - 1)))"
         />
      </xsl:variable>

      <xsl:element name="{concat('publisher', $camelThisName)}">
         <xsl:attribute name="xtf:meta">true</xsl:attribute>
         <xsl:apply-templates mode="meta"/>
      </xsl:element>
   </xsl:template>
   
   
   <!--this creates sort and facet dates-->
   <xsl:template match="*[*:event]|*:temporalCoverage" mode="meta">
      
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" mode="meta"/>
      </xsl:copy>
      
      <!-- create sort and facet from creation/publication dates and from temporal coverage periods -->
      <xsl:for-each select="*:event[*:type='creation']|*:event[*:type='publication']|*:period">
         <!-- Parse the date field to create a year (or range of years) -->
         <xsl:variable name="startDate">
            <xsl:choose>
               <!--
               <xsl:when test="./*:event[*:type='creation']/*:dateStart">
                  <xsl:value-of select=".//*:event[type='creation']/*:dateStart"/>
               </xsl:when>
               <xsl:when test="./*:event[*:type='publication']/*:dateStart">
                  <xsl:value-of select="./*:event[type='publication']/*:dateStart"/>
               </xsl:when>
               -->
               <xsl:when test="./*:dateStart">
                  <xsl:value-of select="./*:dateStart"/>
               </xsl:when>
            </xsl:choose>
         </xsl:variable>
         
         <!--for date facet-->
         <xsl:variable name="startCentury">
            <xsl:choose>
               <xsl:when test="starts-with($startDate, '-')">
                  <xsl:value-of select="substring($startDate, 1,3)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="substring($startDate, 1,2)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         
         <xsl:variable name="endDate">
            <xsl:choose>
               <!--
               <xsl:when test="./*:event[*:type='creation']/*:dateEnd">
                  <xsl:value-of select="./*:event[*:type='creation']/*:dateEnd"/>
               </xsl:when>
               <xsl:when test="./*:event[*:type='publication']/*:dateEnd">
                  <xsl:value-of select="./*:event[*:type='publication']/*:dateEnd"/>
               </xsl:when>
               -->
               <xsl:when test="./*:dateEnd">
                  <xsl:value-of select="./*:dateEnd"/>
               </xsl:when>
            </xsl:choose>
         </xsl:variable>
         
         <!--for date facet-->
         <xsl:variable name="endCentury">
            <xsl:choose>
               <xsl:when test="starts-with($endDate, '-')">
                  <xsl:value-of select="substring($endDate, 1,3)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="substring($endDate, 1,2)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         
         
         <!-- Generate sort-year (if range, only use first year) -->
         <xsl:variable name="startYear" select="parse:year(string($startDate))"/>
         <xsl:variable name="endYear" select="parse:year(string($endDate))"/>
         <xsl:variable name="yearRange" select="concat($startYear,'-',$endYear)"/>
         
         <sort-year xtf:meta="true" xtf:tokenize="no">
            <xsl:value-of select="$startYear"/>
         </sort-year>
         
         <year xtf:meta="true">
            <xsl:copy-of select="$yearRange"/>
         </year>
         
         <!--creates date facet-->
         <xsl:call-template name="facet-date">
            <xsl:with-param name="i" select="$startCentury"/>
            <xsl:with-param name="count" select="$endCentury"/>
         </xsl:call-template>
         
      </xsl:for-each>
      
   </xsl:template>
   
   <!--creates date facets-->
   <xsl:template name="facet-date">
      
      <xsl:param name="i" />
      <xsl:param name="count" />
      <!--converts parameters to numbers-->
      <xsl:variable name="inumber" select="number($i)"/>
      <xsl:variable name="countnumber" select="number($count)"/>
      
      
      <xsl:if test="$inumber &lt;= $countnumber">
         <facet-date xtf:meta="true" xtf:facet="yes">
            <xsl:variable name="centuryString" select="document('')/*/my:centuries/my:century[@key=$inumber]"/>
            <xsl:value-of select="$centuryString"/>
         </facet-date>
         
      </xsl:if>
      
      <xsl:if test="$inumber &lt;= $countnumber">
         
         <xsl:call-template name="facet-date">
            <xsl:with-param name="i">
               <xsl:value-of select="$inumber + 1"/>
            </xsl:with-param>
            <xsl:with-param name="count">
               <xsl:value-of select="$countnumber"/>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      
   </xsl:template>
   
   <!-- Create collection facets -->
   <xsl:template match="*:collections" mode="meta">
      <xsl:for-each select="*:collection">
         <xsl:element name="facet-collection">
            <xsl:attribute name="xtf:meta">true</xsl:attribute>
            <xsl:attribute name="xtf:facet">true</xsl:attribute>
            <xsl:apply-templates select="node()|@*" mode="meta"/>
         </xsl:element>         
      </xsl:for-each>      
   </xsl:template>
   
  <!-- Mark itemType/thumbnail URI/orientation as metadata so that appear in search results -->
   <xsl:template
      match="*:itemType|*:thumbnailUrl
      |*:thumbnailOrientation" mode="meta">
      
      <xsl:copy>
         <xsl:attribute name="xtf:meta">true</xsl:attribute>
         <xsl:attribute name="xtf:noindex">true</xsl:attribute>
         <xsl:apply-templates select="node()|@*" mode="meta"/>
      </xsl:copy>
      
   </xsl:template>
   
   
   <!--*******TURNS OFF INDEXING************-->
   <!--add xtf:noindex=true attribute to fields excluded from indexing-->
   <!--TODO - date, name, subject, place fullForm values are also assigned noindex=true (above), but we may not need them in any case-->

   <xsl:template
      match="*:displayImageRights
      |*:downloadImageRights
      |*:metadataRights
      |*:numberOfPages
      |*:pages
      |*:useTranscriptions
      |*:logicalStructures
      |*:ID
      |*:event/*:type
      |*:name/*:shortForm
      |*:name/*:type
      |*:name/*:role
      |*:authority
      |*:authorityURI
      |*:valueURI
      |*:fundings/*:funding"
      mode="meta">
      
      <!--copies with extra attribute xtf:noindex=true-->
      <xsl:copy>
         <xsl:attribute name="xtf:noindex">true</xsl:attribute>
         <xsl:apply-templates select="node()|@*" mode="meta"/>
      </xsl:copy>
   </xsl:template>
   
   
   
   
   
   <!--****THIS SECTION HANDLES INHERITANCE OF FACETS***-->
   <!--both dmdSecs with no subjects/dates and transcription pages need to inherit facets from the first
   dmdSec up the tree with the right info-->
   
   
   <!--inheritance of facets for dmd parts without subjects or dates-->
   <!-- parts should always have a collection facet so no need to inherit-->
   <xsl:template match="*:part[not(*:subjects) or not(*/*:event)]" mode="meta">
      
      <xsl:copy>
         
         <xsl:apply-templates select="node()|@*" mode="meta"/>
         
         
         <xsl:variable name="dmdID" select="ID"/>
         
         
         <xsl:if test=".[not(*:subjects)]">
         
            <xsl:call-template name="inherit-facet-subjects">
               <xsl:with-param name="dmdID" select="$dmdID"/>
            </xsl:call-template>
            
         </xsl:if>
         
         <xsl:if test=".[not(*/*:event)]">
         
            <xsl:call-template name="inherit-facet-dates">
               <xsl:with-param name="dmdID" select="$dmdID"/>
            </xsl:call-template>
            
         </xsl:if>
         

      </xsl:copy>
      
   </xsl:template>
   
   <!--inheritance of facets for transcription pages-->
   <xsl:template match="*:transcriptionPage" mode="meta">
      
      <xsl:copy>
         
         <xsl:apply-templates select="node()|@*" mode="meta"/>
         
         
         <xsl:variable name="dmdID" select="dmdID"/>
                  
         <xsl:call-template name="inherit-facet-collections">
            <xsl:with-param name="transDmdID" select="$dmdID"/>
         </xsl:call-template>
         
         <xsl:call-template name="inherit-facet-subjects">
            <xsl:with-param name="transDmdID" select="$dmdID"/>
         </xsl:call-template>
      
         
         <xsl:call-template name="inherit-facet-dates">
            <xsl:with-param name="transDmdID" select="$dmdID"/>
         </xsl:call-template>
         
         
      </xsl:copy>
      
      
      
   </xsl:template>
   
   
   <!--inheritance of facets for listItem pages-->
   <xsl:template match="*:listItemPage" mode="meta">
      
      <xsl:copy>
         
         <xsl:apply-templates select="node()|@*" mode="meta"/>
         
         
         <xsl:variable name="dmdID" select="dmdID"/>
         
         <xsl:call-template name="inherit-facet-collections">
            <xsl:with-param name="transDmdID" select="$dmdID"/>
         </xsl:call-template>
         
         <xsl:call-template name="inherit-facet-subjects">
            <xsl:with-param name="transDmdID" select="$dmdID"/>
         </xsl:call-template>
         
         
         <xsl:call-template name="inherit-facet-dates">
            <xsl:with-param name="transDmdID" select="$dmdID"/>
         </xsl:call-template>
         
         
      </xsl:copy>
      
      
      
   </xsl:template>
      
   
   <!--template for collection inheritance-->
   <xsl:template name="inherit-facet-collections">
      <!--different param depending on whether first call was from dmdSec or transcriptionPage-->
      <xsl:param name="dmdID"/>
      <xsl:param name="transDmdID"/>
      
      <xsl:variable name="useDmdID">
         
         <xsl:choose>
            <xsl:when test="$dmdID">
               <xsl:value-of select="//*:logicalStructure[*:descriptiveMetadataID=$dmdID]/ancestor::*:logicalStructure[1]/*:descriptiveMetadataID"/>
            </xsl:when>
            <xsl:when test="$transDmdID">
               <xsl:value-of select="$transDmdID"/>
            </xsl:when>
            
         </xsl:choose>
         
      </xsl:variable>
      
      
      <xsl:if test="normalize-space($useDmdID)">
         
         <xsl:choose>
            <xsl:when test="//*:part[ID=$useDmdID]/*:collections">
               
               
               <xsl:for-each select="//*:part[ID=$useDmdID]/*:collections/*:collection">
                  
                  <!--generates facet-->
                  <xsl:element name="facet-collection">
                     <xsl:attribute name="xtf:meta">true</xsl:attribute>
                     <xsl:attribute name="xtf:facet">true</xsl:attribute>
                     <xsl:apply-templates select="node()|@*" mode="meta"/>
                  </xsl:element>         
                  
               </xsl:for-each>
               
            </xsl:when>
            <xsl:otherwise>
               
               <xsl:call-template name="inherit-facet-collections">
                  <xsl:with-param name="dmdID" select="$useDmdID"/>
               </xsl:call-template>
               
            </xsl:otherwise>
            
         </xsl:choose>   
         
      </xsl:if>
      
   </xsl:template>
   
   <!--template for subject inheritance-->
   <xsl:template name="inherit-facet-subjects">
      <!--different param depending on whether first call was from dmdSec or transcriptionPage-->
      <xsl:param name="dmdID"/>
      <xsl:param name="transDmdID"/>
      
      <xsl:variable name="useDmdID">
         
         <xsl:choose>
            <xsl:when test="$dmdID">
               <xsl:value-of select="//*:logicalStructure[*:descriptiveMetadataID=$dmdID]/ancestor::*:logicalStructure[1]/*:descriptiveMetadataID"/>
            </xsl:when>
            <xsl:when test="$transDmdID">
               <xsl:value-of select="$transDmdID"/>
            </xsl:when>
            
         </xsl:choose>
         
      </xsl:variable>
      
      
      <xsl:if test="normalize-space($useDmdID)">
         
         <xsl:choose>
            <xsl:when test="//*:part[ID=$useDmdID]/*:subjects">
               
               
               <xsl:for-each select="//*:part[ID=$useDmdID]/*:subjects/*:subject/*:fullForm">
               
                  <!--generates facet-->
                  <xsl:element name="facet-subject">
                     <xsl:attribute name="xtf:meta" select="'true'"/>
                     <xsl:attribute name="xtf:facet" select="'yes'"/>
                     <xsl:value-of select="normalize-unicode(string(.))"/>
                  </xsl:element>
                  
               </xsl:for-each>
               
            </xsl:when>
            <xsl:otherwise>
               
               <xsl:call-template name="inherit-facet-subjects">
                  <xsl:with-param name="dmdID" select="$useDmdID"/>
               </xsl:call-template>
               
            </xsl:otherwise>
            
      </xsl:choose>   
      
      </xsl:if>
      
   </xsl:template>
   
   <!--template for date inheritance-->
   <xsl:template name="inherit-facet-dates">
      <!--different param depending on whether first call was from dmdSec or transcriptionPage-->
      <xsl:param name="dmdID"/>
      <xsl:param name="transDmdID"/>
      
      <xsl:variable name="useDmdID">
         
         <xsl:choose>
            <xsl:when test="$dmdID">
               <xsl:value-of select="//*:logicalStructure[*:descriptiveMetadataID=$dmdID]/ancestor::*:logicalStructure[1]/*:descriptiveMetadataID"/>
            </xsl:when>
            <xsl:when test="$transDmdID">
               <xsl:value-of select="$transDmdID"/>
            </xsl:when>
            
         </xsl:choose>
         
      </xsl:variable>
      
      <xsl:if test="normalize-space($useDmdID)">
         
      
         <xsl:choose>
            <xsl:when test="//*:part[ID=$useDmdID]//*:event[type='creation' or type='publication']">
               
               
               <xsl:variable name="startDate">
                  
                  <xsl:choose>
                     <xsl:when test="//*:part[ID=$useDmdID]//*:event[type='creation']">
                        <xsl:value-of select="//*:part[ID=$useDmdID]//*:event[type='creation'][1]/*:dateStart"/>
                        
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="//*:part[ID=$useDmdID]//*:event[type='publication'][1]/*:dateStart"/>
                        
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:variable>
               
               
               <xsl:variable name="endDate">
                  
                  <xsl:choose>
                     <xsl:when test="//*:part[ID=$useDmdID]//*:event[type='creation']">
                        <xsl:value-of select="//*:part[ID=$useDmdID]//*:event[type='creation'][1]/*:dateEnd"/>
                        
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="//*:part[ID=$useDmdID]//*:event[type='publication'][1]/*:dateEnd"/>
                        
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:variable>
               
   
               <!--centuries are for date facet-->
               <xsl:variable name="startCentury">
                  <xsl:choose>
                     <xsl:when test="starts-with($startDate, '-')">
                        <xsl:value-of select="substring($startDate, 1,3)"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="substring($startDate, 1,2)"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:variable>
               
               <xsl:variable name="endCentury">
                  <xsl:choose>
                     <xsl:when test="starts-with($endDate, '-')">
                        <xsl:value-of select="substring($endDate, 1,3)"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="substring($endDate, 1,2)"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:variable>
               
               
               <!-- Generate sort-year (if range, only use first year) -->
               <xsl:variable name="startYear" select="parse:year(string($startDate))"/>
               <xsl:variable name="endYear" select="parse:year(string($endDate))"/>
               <xsl:variable name="yearRange" select="concat($startYear,'-',$endYear)"/>
               
               <sort-year xtf:meta="true" xtf:tokenize="no">
                  <xsl:value-of select="$startYear"/>
               </sort-year>
               
               <year xtf:meta="true">
                  <xsl:copy-of select="$yearRange"/>
               </year>
               
               <!--creates date facet-->
               <xsl:call-template name="facet-date">
                  <xsl:with-param name="i" select="$startCentury"/>
                  <xsl:with-param name="count" select="$endCentury"/>
               </xsl:call-template>
               
            </xsl:when>
            <xsl:otherwise>
               
               <xsl:call-template name="inherit-facet-dates">
                  <xsl:with-param name="dmdID" select="$useDmdID"/>
               </xsl:call-template>
               
            </xsl:otherwise>
            
         </xsl:choose>   
         
      </xsl:if>
      
   </xsl:template>
   
   
   <!-- ====================================================================== -->
   <!-- Functions                                                              -->
   <!-- ====================================================================== -->

   <!-- Function to strip html from a string -->
   <xsl:function name="parse:stripHTML">

      <xsl:param name="HTMLText"/>
      <xsl:choose>
         <xsl:when test="contains($HTMLText, '&gt;')">
            <xsl:variable name="text2"
               select="concat(substring-before($HTMLText, '&lt;'), substring-after($HTMLText, '&gt;'))"/>
            <xsl:value-of select="parse:stripHTML($text2)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$HTMLText"/>
         </xsl:otherwise>
      </xsl:choose>

   </xsl:function>



   <!-- Function to parse normalized titles out of titles -->
   <xsl:function name="parse:title">

      <xsl:param name="title"/>

      <!-- Normalize Spaces & Case-->
      <xsl:variable name="lower-title">
         <xsl:value-of select="lower-case(normalize-space($title))"/>
      </xsl:variable>

      <!-- Remove Punctuation -->
      <xsl:variable name="parse-title">
         <xsl:value-of select="replace($lower-title, '[^a-z0-9 ]', '')"/>
      </xsl:variable>

      <!-- Remove Leading Articles -->
      <xsl:choose>
         <xsl:when test="matches($parse-title, '^a ')">
            <xsl:value-of select="replace($parse-title, '^a (.+)', '$1')"/>
         </xsl:when>
         <xsl:when test="matches($parse-title, '^an ')">
            <xsl:value-of select="replace($parse-title, '^an (.+)', '$1')"/>
         </xsl:when>
         <xsl:when test="matches($parse-title, '^the ')">
            <xsl:value-of select="replace($parse-title, '^the (.+)', '$1')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$parse-title"/>
         </xsl:otherwise>
      </xsl:choose>

   </xsl:function>

   <!-- Function to parse last names out of various name formats -->
   <xsl:function name="parse:name">

      <xsl:param name="name"/>

      <!-- Remove accent marks and other diacritics -->
      <xsl:variable name="no-accents-name">
         <xsl:value-of
            select="CharUtils:applyAccentMap('../../../conf/accentFolding/accentMap.txt', $name)"/>
      </xsl:variable>

      <!-- Normalize Spaces & Case-->
      <xsl:variable name="lower-name">
         <xsl:value-of select="lower-case(normalize-space($no-accents-name))"/>
      </xsl:variable>

      <!-- Remove additional authors and information -->
      <xsl:variable name="first-name">
         <xsl:choose>
            <!-- Pattern:  NAME and NAME -->
            <xsl:when test="matches($lower-name, '[^,]+ and.+')">
               <xsl:value-of select="replace($lower-name, '(.+?) and.+', '$1')"/>
            </xsl:when>
            <!-- Pattern:  NAME, NAME and NAME -->
            <xsl:when test="matches($lower-name, ', .+ and')">
               <xsl:value-of select="replace($lower-name, '(.+?), .+', '$1')"/>
            </xsl:when>
            <!-- Pattern:  NAME -->
            <xsl:otherwise>
               <xsl:value-of select="$lower-name"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:choose>
         <!-- Pattern:  NAME, NAME -->
         <xsl:when test="matches($first-name, ', ')">
            <xsl:value-of select="replace($first-name, '(.+?), .+', '$1')"/>
         </xsl:when>
         <!-- Pattern:  'X. NAME' or ' NAME' -->
         <xsl:when test="matches($first-name, '^.+\.? (\w{2,100})')">
            <xsl:value-of select="replace($first-name, '^.+\.? (\w{2,100})', '$1')"/>
         </xsl:when>
         <!-- Pattern:  Everything else -->
         <xsl:otherwise>
            <xsl:value-of select="$first-name"/>
         </xsl:otherwise>
      </xsl:choose>

   </xsl:function>

   <!-- Function to parse years out of various date formats -->
   <xsl:function name="parse:year">
      <xsl:param name="date"/>

      <xsl:choose>

         <!-- Pattern: 1989-12-1 -->
         <xsl:when
            test="matches($date, '([^0-9]|^)(\d\d\d\d)[^0-9]*[\-/][^0-9]*\d\d?[^0-9]*[\-/][^0-9]*\d\d?([^0-9]|$)')">
            <xsl:analyze-string select="$date"
               regex="([^0-9]|^)(\d\d\d\d)[^0-9]*[\-/][^0-9]*\d\d?[^0-9]*[\-/][^0-9]*\d\d?([^0-9]|$)">
               <xsl:matching-substring>
                  <xsl:copy-of select="number(regex-group(2))"/>
               </xsl:matching-substring>
            </xsl:analyze-string>
         </xsl:when>

         <!-- Pattern: 1980 - 1984 -->
         <xsl:when
            test="matches($date, '([^0-9]|^)([12]\d\d\d)[^0-9]*-[^0-9]*([12]\d\d\d)([^0-9]|$)')">
            <xsl:analyze-string select="$date"
               regex="([^0-9]|^)([12]\d\d\d)[^0-9]*-[^0-9]*([12]\d\d\d)([^0-9]|$)">
               <xsl:matching-substring>
                  <xsl:copy-of select="parse:output-range(regex-group(2), regex-group(3))"/>
               </xsl:matching-substring>
            </xsl:analyze-string>
         </xsl:when>

         <!-- Pattern: 1980 - 84 -->
         <xsl:when test="matches($date, '([^0-9]|^)([12]\d\d\d)[^0-9]*-[^0-9]*(\d\d)([^0-9]|$)')">
            <xsl:analyze-string select="$date"
               regex="([^0-9]|^)([12]\d\d\d)[^0-9]*-[^0-9]*(\d\d)([^0-9]|$)">
               <xsl:matching-substring>
                  <xsl:variable name="year1" select="number(regex-group(2))"/>
                  <xsl:variable name="century" select="floor($year1 div 100) * 100"/>
                  <xsl:variable name="pyear2" select="number(regex-group(3))"/>
                  <xsl:variable name="year2" select="$pyear2 + $century"/>
                  <xsl:copy-of select="parse:output-range($year1, $year2)"/>
               </xsl:matching-substring>
            </xsl:analyze-string>
         </xsl:when>

         <!-- Pattern: 1-12-89 -->
         <xsl:when
            test="matches($date, '([^0-9]|^)\d\d?[^0-9]*[\-/][^0-9]*\d\d?[^0-9]*[\-/][^0-9]*(\d\d)([^0-9]|$)')">
            <xsl:analyze-string select="$date"
               regex="([^0-9]|^)\d\d?[^0-9]*[\-/][^0-9]*\d\d?[^0-9]*[\-/][^0-9]*(\d\d)([^0-9]|$)">
               <xsl:matching-substring>
                  <xsl:copy-of select="number(regex-group(2)) + 1900"/>
               </xsl:matching-substring>
            </xsl:analyze-string>
         </xsl:when>

         <!-- Pattern: 19890112 -->
         <xsl:when test="matches($date, '([^0-9]|^)([12]\d\d\d)[01]\d[0123]\d')">
            <xsl:analyze-string select="$date" regex="([^0-9]|^)([12]\d\d\d)[01]\d[0123]\d">
               <xsl:matching-substring>
                  <xsl:copy-of select="number(regex-group(2))"/>
               </xsl:matching-substring>
            </xsl:analyze-string>
         </xsl:when>

         <!-- Pattern: 890112 -->
         <xsl:when test="matches($date, '([^0-9]|^)([4-9]\d)[01]\d[0123]\d')">
            <xsl:analyze-string select="$date" regex="([^0-9]|^)(\d\d)[01]\d[0123]\d">
               <xsl:matching-substring>
                  <xsl:copy-of select="number(regex-group(2)) + 1900"/>
               </xsl:matching-substring>
            </xsl:analyze-string>
         </xsl:when>

         <!-- Pattern: 011291 -->
         <xsl:when test="matches($date, '([^0-9]|^)[01]\d[0123]\d(\d\d)')">
            <xsl:analyze-string select="$date" regex="([^0-9]|^)[01]\d[0123]\d(\d\d)">
               <xsl:matching-substring>
                  <xsl:copy-of select="number(regex-group(2)) + 1900"/>
               </xsl:matching-substring>
            </xsl:analyze-string>
         </xsl:when>

         <!-- Pattern: 1980 -->
         <xsl:when test="matches($date, '([^0-9]|^)([12]\d\d\d)([^0-9]|$)')">
            <xsl:analyze-string select="$date" regex="([^0-9]|^)([12]\d\d\d)([^0-9]|$)">
               <xsl:matching-substring>
                  <xsl:copy-of select="regex-group(2)"/>
               </xsl:matching-substring>
            </xsl:analyze-string>
         </xsl:when>

         <!-- Pattern: any 4 digits starting with 1 or 2 -->
         <xsl:when test="matches($date, '([12]\d\d\d)')">
            <xsl:analyze-string select="$date" regex="([12]\d\d\d)">
               <xsl:matching-substring>
                  <xsl:copy-of select="regex-group(1)"/>
               </xsl:matching-substring>
            </xsl:analyze-string>
         </xsl:when>

      </xsl:choose>

   </xsl:function>

   <!-- Function to parse year ranges -->
   <xsl:function name="parse:output-range">
      <xsl:param name="year1-in"/>
      <xsl:param name="year2-in"/>

      <xsl:variable name="year1" select="number($year1-in)"/>
      <xsl:variable name="year2" select="number($year2-in)"/>

      <xsl:choose>

         <xsl:when test="$year2 > $year1 and ($year2 - $year1) &lt; 500">
            <xsl:for-each select="(1 to 500)">
               <xsl:if test="$year1 + position() - 1 &lt;= $year2">
                  <xsl:value-of select="$year1 + position() - 1"/>
                  <xsl:value-of select="' '"/>
               </xsl:if>
            </xsl:for-each>
         </xsl:when>

         <xsl:otherwise>
            <xsl:value-of select="$year1"/>
            <xsl:value-of select="' '"/>
            <xsl:value-of select="$year2"/>
         </xsl:otherwise>

      </xsl:choose>

   </xsl:function>

   <!-- function to expand date strings -->
   <xsl:function name="expand:date">
      <xsl:param name="date"/>

      <xsl:variable name="year" select="replace($date, '[0-9]+/[0-9]+/([0-9]+)', '$1')"/>

      <xsl:variable name="month">
         <xsl:choose>
            <xsl:when test="matches($date,'^[0-9]/[0-9]+/[0-9]+')">
               <xsl:value-of select="0"/>
               <xsl:value-of select="replace($date, '^([0-9])/[0-9]+/[0-9]+', '$1')"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="replace($date, '([0-9]+)/[0-9]+/[0-9]+', '$1')"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:variable name="day">
         <xsl:choose>
            <xsl:when test="matches($date,'[0-9]+/[0-9]/[0-9]+')">
               <xsl:value-of select="0"/>
               <xsl:value-of select="replace($date, '[0-9]+/([0-9])/[0-9]+', '$1')"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="replace($date, '[0-9]+/([0-9]+)/[0-9]+', '$1')"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:value-of select="concat($year, '::', $month, '::', $day)"/>

   </xsl:function>

   <!-- function to create alpha browse facets -->
   <xsl:function name="parse:alpha">

      <xsl:param name="string"/>

      <!-- Remove accent marks and other diacritics -->
      <xsl:variable name="no-accents-name">
         <xsl:value-of
            select="CharUtils:applyAccentMap('../../../conf/accentFolding/accentMap.txt', $string)"
         />
      </xsl:variable>

      <!-- Normalize Spaces & Case-->
      <xsl:variable name="lower-name">
         <xsl:value-of select="lower-case(normalize-space($no-accents-name))"/>
      </xsl:variable>

      <xsl:choose>
         <xsl:when test="matches($lower-name,'^.*?[a-z].*$')">
            <xsl:value-of select="replace($lower-name,'^.*?([a-z]).*$','$1$1')"/>
         </xsl:when>
         <xsl:otherwise>
            <!-- Can't find any letters... put it on the first tab. -->
            <xsl:value-of select="'aa'"/>
         </xsl:otherwise>
      </xsl:choose>

   </xsl:function>
   
   <!--processes transcription uri for indexing-->
   <xsl:function name="cudl:transcription-uri">
   
      <xsl:param name="uri"/>
      
      <xsl:variable name="uriReplaced" select="replace($uri, 'http://services.cudl.lib.cam.ac.uk/', $servicesURI)"/>
      <xsl:value-of select="concat($uriReplaced, '?apikey=', $apiKey)"></xsl:value-of>
     
   </xsl:function>
   
   <!-- Lookup collections of which this item is a member (from SQL database) -->
   <xsl:function name="cudl:get-memberships">
      <xsl:param name="itemid"/>
      
      <!-- Returns sequence of collection elements -->
      <xsl:for-each select="document(concat($servicesURI, 'v1/rdb/membership/collections/', $itemid))/collections/collection">
         <xsl:copy-of select="."/>
      </xsl:for-each>       
      
   </xsl:function>
   
   <!-- Provide page for reproduction requests, based on repository. Temporary hack: this really neeeds to come from data -->

   <xsl:function name="cudl:get-imageReproPageURL">
      <xsl:param name="repository"/>
      
      <xsl:choose>
         <xsl:when test="$repository='National Maritime Museum'">
            <xsl:text>http://images.rmg.co.uk/en/page/show_home_page.html</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>http://www.lib.cam.ac.uk/deptserv/imagingservices/rights_form/rights_form.html</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   
   </xsl:function>
   
   <!--BROWSE ELEMENTS - NOT CURRENTLY USED-->

      <!-- Generate browse-title -->
      <!--<xsl:template match="*:title" mode="browse">
      <browse-title>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:value-of select="parse:alpha(parse:title(.))"/>
      </browse-title>
      </xsl:template>-->
      
      <!-- Generate browse-name -->
      <!--<xsl:template match="*:name/*:fullForm" mode="browse">
      <browse-name>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      
      <xsl:value-of select="parse:alpha(parse:name(.))"/>
      </browse-name>
      </xsl:template>-->

</xsl:stylesheet>
