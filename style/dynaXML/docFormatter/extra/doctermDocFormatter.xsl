<xsl:stylesheet version="2.0" 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xtf="http://cdlib.org/xtf"
   xmlns:session="java:org.cdlib.xtf.xslt.Session"
   xmlns:editURL="http://cdlib.org/xtf/editURL"
   xmlns:local="http://localhost/"
   xmlns:cudl="http://cudl.cam.ac.uk/xtf/"
   xmlns="http://www.w3.org/1999/xhtml"
   extension-element-prefixes="session"
   exclude-result-prefixes="#all">
   
   <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
   <!-- General dynaXML Stylesheet  for all document types                     -->
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
   
   <!--function for json escaping-->
   <xsl:function name="local:escape">
      <xsl:param name="text" />
      
      <!-- In JSON, need to escape quotation mark and backward slash -->
      <xsl:value-of select="replace(replace($text, '\\', '\\\\'), '&quot;', '\\&quot;')"/>
   </xsl:function>
   
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
   
   <xsl:variable name="indoc" select="/" />
   
   <!-- ====================================================================== -->
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
      
      <xsl:text>
         {</xsl:text>
      
      <!-- for each input element with match in table -->
      <xsl:for-each select="xtf-converted/xtf:meta/*[local-name()=$layout/cudl:element/@name]">
         <xsl:variable name="thisname" select="local-name()" />
         <xsl:variable name="seq" select="cudl:get-pos($layout, $thisname)"/>
         
         
         <!-- process current input element -->
         <xsl:apply-templates select="." mode="json">
            <xsl:with-param name="cudl-element" select="$layout/cudl:element[@name=$thisname]"/>
            <xsl:with-param name="seq" select="$seq"/>
            <xsl:with-param name="cudl-parent" select="$layout"/>
            
            
            
         </xsl:apply-templates>

         <xsl:if test="position() != last()">,</xsl:if>
      </xsl:for-each>
      
      <xsl:text>
         }</xsl:text>
   
   </xsl:template>
   
   <xsl:function name="cudl:get-pos">
      <xsl:param name="parent" />
      <xsl:param name="childname" />
      
      <xsl:for-each select="$parent/cudl:element">
         <xsl:if test="@name=$childname">
            <xsl:value-of select="sum((count(ancestor::cudl:element), count(preceding::cudl:element)))" />
         </xsl:if>
      </xsl:for-each>
      
   </xsl:function>
   
   <xsl:template match="*" mode="json">
      <xsl:param name="cudl-element" />
      <xsl:param name="seq" />
      <xsl:param name="cudl-parent" />
      
      
      <!-- if parent not array then need JSON-label; if parent is array then no need -->
      <xsl:if test="not($cudl-parent/@jsontype='array')">
         <xsl:text>
            "</xsl:text>
         <xsl:value-of select="local-name()" />
         <xsl:text>": </xsl:text>
      </xsl:if>
      
      <!-- process according to @jsontype to construct JSON-value -->
            
      <xsl:choose>
         <xsl:when test="$cudl-element/@jsontype='array'">
            
            <xsl:call-template name="make-json-array">
               <xsl:with-param name="cudl-element" select="$cudl-element"/>
               <xsl:with-param name="seq" select="$seq" />
            </xsl:call-template>
            
         </xsl:when>
         <xsl:when test="$cudl-element/@jsontype='object'">
            
            <xsl:call-template name="make-json-object">
               <xsl:with-param name="cudl-element" select="$cudl-element"/>
               <xsl:with-param name="seq" select="$seq" />
            </xsl:call-template>
            
         </xsl:when>
         <xsl:when test="$cudl-element/@jsontype='string'">
            
            <xsl:call-template name="make-json-string">
               <xsl:with-param name="cudl-element" select="$cudl-element"/>
               <xsl:with-param name="seq" select="$seq" />
            </xsl:call-template>
            
         </xsl:when>
         <xsl:when test="$cudl-element/@jsontype='number'">
            
            <xsl:call-template name="make-json-number">
               <xsl:with-param name="cudl-element" select="$cudl-element"/>
               <xsl:with-param name="seq" select="$seq" />
            </xsl:call-template>
            
         </xsl:when>
         <xsl:when test="$cudl-element/@jsontype='boolean'">
            
            <xsl:call-template name="make-json-boolean">
               <xsl:with-param name="cudl-element" select="$cudl-element"/>
               <xsl:with-param name="seq" select="$seq" />
            </xsl:call-template>
            
         </xsl:when>
      </xsl:choose>

   </xsl:template>
   
   <xsl:template name="make-json-array">
      <xsl:param name="cudl-element" />
      <xsl:param name="seq" />
            
      <xsl:choose>
         <xsl:when test="@display">
            <!-- blow up into object with display attributes -->
            <xsl:text>
               {</xsl:text>
            <xsl:text>
               "display": </xsl:text>
            <xsl:value-of select="@display" />
            <xsl:text>, </xsl:text>
            <xsl:if test="@displayForm">
               <xsl:text>
                  "displayForm": "</xsl:text>
               <xsl:value-of select="local:escape(@displayForm)" />
               <xsl:text>", </xsl:text>             
            </xsl:if>
            
            <xsl:text>
               "seq": </xsl:text>
            <xsl:value-of select="$seq" />
            <xsl:text>, </xsl:text>             
            
            <xsl:if test="normalize-space($cudl-element/@listDisplay)">
               <xsl:text>
                  "listDisplay": "</xsl:text>
               <xsl:value-of select="normalize-space($cudl-element/@listDisplay)" />
               <xsl:text>", </xsl:text>             
            </xsl:if>
            <xsl:if test="normalize-space($cudl-element/@linktype)">
               <xsl:text>
                  "linktype": "</xsl:text>
               <xsl:value-of select="normalize-space($cudl-element/@linktype)" />
               <xsl:text>", </xsl:text>             
            </xsl:if>
            <xsl:if test="normalize-space($cudl-element/@label)">
               <xsl:text>
                  "label": "</xsl:text>
               <xsl:value-of select="normalize-space($cudl-element/@label)" />
               <xsl:text>", </xsl:text>             
            </xsl:if>
            <!-- here comes the array -->
            <xsl:text>
               "value": [
            </xsl:text>

            <!-- for each child element with match in table -->
            <xsl:for-each select="*[local-name()=$cudl-element/cudl:element/@name]">
               <xsl:variable name="thisname" select="local-name()" />
               <xsl:variable name="seq" select="cudl:get-pos($cudl-element, $thisname)"/>
               
               <!-- Process child element -->
               <xsl:apply-templates select="." mode="json">
                  <xsl:with-param name="cudl-element" select="$cudl-element/cudl:element[@name=$thisname]"/>
                  <xsl:with-param name="seq" select="$seq" />
                  <xsl:with-param name="cudl-parent" select="$cudl-element"/>
               </xsl:apply-templates>
               
               <xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>
            <xsl:text>
               ]</xsl:text>
            <xsl:text>
               }</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <!-- just treat as array -->
            <xsl:text>
               [
            </xsl:text>

            <!-- for each child element with match in table -->
            <xsl:for-each select="*[local-name()=$cudl-element/cudl:element/@name]">
               <xsl:variable name="thisname" select="local-name()" />
               <xsl:variable name="seq" select="cudl:get-pos($cudl-element, $thisname)"/>

               <!-- Process child element -->
               <xsl:apply-templates select="." mode="json">
                  <xsl:with-param name="cudl-element" select="$cudl-element/cudl:element[@name=$thisname]"/>
                  <xsl:with-param name="seq" select="$seq" />
                  <xsl:with-param name="cudl-parent" select="$cudl-element"/>
               </xsl:apply-templates>

               <xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>
            <xsl:text>
               ]</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   
   </xsl:template>

   <xsl:template name="make-json-object">
      <xsl:param name="cudl-element" />
      <xsl:param name="seq" />
      
      <xsl:text>
         {</xsl:text>
      <xsl:choose>
         <xsl:when test="@display">
            <!-- blow up into object with display attributes -->
            <xsl:text>
               "display": </xsl:text>
            <xsl:value-of select="@display" />
            <xsl:text>, </xsl:text>
            <xsl:if test="@displayForm">
               <xsl:text>
                  "displayForm": "</xsl:text>
               <xsl:value-of select="local:escape(@displayForm)" />
               <xsl:text>", </xsl:text>             
            </xsl:if>
            <xsl:text>
               "seq": </xsl:text>
            <xsl:value-of select="$seq" />
            <xsl:text>, </xsl:text>             
            
            <xsl:if test="normalize-space($cudl-element/@linktype)">
               <xsl:text>
                  "linktype": "</xsl:text>
               <xsl:value-of select="normalize-space($cudl-element/@linktype)" />
               <xsl:text>", </xsl:text>             
            </xsl:if>
            <xsl:if test="normalize-space($cudl-element/@label)">
               <xsl:text>
                  "label": "</xsl:text>
               <xsl:value-of select="normalize-space($cudl-element/@label)" />
               <xsl:text>", </xsl:text>             
            </xsl:if>
         </xsl:when>
         <xsl:otherwise />  <!-- no need for anything -->         
      </xsl:choose>
      
      <!-- for each child element with match in table -->
      <xsl:for-each select="*[local-name()=$cudl-element/cudl:element/@name]">
         <xsl:variable name="thisname" select="local-name()" />
         <xsl:variable name="seq" select="cudl:get-pos($cudl-element, $thisname)"/>

         <!-- Process child element -->
         <xsl:apply-templates select="." mode="json">
            <xsl:with-param name="cudl-element" select="$cudl-element/cudl:element[@name=$thisname]"/>
            <xsl:with-param name="seq" select="$seq" />
            <xsl:with-param name="cudl-parent" select="$cudl-element"/>
         </xsl:apply-templates>

         <xsl:if test="position() != last()">,</xsl:if>
      </xsl:for-each>
      <xsl:text>
         }</xsl:text>     
   
   </xsl:template>
   
   <xsl:template name="make-json-string">
      <xsl:param name="cudl-element" />
      <xsl:param name="seq" />
      
      <xsl:choose>
         <xsl:when test="@display">
            <!-- blow up into object with display attributes -->
            <xsl:text>
               {</xsl:text>
            <xsl:text>
               "display": </xsl:text>
            <xsl:value-of select="@display" />
            <xsl:text>, </xsl:text>
            <xsl:if test="@displayForm">
               <xsl:text>
                  "displayForm": "</xsl:text>
               <xsl:value-of select="local:escape(@displayForm)" />
               <xsl:text>", </xsl:text>             
            </xsl:if>

            <xsl:if test="normalize-space($cudl-element/@linktype)">
               <xsl:text>
                  "linktype": "</xsl:text>
               <xsl:value-of select="normalize-space($cudl-element/@linktype)" />
               <xsl:text>", </xsl:text>             
            </xsl:if>
            <xsl:if test="normalize-space($cudl-element/@label)">
               <xsl:text>
                  "label": "</xsl:text>
               <xsl:value-of select="normalize-space($cudl-element/@label)" />
               <xsl:text>", </xsl:text>             
            </xsl:if>
            <xsl:text>
               "seq": </xsl:text>
            <xsl:value-of select="$seq" />
            <!-- <xsl:text>, </xsl:text> -->             
            <!--
            <xsl:text>"value": </xsl:text>
            <xsl:text>"</xsl:text>            
            <xsl:value-of select="local:escape(.)" />
            <xsl:text>"</xsl:text>
            -->
            <xsl:text>
               }</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <!-- it really is just a string -->
            <xsl:text>"</xsl:text>            
            <xsl:value-of select="local:escape(.)" />
            <xsl:text>"</xsl:text>          
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   <xsl:template name="make-json-number">
      <xsl:param name="cudl-element" />
      <xsl:param name="seq" />
      
      <!-- numbers are never displayed so really are just numbers -->
      <xsl:value-of select="." />
   
   </xsl:template>
   
   <xsl:template name="make-json-boolean">
      <xsl:param name="cudl-element" />
      <xsl:param name="seq" />
      
      <!-- booleans are never displayed so really are just booleans -->
      <xsl:value-of select="." />
   
   </xsl:template>

   <!-- 
      
      Variable $layout is the source of the "display attributes" for the JSON data (label, linktype, seq
      
      For each input element type to be included in the JSON output, the variable $layout provides:
      - the type of the output JSON structure
      - for display elements:
        - the display label to be applied (@label)
        - the linktype to be applied (@linktype) (currently only a single search type, but that will probably expand in the future)
        - the order in which the element is to be displayed, based on order within this table. 
          (This is a bit limiting in the sense that the ordering of "child" elements is subordinate to the ordering of "parent" elements, 
          but for now, it's probably adequate.)
        
        N.B. This variable does NOT control 
        - whether an individual element is displayed or not: that comes from the input data (@display) 
   
   -->
   
   <xsl:variable name="layout">
      
      <cudl:element name="document-terms" jsontype="object">
         <cudl:element name="docID" jsontype="string"/>
         <cudl:element name="total" jsontype="number"/>
         <cudl:element name="terms" jsontype="array">
            <cudl:element name="term" jsontype="object">
               <cudl:element name="name" jsontype="string"/>
               <cudl:element name="raw" jsontype="number"/>
               <cudl:element name="value" jsontype="number"/>
            </cudl:element>
         </cudl:element>
      </cudl:element>

   </xsl:variable>
  
</xsl:stylesheet>