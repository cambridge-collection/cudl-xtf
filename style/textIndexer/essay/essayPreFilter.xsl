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
      
      Prefilter for Longitude essay documents. Adapted from CUDL EAD prefilter, which was adapted from the XTF EAD prefilter.
      All essay XML files are pointed here by docSelector.xsl. A variety of templates are then used
      
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
      
   <!-- short-term fudge to get from unitid to docid -->
   
   <xsl:variable name="docs">
      <doc docid="MS-ADD-03968" unitid="Add 3968"/>
      <doc docid="MS-ADD-03969" unitid="Add 3969"/>
      <doc docid="MS-ADD-03971" unitid="Add 3971"/>
      <doc docid="MS-ADD-03972" unitid="Add 3972"/>
      <doc docid="MS-ADD-03976" unitid="Add 3976"/>
      <doc docid="MS-ADD-03977" unitid="Add 3977"/>
      <doc docid="MS-ADD-03978" unitid="Add 3978"/>
      <doc docid="MS-ADD-03979" unitid="Add 3979"/>
      <doc docid="MS-ADD-03980" unitid="Add 3980"/>
      <doc docid="MS-ADD-03982" unitid="Add 3982"/>
      <doc docid="MS-ADD-03983" unitid="Add 3983"/>
      <doc docid="MS-ADD-03984" unitid="Add 3984"/>
      <doc docid="MS-ADD-03985" unitid="Add 3985"/>
      <doc docid="MS-ADD-03986" unitid="Add 3986"/>
      <doc docid="MS-ADD-03990" unitid="Add 3990"/>
      <doc docid="MS-ADD-03993" unitid="Add 3993"/>
      <doc docid="MS-ADD-03995" unitid="Add 3995"/>
      <doc docid="MS-ADD-04002" unitid="Add 4002"/>
      <doc docid="MS-ADD-04003" unitid="Add 4003"/>
      <doc docid="MS-ADD-04005" unitid="Add 4005"/>
      <doc docid="MS-ADD-04006" unitid="Add 4006"/>

      <doc docid="MS-MM-00006-00048" unitid="Mm/6/48"/>
      
      <doc docid="MS-RGO-00004-00001" unitid="RGO 4/1"/>
      <doc docid="MS-RGO-00004-00028" unitid="RGO 4/28"/>
      <doc docid="MS-RGO-00004-00066" unitid="RGO 4/66"/>
      <doc docid="MS-RGO-00004-00084" unitid="RGO 4/84"/>
      <doc docid="MS-RGO-00004-00085" unitid="RGO 4/85"/>
      <doc docid="MS-RGO-00004-00086" unitid="RGO 4/86"/>
      <!--
      <doc docid="MS-RGO-00004-00107" unitid="RGO 4/107"/>
      -->
      <doc docid="MS-RGO-00004-00109" unitid="RGO 4/109"/>
      <doc docid="MS-RGO-00004-00149" unitid="RGO 4/149"/>
      <doc docid="MS-RGO-00004-00150" unitid="RGO 4/150"/>
      <doc docid="MS-RGO-00004-00152" unitid="RGO 4/152"/>
      <doc docid="MS-RGO-00004-00153" unitid="RGO 4/153"/>
      <doc docid="MS-RGO-00004-00154" unitid="RGO 4/154"/>
      <doc docid="MS-RGO-00004-00155" unitid="RGO 4/155 "/>
      <doc docid="MS-RGO-00004-00156" unitid="RGO 4/156"/>
      <doc docid="MS-RGO-00004-00157" unitid="RGO 4/157"/>
      <doc docid="MS-RGO-00004-00158" unitid="RGO 4/158"/>
      <doc docid="MS-RGO-00004-00159" unitid="RGO 4/159"/>
      <doc docid="MS-RGO-00004-00185" unitid="RGO 4/185"/>
      <doc docid="MS-RGO-00004-00186" unitid="RGO 4/186"/>
      <doc docid="MS-RGO-00004-00187" unitid="RGO 4/187"/>
      <doc docid="MS-RGO-00004-00196" unitid="RGO 4/196"/>
      <doc docid="MS-RGO-00004-00219" unitid="RGO 4/219"/>
      <doc docid="MS-RGO-00004-00288" unitid="RGO 4/288"/>
      <doc docid="MS-RGO-00004-00292" unitid="RGO 4/292"/>
      <doc docid="MS-RGO-00004-00310" unitid="RGO 4/310"/>
      <doc docid="MS-RGO-00004-00311" unitid="RGO 4/311"/>
      <doc docid="MS-RGO-00004-00312" unitid="RGO 4/312"/>
      <doc docid="MS-RGO-00004-00320" unitid="RGO 4/320"/>
      <doc docid="MS-RGO-00004-00321" unitid="RGO 4/321"/>
      <doc docid="MS-RGO-00004-00322" unitid="RGO 4/322"/>
      <doc docid="MS-RGO-00004-00323" unitid="RGO 4/323"/>
      <doc docid="MS-RGO-00004-00324" unitid="RGO 4/324"/>

      <doc docid="MS-RGO-00005-00229" unitid="RGO 5/229"/>
      <doc docid="MS-RGO-00005-00230" unitid="RGO 5/230"/>
      <!--
      <doc docid="MS-RGO-00005-00231" unitid="RGO 5/231"/>
      -->
      <doc docid="MS-RGO-00005-00233" unitid="RGO 5/233"/>
      <doc docid="MS-RGO-00005-00237" unitid="RGO 5/237"/>
      <doc docid="MS-RGO-00005-00238" unitid="RGO 5/238"/>

      <doc docid="MS-RGO-00014-00001" unitid="RGO 14/1"/>
      <doc docid="MS-RGO-00014-00002" unitid="RGO 14/2"/>
      <doc docid="MS-RGO-00014-00003" unitid="RGO 14/3"/>
      <doc docid="MS-RGO-00014-00004" unitid="RGO 14/4"/>
      <doc docid="MS-RGO-00014-00005" unitid="RGO 14/5"/>
      <doc docid="MS-RGO-00014-00006" unitid="RGO 14/6"/>
      <doc docid="MS-RGO-00014-00007" unitid="RGO 14/7"/>
      <doc docid="MS-RGO-00014-00008" unitid="RGO 14/8"/>
      <doc docid="MS-RGO-00014-00009" unitid="RGO 14/9"/>
      <doc docid="MS-RGO-00014-00010" unitid="RGO 14/10"/>
      <doc docid="MS-RGO-00014-00011" unitid="RGO 14/11"/>
      <doc docid="MS-RGO-00014-00012" unitid="RGO 14/12"/>
      <doc docid="MS-RGO-00014-00013" unitid="RGO 14/13"/>
      <doc docid="MS-RGO-00014-00014" unitid="RGO 14/14"/>
      <doc docid="MS-RGO-00014-00015" unitid="RGO 14/15"/>
      <doc docid="MS-RGO-00014-00016" unitid="RGO 14/16"/>
      <doc docid="MS-RGO-00014-00017" unitid="RGO 14/17"/>
      <doc docid="MS-RGO-00014-00018" unitid="RGO 14/18"/>
      <doc docid="MS-RGO-00014-00019" unitid="RGO 14/19"/>
      <doc docid="MS-RGO-00014-00020" unitid="RGO 14/20"/>
      <doc docid="MS-RGO-00014-00021" unitid="RGO 14/21"/>
      <doc docid="MS-RGO-00014-00022" unitid="RGO 14/22"/>
      <doc docid="MS-RGO-00014-00023" unitid="RGO 14/23"/>
      <doc docid="MS-RGO-00014-00024" unitid="RGO 14/24"/>
      <doc docid="MS-RGO-00014-00025" unitid="RGO 14/25"/>
      <doc docid="MS-RGO-00014-00026" unitid="RGO 14/26"/>
      <doc docid="MS-RGO-00014-00027" unitid="RGO 14/27"/>
      <doc docid="MS-RGO-00014-00028" unitid="RGO 14/28"/>
      <doc docid="MS-RGO-00014-00029" unitid="RGO 14/29"/>
      <doc docid="MS-RGO-00014-00030" unitid="RGO 14/30"/>
      <doc docid="MS-RGO-00014-00031" unitid="RGO 14/31"/>
      <doc docid="MS-RGO-00014-00032" unitid="RGO 14/32"/>
      <doc docid="MS-RGO-00014-00033" unitid="RGO 14/33"/>
      <doc docid="MS-RGO-00014-00034" unitid="RGO 14/34"/>
      <doc docid="MS-RGO-00014-00035" unitid="RGO 14/35"/>
      <doc docid="MS-RGO-00014-00036" unitid="RGO 14/36"/>
      <doc docid="MS-RGO-00014-00037" unitid="RGO 14/37"/>
      <doc docid="MS-RGO-00014-00038" unitid="RGO 14/38"/>
      <doc docid="MS-RGO-00014-00039" unitid="RGO 14/39"/>
      <doc docid="MS-RGO-00014-00040" unitid="RGO 14/40"/>
      <doc docid="MS-RGO-00014-00041" unitid="RGO 14/41"/>
      <doc docid="MS-RGO-00014-00042" unitid="RGO 14/42"/>
      <doc docid="MS-RGO-00014-00043" unitid="RGO 14/43"/>
      <doc docid="MS-RGO-00014-00044" unitid="RGO 14/44"/>
      <doc docid="MS-RGO-00014-00045" unitid="RGO 14/45"/>
      <doc docid="MS-RGO-00014-00046" unitid="RGO 14/46"/>
      <doc docid="MS-RGO-00014-00047" unitid="RGO 14/47"/>
      <doc docid="MS-RGO-00014-00048" unitid="RGO 14/48"/>
      <doc docid="MS-RGO-00014-00049" unitid="RGO 14/49"/>
      <doc docid="MS-RGO-00014-00050" unitid="RGO 14/50"/>
      <doc docid="MS-RGO-00014-00051" unitid="RGO 14/51"/>
      <doc docid="MS-RGO-00014-00052" unitid="RGO 14/52"/>
      <doc docid="MS-RGO-00014-00053" unitid="RGO 14/53"/>
      <doc docid="MS-RGO-00014-00054" unitid="RGO 14/54"/>
      <doc docid="MS-RGO-00014-00055" unitid="RGO 14/55"/>
      <doc docid="MS-RGO-00014-00056" unitid="RGO 14/56"/>
      <doc docid="MS-RGO-00014-00057" unitid="RGO 14/57"/>
      <doc docid="MS-RGO-00014-00058" unitid="RGO 14/58"/>
      <doc docid="MS-RGO-00014-00059" unitid="RGO 14/59"/>
      <doc docid="MS-RGO-00014-00060" unitid="RGO 14/60"/>
      <doc docid="MS-RGO-00014-00061" unitid="RGO 14/61"/>
      <doc docid="MS-RGO-00014-00062" unitid="RGO 14/62"/>
      <doc docid="MS-RGO-00014-00063" unitid="RGO 14/63"/>
      <doc docid="MS-RGO-00014-00064" unitid="RGO 14/64"/>
      <doc docid="MS-RGO-00014-00065" unitid="RGO 14/65"/>
      <doc docid="MS-RGO-00014-00066" unitid="RGO 14/66"/>
      <doc docid="MS-RGO-00014-00067" unitid="RGO 14/67"/>
      <doc docid="MS-RGO-00014-00068" unitid="RGO 14/68"/>

      <doc docid="MS-ADM-A-02528" unitid="ADM/A/2528"/>
      <doc docid="MS-ADM-A-02539" unitid="ADM/A/2539"/>
      <doc docid="MS-ADM-A-02551" unitid="ADM/A/2551"/>
      <doc docid="MS-ADM-A-02572" unitid="ADM/A/2572"/>
      <doc docid="MS-ADM-A-02869" unitid="ADM/A/2869"/>
      <doc docid="MS-ADM-L-C-00082" unitid="ADM/L/C/82"/>
      <doc docid="MS-ADM-L-O-00027" unitid="ADM/L/O/27"/>
      <doc docid="MS-ADM-L-O-00028" unitid="ADM/L/O/28"/>
      <doc docid="MS-ADM-L-O-00029-A" unitid="ADM/L/O/29A"/>
      <doc docid="MS-ADM-L-P-00330" unitid="ADM/L/P/330"/>
      <doc docid="MS-ADM-L-P-00331" unitid="ADM/L/P/331"/>
      <doc docid="MS-ADM-L-T-00022" unitid="ADM/L/T/22"/>
      <doc docid="MS-ADM-L-T-00023" unitid="ADM/L/T/23"/>
      
      <doc docid="MS-AGC-00008-00029" unitid="AGC/8/29"/>
      <doc docid="MS-AGC-M-00016" unitid="AGC/M/16"/>
      
      <doc docid="MS-BGN-00000" unitid="BGN"/>

      <doc docid="MS-FIS-00001" unitid="FIS/1"/>
      <doc docid="MS-FIS-00003" unitid="FIS/3"/>
      <doc docid="MS-FIS-00004" unitid="FIS/4"/>
      <doc docid="MS-FIS-00005" unitid="FIS/5"/>
      <doc docid="MS-FIS-00006-A" unitid="FIS/6/A"/>
      <doc docid="MS-FIS-00006-B" unitid="FIS/6/B"/>
      <doc docid="MS-FIS-00007" unitid="FIS/7"/>
      <doc docid="MS-FIS-00008" unitid="FIS/8"/>
      <doc docid="MS-FIS-00009" unitid="FIS/9"/>
      <doc docid="MS-FIS-00010" unitid="FIS/10"/>
      <doc docid="MS-FIS-00011-00001" unitid="FIS/11/1"/>
      <doc docid="MS-FIS-00011-00002" unitid="FIS/11/2"/>
      <doc docid="MS-FIS-00012" unitid="FIS/12"/>
      <doc docid="MS-FIS-00019-00001" unitid="FIS/19/1"/>
      <doc docid="MS-FIS-00020" unitid="FIS/20"/>
      <doc docid="MS-FIS-00021" unitid="FIS/21"/>
      <doc docid="MS-FIS-00022" unitid="FIS/22"/>
      <doc docid="MS-FIS-00023" unitid="FIS/23"/>
      <doc docid="MS-FIS-00030" unitid="FIS/30"/>
      
      <doc docid="MS-G-00298-00001-00003" unitid="G298:1/3"/>
      
      <doc docid="MS-HMN-00029" unitid="HMN/29"/>
      <doc docid="MS-HMN-00031" unitid="HMN/31"/>
      <doc docid="MS-HMN-00044" unitid="HMN/44"/>
      <doc docid="MS-JOD-00019" unitid="JOD/19"/>
      <doc docid="MS-JOD-00020" unitid="JOD/20"/>
      <doc docid="MS-JOD-00056" unitid="JOD/56"/>
      <doc docid="MS-MKY-00006" unitid="MKY/6"/>
      <doc docid="MS-MKY-00008" unitid="MKY/8"/>
      <doc docid="MS-MKY-00009" unitid="MKY/9"/>

      <doc docid="MS-MSS-00079-00130-00002" unitid="MSS/79/130.2"/>
      <doc docid="MS-NVT-00005" unitid="NVT/5"/>
      <doc docid="MS-PLT-00073-00002" unitid="PLT/73/2"/>
      <doc docid="MS-POR-H-00008" unitid="POR/H/8"/>
      <!--
         <doc docid="MS-REG-00009-000225" unitid="REG09/000225"/>
      -->
      <doc docid="MS-REG-00009-00037" unitid="REG09/000037"/>
      <!--
      <doc docid="MS-REG-00012-00011" unitid="REG12/000011"/>
      -->
      <doc docid="MS-SAN-F-00002" unitid="SAN/F/2"/>
      <doc docid="MS-SAN-F-00004" unitid="SAN/F/4"/>
      <doc docid="MS-SAN-F-00036" unitid="SAN/F/36"/>
      <doc docid="MS-ZAA-00881" unitid="ZAA0881"/>
      <doc docid="MS-ZAA-00882" unitid="ZAA0882"/>
      <doc docid="MS-ZAA-00883" unitid="ZAA0883"/>
      
   </xsl:variable>
   
   
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
         
         <!--
         <itemType>
            <type>essay</type>
         </itemType>
         -->
         <itemType>essay</itemType>
         
         <xsl:call-template name="make-metadata"/>
         
         <xsl:call-template name="get-numberOfPages"/>
         <xsl:call-template name="make-page" /> 
         <xsl:call-template name="make-logical-structure" /> 
         
