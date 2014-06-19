<xsl:stylesheet version="2.0" 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xtf="http://cdlib.org/xtf"
   xmlns:session="java:org.cdlib.xtf.xslt.Session"
   xmlns:editURL="http://cdlib.org/xtf/editURL"
   xmlns:local="http://local"
   xmlns="http://www.w3.org/1999/xhtml"
   extension-element-prefixes="session"
   exclude-result-prefixes="#all">
   
   <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
   <!-- BookReader dynaXML Stylesheet                                          -->
   <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
   
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
   
   
   <!-- ====================================================================== -->
   <!-- Import Common Templates                                                -->
   <!-- ====================================================================== -->
   
   <xsl:import href="../common/docFormatterCommon.xsl"/>
   <xsl:import href="../../../xtfCommon/xtfCommon.xsl"/>
   
   <!-- ====================================================================== -->
   <!-- Output Format                                                          -->
   <!-- ====================================================================== -->
   
   <xsl:output method="text" indent="yes" 
      encoding="UTF-8" media-type="text/json; charset=UTF-8" 
      exclude-result-prefixes="#all"
      omit-xml-declaration="yes"/>
   
   <!--NOT CURRENTLY NEEDED - NEEDS WORK-->
   <!--function for json escaping-->
   <!--<xsl:function name="js:escape">
      <xsl:param name="text" />
      <xsl:value-of select='replace($text, "&apos;", "\\&apos;")'/>
      <xsl:value-of select="replace($text, '&quot;', '\\&quot;')"/>
   </xsl:function>-->
   
   <!-- ====================================================================== -->
   <!-- Strip Space                                                            -->
   <!-- ====================================================================== -->
   
   <xsl:strip-space elements="*"/>
   
   <!-- ====================================================================== -->
   <!-- Included Stylesheets                                                   -->
   <!-- ====================================================================== -->
   
   <xsl:include href="search.xsl"/>
   
   <!-- ====================================================================== -->
   <!-- Define Keys                                                            -->
   <!-- ====================================================================== -->
   
   <xsl:key name="div-id" match="sec" use="@id"/>
   
   <!-- ====================================================================== -->
   <!-- Define Parameters                                                      -->
   <!-- ====================================================================== -->
   
   <xsl:param name="root.URL"/>

   <xsl:param name="doc.title" select="xtf-converted/xtf:meta/title"/>
   <xsl:param name="doc.images" select="xtf-converted/xtf:meta/image"/>

   <xsl:param name="servlet.dir"/>
   <!-- for docFormatterCommon.xsl -->
   <xsl:param name="css.path" select="'css/default/'"/>
   <xsl:param name="icon.path" select="'css/default/'"/>
    <xsl:param name="doc.full" select="/"/>
   <!-- =========================================<xsl:param name="doc.title" select="'title'"/>============================= -->
   <!-- Root Template                                                          -->
   <!-- ====================================================================== -->
   
   <xsl:template match="/">

      <xsl:choose>
         <!-- robot solution -->
         <xsl:when test="matches($http.user-agent,$robots)">
            <xsl:call-template name="robot"/>
         </xsl:when>
         <xsl:when test="$doc.view='citation'">
            <xsl:call-template name="citation"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="json"/>

         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- ====================================================================== -->
   <!-- Content Template                                                       -->
   <!-- ====================================================================== -->
   
   <xsl:template name="json">
               {
               "title":"<xsl:value-of select="xtf-converted/xtf:meta/title"/>",
               "uniformTitle":"<xsl:value-of select="xtf-converted/xtf:meta/uniformTitle"/>",
               "author":[
               "<xsl:value-of separator='","' select='xtf-converted/xtf:meta/creator'></xsl:value-of>"
               ],
               "contributor":[
               "<xsl:value-of separator='","' select='xtf-converted/xtf:meta/contributor'></xsl:value-of>"
               ],
               "abstract":"<xsl:value-of select="xtf-converted/xtf:meta/abstract"/>",
               "subject":[
               "<xsl:value-of separator='","' select='xtf-converted/xtf:meta/subject'></xsl:value-of>"
               ],
               "publisher":[
               "<xsl:value-of separator='","' select='xtf-converted/xtf:meta/publisher'></xsl:value-of>"
               ],
               "publicationPlace":[
               "<xsl:value-of separator='","' select='xtf-converted/xtf:meta/publicationPlace'></xsl:value-of>"
               ],
               "mediaurl":"<xsl:value-of select="xtf-converted/xtf:meta/mediaurl"/>",
               "dateCreated":"<xsl:value-of select="xtf-converted/xtf:meta/dateCreated"/>",
               "dateCreatedDisplay":"<xsl:value-of select="xtf-converted/xtf:meta/dateCreatedDisplay"/>",
               "dateIssued":"<xsl:value-of select="xtf-converted/xtf:meta/dateIssued"/>",
               "dateIssuedDisplay":"<xsl:value-of select="xtf-converted/xtf:meta/dateIssuedDisplay"/>",
               "languageCodes":[
               "<xsl:value-of separator='","' select='xtf-converted/xtf:meta/languageCode'></xsl:value-of>"
               ],
               "notes":[
               "<xsl:value-of separator='","' select='xtf-converted/xtf:meta/note'></xsl:value-of>"
               ],
               "ownership":[
               "<xsl:value-of separator='","' select='xtf-converted/xtf:meta/ownership'></xsl:value-of>"
               ],
               "physicalLocation":"<xsl:value-of select="xtf-converted/xtf:meta/physicalLocation"/>",
               "shelfLocator":"<xsl:value-of select="xtf-converted/xtf:meta/shelfLocator"/>",
               "displayImageRights":"<xsl:value-of select="xtf-converted/xtf:meta/displayImageRights"/>",
               "downloadImageRights":"<xsl:value-of select="xtf-converted/xtf:meta/downloadImageRights"/>",
               "type":"<xsl:value-of select="xtf-converted/xtf:meta/type"/>",
               "extent":"<xsl:value-of select="xtf-converted/xtf:meta/extent"/>",
               "collection":[
               "<xsl:value-of separator='","' select='xtf-converted/xtf:meta/collection'></xsl:value-of>"
               ],
               "numberOfPages":"<xsl:value-of select="xtf-converted/xtf:meta/numberOfPages"/>",
               "useTranscriptions":"<xsl:value-of select="xtf-converted/xtf:meta/transcriptions"/>",
               "pages":[<xsl:for-each select="xtf-converted/xtf:meta/pages/page">
                  {
                  "name":"<xsl:value-of select='./name'/>",
                  "physID":"<xsl:value-of select='./physID'/>",
                  "displayImageURL":"<xsl:value-of select='./displayImageURL'/>",
                  "downloadImageURL":"<xsl:value-of select='./downloadImageURL'/>",
                  "transcriptionNormalisedURL":"<xsl:value-of select='./transcriptionNormalisedURL'/>",
                  "transcriptionDiplomaticURL":"<xsl:value-of select='./transcriptionDiplomaticURL'/>"
                  }<xsl:if test="position() != last()">,</xsl:if>                  
               </xsl:for-each>],
               "logicalStructure":[<xsl:for-each select="xtf-converted/xtf:meta/logicalStructures/logicalStructure">
                  {
                  "title":"<xsl:value-of select='./title'/>",
                  "startPage":"<xsl:value-of select='./startPage'/>",
                  "startPageID":"<xsl:value-of select='./startPageID'/>",
                  "startPagePosition":"<xsl:value-of select='./startPagePosition'/>"
                  }<xsl:if test="position() != last()">,</xsl:if>
               </xsl:for-each>]
               }
   </xsl:template>

</xsl:stylesheet>