<!--         <xsl:call-template name="make-content-page" /> --> 
                  
      </xsl:variable>
      
      <!-- Add doc kind and sort fields to the data, and output the result. -->
      <xsl:call-template name="add-fields">
         <xsl:with-param name="display" select="'dynaxml'"/>
         <xsl:with-param name="meta" select="$meta"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template name="make-metadata">
      
      <descriptiveMetadata>
         
         <xsl:apply-templates select="*:essay" />
         
      </descriptiveMetadata>
      
   </xsl:template>
      
   <xsl:template match="*:essay">
      
      <xsl:call-template name="make-metadata-part" />
            
   </xsl:template>

   <xsl:template name="make-metadata-part">
      
      <part>
         <xsl:call-template name="get-dmdID"/>
         <xsl:call-template name="get-title"/>
                  
         <xsl:call-template name="get-authors"/>
                  
         <xsl:call-template name="get-content"/>      
         
         <xsl:call-template name="get-subjects"/>
         
         <xsl:call-template name="get-mentioned-persons"/>
         
         <xsl:call-template name="get-mentioned-corporates"/>         
         
         <xsl:call-template name="get-mentioned-places"/>         
         
         <xsl:call-template name="get-dates"/>         
         
         <xsl:call-template name="get-archrefs"/>
                  
         <xsl:call-template name="get-thumbnail"/>       
         
         <xsl:call-template name="get-collection-memberships"/>       
      </part>
      
   </xsl:template>   
      
   <xsl:template name="get-dmdID">
            
      <xsl:attribute name="xtf:subDocument" select="'essay'"/>
      
      <xsl:element name="ID">essay</xsl:element>      
      
      <xsl:element name="fileID">
         <xsl:value-of select="$fileID"/>
      </xsl:element>
            
      <xsl:element name="startPageLabel">
         <xsl:text>1</xsl:text>
      </xsl:element>

      <xsl:element name="startPage">
         <xsl:text>1</xsl:text>
      </xsl:element>
      
   </xsl:template>   

   <xsl:template name="get-title">
      
      <xsl:variable name="title">
         <xsl:choose>
            <xsl:when test="normalize-space(*:title)">
               <xsl:value-of select="normalize-space(*:title)" />
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
   
   <xsl:template name="get-authors">
      
      <xsl:if test="exists(*:author)">
         <xsl:element name="authors">
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:apply-templates select="*:author"/>
            
         </xsl:element>            
      </xsl:if>
            
   </xsl:template>
   
   <xsl:template match="*:author">
      
      <xsl:element name="name">
         <xsl:attribute name="display" select="'true'" />
         <xsl:attribute name="displayForm" select="." />
         <xsl:element name="shortForm">
            <xsl:value-of select="normalize-space(.)" />
         </xsl:element>
      </xsl:element>
   
   </xsl:template>
      
   <xsl:template name="get-content">
      
      <xsl:element name="content">
         
         <xsl:variable name="content">
            <xsl:text>&lt;div&gt;</xsl:text>
            <xsl:apply-templates select="*:p|*:list" mode="html"/>
            <xsl:text>&lt;/div&gt;</xsl:text>
         </xsl:variable>
                        
         <xsl:value-of select="normalize-space(replace($content, '&lt;[^&gt;]+&gt;', ''))"/>
            
      </xsl:element>
      
   </xsl:template>
      
   
   <xsl:template name="get-mentioned-persons">
      
      <xsl:if test="exists(*:mentions/*:persname)">
         <xsl:element name="associated">
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:apply-templates select="*:mentions/*:persname" />
         </xsl:element>
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template match="*:mentions/*:persname">
      
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
         <xsl:otherwise>
            <!-- Not AACR2 rules name : use if no AACR2 name present -->
            
            <xsl:choose>
               <xsl:when test="normalize-space(@normal)">
                  <xsl:variable name="persnormal" select="normalize-space(@normal)"/>
                  
                  <xsl:if test="empty(../*[@normal=$persnormal and @rules='AACR2'])">
                     
                     <xsl:element name="name">
                        <xsl:attribute name="display" select="'true'" />
                        <xsl:attribute name="displayForm" select="normalize-space(.)" />
                        <xsl:element name="fullForm">
                           <xsl:value-of select="$persnormal" />
                        </xsl:element>               
                        <xsl:element name="shortForm">
                           <xsl:value-of select="normalize-space(.)" />
                        </xsl:element>               
                     </xsl:element>
                     
                  </xsl:if>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:element name="name">
                     <xsl:attribute name="display" select="'true'" />
                     <xsl:attribute name="displayForm" select="normalize-space(.)" />
                     <xsl:element name="shortForm">
                        <xsl:value-of select="normalize-space(.)" />
                     </xsl:element>               
                  </xsl:element>
                  
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   
   <xsl:template name="get-mentioned-corporates">
      
      <xsl:if test="exists(*:mentions/*:corpname)">
         <xsl:element name="associatedCorps">
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:apply-templates select="*:mentions/*:corpname" />
         </xsl:element>
      </xsl:if>
      
   </xsl:template>
      
   <xsl:template match="*:mentions/*:corpname">
      
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
         <xsl:otherwise>
            <!-- Not AACR2 rules name : use if no AACR2 name present -->
            
            <xsl:choose>
               <xsl:when test="normalize-space(@normal)">
                  <xsl:variable name="corpnormal" select="normalize-space(@normal)"/>
                  
                  <xsl:if test="empty(../*[@normal=$corpnormal and @rules='AACR2'])">
                     
                     <xsl:element name="name">
                        <xsl:attribute name="display" select="'true'" />
                        <xsl:attribute name="displayForm" select="normalize-space(.)" />
                        <xsl:element name="fullForm">
                           <xsl:value-of select="$corpnormal" />
                        </xsl:element>               
                        <xsl:element name="shortForm">
                           <xsl:value-of select="normalize-space(.)" />
                        </xsl:element>               
                     </xsl:element>
                     
                  </xsl:if>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:element name="name">
                     <xsl:attribute name="display" select="'true'" />
                     <xsl:attribute name="displayForm" select="normalize-space(.)" />
                     <xsl:element name="shortForm">
                        <xsl:value-of select="normalize-space(.)" />
                     </xsl:element>               
                  </xsl:element>
                  
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   
   <xsl:template name="get-mentioned-places">
      
      <xsl:if test="exists(*:mentions/*:geogname)">
         <xsl:element name="places">
            <xsl:attribute name="display" select="'true'" />
            
            <xsl:apply-templates select="*:mentions/*:geogname" />
         </xsl:element>
      </xsl:if>
         
   </xsl:template>
   
   <xsl:template match="*:mentions/*:geogname">
      
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
                     <xsl:when test="normalize-space(../*[@normal=$placenormal and @source='Getty_thesaurus'][1])">
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
            <!-- Not Getty TGN or Geonames. Use if no Getty name -->
            
            <xsl:choose>
               <xsl:when test="normalize-space(@normal)">
                  <xsl:variable name="geognormal" select="normalize-space(@normal)"/>
                  
                  <xsl:if test="empty(../*[@normal=$geognormal and @source='Getty_thesaurus'])">
                     
                     <xsl:element name="name">
                        <xsl:attribute name="display" select="'true'" />
                        <xsl:attribute name="displayForm" select="normalize-space(.)" />
                        <xsl:element name="fullForm">
                           <xsl:value-of select="$geognormal" />
                        </xsl:element>               
                        <xsl:element name="shortForm">
                           <xsl:value-of select="normalize-space(.)" />
                        </xsl:element>               
                     </xsl:element>
                     
                  </xsl:if>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:element name="name">
                     <xsl:attribute name="display" select="'true'" />
                     <xsl:attribute name="displayForm" select="normalize-space(.)" />
                     <xsl:element name="shortForm">
                        <xsl:value-of select="normalize-space(.)" />
                     </xsl:element>               
                  </xsl:element>
                  
               </xsl:otherwise>
            </xsl:choose>
            
         </xsl:otherwise>
      
      </xsl:choose>

   </xsl:template>
   
   <xsl:template name="get-thumbnail">
      
      <xsl:apply-templates select="*:thumbnail" />
      
   </xsl:template>
   
   <xsl:template match="*:thumbnail">
      
      <xsl:variable name="imageURI" select="normalize-space(@href)"/>
      <xsl:variable name="imageURIShort" select="replace($imageURI, 'http://cudl.lib.cam.ac.uk/','/')"/>
      <xsl:element name="thumbnailUrl">
         <xsl:value-of select="$imageURIShort"/>                  
      </xsl:element>
      
      <xsl:element name="thumbnailOrientation">
         <xsl:choose>
            <xsl:when test="normalize-space(@orientation)">
               <xsl:value-of select="normalize-space(@orientation)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>portrait</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
      
   </xsl:template>
   
   <xsl:template name="get-dates">
      
      <xsl:if test="exists(//*:date)">
         <xsl:element name="temporalCoverage">
            <!-- currently non-display: only used to generate date facets -->
            <xsl:apply-templates select="//*:date" />
         
         </xsl:element>
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template match="*:date">
      
      <xsl:if test="matches(normalize-space(.), '^\d{4}$')">
         
         <xsl:element name="period">
            
            <xsl:element name="dateStart">
               <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
            
            <xsl:element name="dateEnd">
               <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
            
            <xsl:element name="dateDisplay">
               <xsl:attribute name="display" select="'true'" />            
               <xsl:attribute name="displayForm" select="normalize-space(.)"/>            
               <xsl:value-of select="normalize-space(.)" />            
            </xsl:element>
         </xsl:element>
         
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template name="get-archrefs">
      
      <xsl:if test="exists(*:archrefs)">
         <xsl:element name="itemReferences">
            <xsl:variable name="itemrefs">
            	<xsl:apply-templates select="*:archrefs/*:archref[normalize-space(*:unitid)]" />
            </xsl:variable>
            <!-- itemrefs may contain duplicates (from e.g. refs to multiple components in same unit) so now dedup -->
            <xsl:for-each-group select="$itemrefs/item" group-by="ID">
               <xsl:copy-of select="."/>            
            </xsl:for-each-group>
         </xsl:element>
      </xsl:if>
   
   </xsl:template>
   
   <xsl:template match="*:archrefs/*:archref[normalize-space(*:unitid)]">
      
      <!-- Trim down to top-level (= CUDL item) links -->
                  
         <xsl:variable name="targetArch">
            <xsl:choose>
               <xsl:when test="contains(*:unitid, ':')">
                  <!-- i.e. link to component -->                     
                  <xsl:value-of select="normalize-space(substring-before(*:unitid, ':'))"/>                     
               </xsl:when>
               <xsl:otherwise>
                  <!-- i.e. link to top-level -->
                  <xsl:value-of select="normalize-space(*:unitid)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
                        
         <xsl:if test="$docs/doc[@unitid=$targetArch]/@docid">
            <xsl:element name="item">
               <xsl:element name="ID">
                  <xsl:value-of select="$docs/doc[@unitid=$targetArch]/@docid"/>
               </xsl:element>
            </xsl:element>
         </xsl:if>
      
   </xsl:template>
   
   <xsl:template name="get-subjects">
      
      <xsl:if test="exists(*:subjects)">
         <xsl:element name="subjects">
            <xsl:attribute name="display" select="'true'" />            
            <xsl:apply-templates select="*:subjects/*" />
         </xsl:element>
      </xsl:if>
      
   </xsl:template>
   
   <xsl:template match="*:subjects/*:concept">
         
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
               
   </xsl:template>
   
   <xsl:template name="get-collection-memberships">
      <!-- Lookup collections of which this item is a member (from SQL database) -->
      
      <xsl:element name="collections">
         <xsl:for-each select="cudl:get-memberships($fileID)">
            <xsl:element name="collection">
               <xsl:value-of select="@label"/>
            </xsl:element>
         </xsl:for-each>         
      </xsl:element>
      
   </xsl:template>
   
   <!-- number of pages -->
   <xsl:template name="get-numberOfPages">
      <numberOfPages>1</numberOfPages>
   </xsl:template>
   
   
   <xsl:template name="make-page">
      
      <xsl:element name="pages">         
            
            <xsl:element name="page">
               <xsl:element name="label">1</xsl:element>
               <xsl:element name="physID">PHYS-1</xsl:element>
               <xsl:element name="sequence">
                  <xsl:value-of select="position()"/>
               </xsl:element>
               <xsl:element name="content">
                  
                  <xsl:variable name="content">
                     <xsl:text>&lt;div&gt;</xsl:text>
                     <xsl:apply-templates select="/*:essay/*:p|/*:essay/*:list" mode="html"/>
                     <xsl:text>&lt;/div&gt;</xsl:text>
                  </xsl:variable>
                                    
                  <xsl:value-of select="normalize-space($content)"/>
                  
               </xsl:element>
            </xsl:element>
         
      </xsl:element>
         
   </xsl:template>   
   
   <xsl:template name="make-logical-structure">
      
      <xsl:element name="logicalStructures">
         
         <xsl:element name="logicalStructure">
            
            <xsl:element name="descriptiveMetadataID">essay</xsl:element>
            
            <xsl:element name="label">
               <xsl:value-of select="normalize-space(/*:essay/*:title)" />
            </xsl:element>

            <xsl:element name="startPageLabel">1</xsl:element>
            <xsl:element name="startPagePosition">1</xsl:element>
            <xsl:element name="startPageID">1</xsl:element>
            
            <xsl:element name="endPageLabel">1</xsl:element>
            <xsl:element name="endPagePosition">1</xsl:element>
            <xsl:element name="endPageID">1</xsl:element>
            
         </xsl:element>
         
      </xsl:element>
   
   </xsl:template>
   
   <xsl:template match="*:p" mode="html">
      
      <xsl:text>&lt;p&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/p&gt; </xsl:text> 
      
   </xsl:template>
   
   <xsl:template match="text()" mode="html">
      
      <xsl:value-of select="."/>
      
   </xsl:template>
   
   <xsl:template match="*:lb" mode="html">
      
      <xsl:text>&lt;br /&gt; </xsl:text>
      
   </xsl:template>
   
   <xsl:template match="*:list" mode="html">
      
      <xsl:text>&lt;ul&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/ul&gt; </xsl:text> 
      
   </xsl:template>
   
   <xsl:template match="*:item" mode="html">
      
      <xsl:text>&lt;li&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/li&gt; </xsl:text> 
      
   </xsl:template>
   
   <xsl:template match="*:emph[not(normalize-space(@render))]" mode="html">
      
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

   <xsl:template match="*[@render='underline']" mode="html">
      
      <xsl:text>&lt;i style="text-decoration: underline;"&gt;</xsl:text>
      <xsl:apply-templates mode="html" />
      <xsl:text>&lt;/i&gt;</xsl:text>
      
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
   
   <xsl:template match="*:p//*:persname|*:p//*:corpname|*:p//*:geogname" mode="html">
      
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
               
               <xsl:value-of select="normalize-space(substring-after(*:unitid,':'))"/>
               
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
                  <xsl:value-of select="normalize-space(normalize-space(substring-after(*:unitid, ':')))"/>                  
                  <xsl:text>&lt;/a&gt;</xsl:text>    
                  
               </xsl:when>
               
               
               <!--if it is a link to another document-->
               <xsl:otherwise>
                  
                  
                  <xsl:variable name="targetPageNo">
                     
                     <xsl:choose>
                        
                        <xsl:when test="normalize-space($idTargetFoliation)">
                           
                           <xsl:variable name="targetURI" select="replace(base-uri(), concat('essay/',$fileID, '/', $fileID, '.xml'), concat('ead/',$idFileName, '/', $idFileName, '.xml'))"/>
                           
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
   
   <!--<xsl:template match="*:archref" mode="html">
            
      <xsl:choose>
         <xsl:when test="normalize-space(*:unitid)">
            
            <xsl:if test="text()|*[not(local-name()='unitid')]">
               <xsl:apply-templates mode="html" select="text()|*[not(local-name()='unitid')]"/>                  
               <xsl:text> [</xsl:text>
            </xsl:if>
            
            <xsl:variable name="targetArch">
               <xsl:choose>
                  <xsl:when test="contains(*:unitid, ':')">
                     <!-\- i.e. link to component -\->
                     <!-\-<xsl:value-of select="normalize-space(substring-before(substring-after(*:unitid, 'MS '), ':'))"/>-\->
                     
                     <xsl:value-of select="normalize-space(substring-before(*:unitid, ':'))"/>
                     
                  </xsl:when>
                  <xsl:otherwise>
                     <!-\- i.e. link to top-level -\->
                     <xsl:value-of select="normalize-space(*:unitid)"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            
            <xsl:variable name="targetLabel">
               <xsl:choose>
                  <xsl:when test="contains(*:unitid, ':')">
                     <!-\- i.e. link to component -\->
                     <xsl:choose>
                        <xsl:when test="contains(substring-after(*:unitid, ':'), '-')">
                           <!-\- i.e. link to range, so get start -\->
                           <xsl:value-of select="normalize-space(substring-before(substring-after(*:unitid, ':'), '-'))"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <!-\- i.e. link to single page so use as is -\->
                           <xsl:value-of select="normalize-space(substring-after(*:unitid, ':'))"/>                           
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="*:unitid"/>
                  </xsl:otherwise>
               </xsl:choose>               
            </xsl:variable>
            
                  
                  <xsl:choose>
                     <xsl:when test="$docs/doc[@unitid=$targetArch]/@docid">                        
                        <xsl:variable name="targetDoc" select="$docs/doc[@unitid=$targetArch]/@docid"/>
                        <xsl:variable name="targetURI" select="concat('../../ead/', $targetDoc, '/', $targetDoc, '.xml')"/>
                        
                        <xsl:variable name="targetPageNo">
                           <xsl:choose>
                              <xsl:when test="normalize-space($targetLabel)">
                                 
                                 <xsl:choose>
                                    <xsl:when test="document($targetURI, /)/*:ead/*:archdesc/*:daogrp/*:daoloc[@role='pageImage' and @label=$targetLabel]">
                                       <!-\- match for target label -\->
                                       <xsl:value-of select="substring-after(document($targetURI, /)/*:ead/*:archdesc/*:daogrp/*:daoloc[@role='pageImage' and @label=$targetLabel]/@id, '-')"/>                                 
                                    </xsl:when>
                                    <xsl:when test="document($targetURI, /)/*:ead/*:archdesc/*:daogrp/*:daoloc[@role='pageImage' and @label=concat($targetLabel, 'r')]">
                                       <!-\- match for target label + 'r' -\->
                                       <xsl:value-of select="substring-after(document($targetURI, /)/*:ead/*:archdesc/*:daogrp/*:daoloc[@role='pageImage' and @label=concat($targetLabel, 'r')]/@id, '-')"/>                                 
                                    </xsl:when>
                                    <xsl:when test="document($targetURI, /)/*:ead/*:archdesc/*:daogrp/*:daoloc[@role='pageImage' and @label=concat($targetLabel, 'v')]">
                                       <!-\- match for target label + 'v' -\->
                                       <xsl:value-of select="substring-after(document($targetURI, /)/*:ead/*:archdesc/*:daogrp/*:daoloc[@role='pageImage' and @label=concat($targetLabel, 'v')]/@id, '-')"/>                                 
                                    </xsl:when>                                    
                                    <xsl:when test="document($targetURI, /)/*:ead/*:archdesc/*:daogrp/*:daoloc[@role='pageImage' and @label=concat($targetLabel, '(r)')]">
                                       <!-\- match for target label + '(r)' -\->
                                       <xsl:value-of select="substring-after(document($targetURI, /)/*:ead/*:archdesc/*:daogrp/*:daoloc[@role='pageImage' and @label=concat($targetLabel, '(r)')]/@id, '-')"/>                                 
                                    </xsl:when>
                                    <xsl:when test="document($targetURI, /)/*:ead/*:archdesc/*:daogrp/*:daoloc[@role='pageImage' and @label=concat($targetLabel, '(v)')]">
                                       <!-\- match for target label + '(v)' -\->
                                       <xsl:value-of select="substring-after(document($targetURI, /)/*:ead/*:archdesc/*:daogrp/*:daoloc[@role='pageImage' and @label=concat($targetLabel, '(v)')]/@id, '-')"/>                                 
                                    </xsl:when>                                                                       
                                    <xsl:otherwise>
                                       <!-\- meh - can't match target label -\->
                                    </xsl:otherwise>                                                         
                                 </xsl:choose>
                                 
                              </xsl:when>
                              <xsl:otherwise>
                                 <!-\- no label so set target = first page -\->
                                 <xsl:value-of select="substring-after(document($targetURI, /)/*:ead/*:archdesc/*:daogrp/*:daoloc[@role='pageImage'][1]/@id, '-')"/>                                 
                              </xsl:otherwise>
                           </xsl:choose>
                        </xsl:variable>
                        
                        <xsl:text>&lt;a href=&apos;</xsl:text>
                        <xsl:value-of select="concat('/view/', $targetDoc, '/', $targetPageNo)"/>
                        <xsl:text>&apos;&gt;</xsl:text>
                        <xsl:value-of select="normalize-space(unitid)"/>                  
                        <xsl:text>&lt;/a&gt;</xsl:text>                  
                                        
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="normalize-space(unitid)"/>                                          
                     </xsl:otherwise>
                  </xsl:choose>

            <xsl:if test="text()|*[not(local-name()='unitid')]">
               <xsl:text>]</xsl:text>
            </xsl:if>
         
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates mode="html" />
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>-->
   
</xsl:stylesheet>
