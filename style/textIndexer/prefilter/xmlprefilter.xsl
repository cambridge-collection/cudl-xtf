<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xtf="http://cdlib.org/xtf"
                xmlns:cudl="http://cudl.lib.cam.ac.uk/xtf/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:parse="http://cdlib.org/xtf/parse"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:x="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all">
    
    <!-- Import Common Templates and Functions                                  -->
    
   
    <xsl:import href="../common/preFilterCommon.xsl"/>
   
    <!-- Output parameters                                                      -->
    
   
    <xsl:output method="xml" 
                indent="yes" 
                encoding="UTF-8"/>

    <!-- import properties file - properties.xml -->
    <xsl:variable name="propertiesfile" select="document('properties.xml')"/>
    <!-- get the services url from properties file -->
    <xsl:variable name="services" >
        
        <xsl:value-of select="$propertiesfile/properties/services-url"/>
       
    </xsl:variable>

    <!-- Map from descriptive metadata ID to logical structure node -->
    <xsl:key
        name="structure-by-dmd"
        match="/root/logicalStructures|/root/logicalStructures//children"
        use="descriptiveMetadataID"/>

    <!-- Default: delete everything -->
    <xsl:template match="@*|node()"/>

    <!-- ====================================================================== -->
    <!-- Metadata Indexing                                                      -->
    <!-- ====================================================================== -->
   
    <xsl:template name="get-meta">
         
        <xsl:variable name="meta">
            
            <xsl:call-template name="make-dmd-parts"/>
            <xsl:call-template name="numberOfPages"/>
            <xsl:call-template name="get-embeddable"/>
            <xsl:call-template name="make-pages"/>
            
            <xsl:call-template name="make-logicalstructures"/>
            <xsl:call-template name="make-listitems"/>
            <xsl:call-template name="make-transcription-pages" /> 
            
        </xsl:variable>
      
           
        
        <xsl:call-template name="add-fields">
            <xsl:with-param name="display">
                <xsl:value-of select="'dynaxml'"/>
            </xsl:with-param>
            <xsl:with-param name="meta" select="$meta"/>
        </xsl:call-template>    
    </xsl:template>
    
    <!--top level template for descriptive metadata-->
    <xsl:template name="make-dmd-parts">
        <descriptiveMetadata>
            <xsl:apply-templates select="/root/*" />
        </descriptiveMetadata>
    </xsl:template>
  
    
     
    <!--fills in descriptive metadata for a structure within the item-->    
    <xsl:template match="descriptiveMetadata">
        <xsl:call-template name="make-dmd-part"/>
    </xsl:template>
    
    <xsl:template name="make-dmd-part">
        <part>
            <xsl:apply-templates select="ID"/>
            <xsl:apply-templates select="title"/>
            <xsl:apply-templates select="scribes"/>
            <xsl:apply-templates select="type"/>
            <xsl:apply-templates select="manuscript"/>
            <xsl:apply-templates select="recipients"/>
            <xsl:apply-templates select="uniformTitle"/>
            <xsl:apply-templates select="languageCodes"/>
            <xsl:apply-templates select="languageStrings"/>
            <xsl:apply-templates select="alternativeTitles"/>
            <xsl:apply-templates select="excerpts"/>
            <xsl:apply-templates select="abstract"/>
            
            <xsl:apply-templates select="physicalLocation"/>
            <xsl:apply-templates select="shelfLocator"/>
            <xsl:apply-templates select="reference"/>
            <xsl:apply-templates select="level"/>
            <xsl:apply-templates select="creators"/>
            <xsl:apply-templates select="authors"/>
            <xsl:apply-templates select="donors"/>
            <xsl:apply-templates select="associated"/>
            
            <xsl:apply-templates select="associatedCorps"/>
            <xsl:apply-templates select="places"/>
            <xsl:call-template   name="temporalCoverage"/>
            <xsl:call-template   name="itemReferences"/>
            <xsl:apply-templates select="destinations"/>
            <xsl:call-template   name="content"/>

            <xsl:apply-templates select="subjects"/>
            <!--creations/events-->
            <xsl:apply-templates select="creations"/>
            <xsl:apply-templates select="publications"/>
            <xsl:apply-templates select="acquisitions"/>
            <xsl:apply-templates select="extent"/>
            <xsl:apply-templates select="notes"/>
            <xsl:apply-templates select="layouts"/>
            <xsl:apply-templates select="decorations"/>
            <xsl:apply-templates select="additions"/>
            <xsl:apply-templates select="bindings"/>
            <xsl:apply-templates select="provenances"/>
            <xsl:apply-templates select="bibliographies"/>
            <xsl:apply-templates select="calendarnum"/>
            <xsl:apply-templates select="dataSources"/>
            <xsl:apply-templates select="material"/>
            <xsl:apply-templates select="thumbnailUrl"/>
            <xsl:apply-templates select="thumbnailOrientation"/>
            <xsl:apply-templates select="displayImageRights"/>
            <xsl:apply-templates select="downloadImageRights"/>
            <xsl:apply-templates select="imageReproPageURL"/>
            <xsl:apply-templates select="metadataRights"/>
            <xsl:apply-templates select="dataRevisions"/>
            <xsl:apply-templates select="fundings"/>
            <xsl:call-template name="get-collection-memberships"/>
        </part>
         
    </xsl:template>
  
    <!--   ids for structural item-->
    <xsl:template match="ID">
        <xsl:variable name="sectionId" >
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:variable>

        <xsl:attribute name="xtf:subDocument" select="$sectionId"/>

        <xsl:element name="ID">
            <xsl:value-of select="$sectionId"/>
        </xsl:element>

        <xsl:element name="fileID">
            <xsl:value-of select="$fileID"/>
        </xsl:element>

        <!-- Each metadata section has a structure node which contains details
             of the physical area of the item the metadata covers.  -->
        <xsl:variable name="structureNode"
                      select="key('structure-by-dmd', $sectionId)"/>

        <startPageLabel>
            <xsl:value-of select="$structureNode/startPageLabel"/>
        </startPageLabel>

        <startPage>
            <xsl:value-of select="$structureNode/startPagePosition"/>
        </startPage>
    </xsl:template>
        
       
    <!--   title-->
    <xsl:template match="title">
        <xsl:variable name="displayvalue" >
            <xsl:value-of select = "display"/>
        </xsl:variable>
        <xsl:variable name="displayformvalue" >
            <xsl:value-of select = "displayForm"/>
        </xsl:variable>
        
        <xsl:element name="title">
            <xsl:attribute name="display" select="$displayvalue"/>
            <xsl:attribute name="displayForm" select="$displayformvalue"/>
            <xsl:value-of select="$displayformvalue"/>
        </xsl:element>   
    </xsl:template>
    
    <!-- uniform title-->
    <xsl:template match="uniformTitle">
        <xsl:element name="uniformTitle">
            <xsl:attribute name="display" select="display"/>
            <xsl:attribute name="displayForm" select="displayForm"/>
        </xsl:element>
    </xsl:template>
    
    <!-- alternativeTitles -->
    <xsl:template match="alternativeTitles">
        <xsl:element name="alternativeTitles">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:element name="alternativeTitle">
                <xsl:attribute name="display">
                    <xsl:value-of select="value/display"/>
                </xsl:attribute>
                <xsl:attribute name="displayForm">
                    <xsl:value-of select="value/displayForm"/>
                </xsl:attribute>
                <xsl:value-of select="value/displayForm"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!-- scribes -->
    <xsl:template match="scribes">
        <xsl:element name="scribes">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:element name="name">
                <xsl:attribute name="display">
                    <xsl:value-of select="display"/>
                </xsl:attribute>
                <xsl:attribute name="displayForm">
                    <xsl:value-of select="value/displayForm"/>
                </xsl:attribute>
                <xsl:element name="fullForm">
                    <xsl:value-of select="value/fullForm"/>
                </xsl:element>
                <xsl:element name="shortForm">
                    <xsl:value-of select="value/shortForm"/>
                </xsl:element>
                <xsl:element name="type">
                    <xsl:value-of select="value/type"/>
                </xsl:element>
                <xsl:element name="role">
                    <xsl:value-of select="value/role"/>
                </xsl:element>
                <xsl:element name="authorityURI">
                    <xsl:value-of select="value/authorityURI"/>
                </xsl:element>
                <xsl:element name="authority">
                    <xsl:value-of select="value/authority"/>
                </xsl:element>
                <xsl:element name="valueURI">
                    <xsl:value-of select="value/valueURI"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>    
    <!-- type-->
    <xsl:template match="type">
        <xsl:element name="type">
            <xsl:value-of select="current()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- manuscript-->
    <xsl:template match="manuscript">
        <xsl:element name="manuscript">
            <xsl:value-of select="current()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- recipient -->
    <xsl:template match="recipients">
        <xsl:element name="recipients">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:element name="name">
                <xsl:attribute name="display">
                    <xsl:value-of select="value/display"/>
                </xsl:attribute>
                <xsl:attribute name="displayForm">
                    <xsl:value-of select="value/displayForm"/>
                </xsl:attribute>
                <xsl:element name="fullForm">
                    <xsl:value-of select="value/fullForm"/>
                </xsl:element>
                <xsl:element name="shortForm">
                    <xsl:value-of select="value/shortForm"/>
                </xsl:element>
                <xsl:element name="authority">
                    <xsl:value-of select="value/authority"/>
                </xsl:element>
                <xsl:element name="authorityURI">
                    <xsl:value-of select="value/authorityURI"/>
                </xsl:element>
                <xsl:element name="valueURI">
                    <xsl:value-of select="value/valueURI"/>
                </xsl:element>
                <xsl:element name="type">
                    <xsl:value-of select="value/type"/>
                </xsl:element>
                <xsl:element name="role">
                    <xsl:value-of select="value/role"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!-- language codes -->
    <xsl:template match="languageCodes">
        <xsl:element name="languageCodes">
            <xsl:element name="languageCode">
                <xsl:choose>
                    <xsl:when test="value/displayForm">
                        <xsl:value-of select="value/displayForm"/>
                    </xsl:when>
                    <xsl:when test="displayForm">
                        <xsl:value-of select="displayForm"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="current()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!-- language strings -->
    <xsl:template match="languageStrings">
        <xsl:element name="languageStrings">
            <xsl:element name="languageString">
                <xsl:choose>
                    <xsl:when test="value/displayForm">
                        <xsl:value-of select="value/displayForm"/>
                    </xsl:when>
                    <xsl:when test="displayForm">
                        <xsl:attribute name="display" select="display"/>
                        <xsl:attribute name="displayForm" select="displayForm"/>
                        <xsl:value-of select="displayForm"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="current()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!-- excerpts -->
    <xsl:template match="excerpts">
        <xsl:element name="excerpts">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:attribute name="displayForm">
                <xsl:value-of select="displayForm"/>
            </xsl:attribute>
            <xsl:value-of select="normalize-space(replace(displayForm, '&lt;[^&gt;]+&gt;', ''))"/>
        </xsl:element>
    </xsl:template>
    
    <!--    abstract-->
    <xsl:template match="abstract">
        
        <xsl:variable name="displayvalue" >
            <xsl:value-of select="display"/>
        </xsl:variable>
        <xsl:variable name="displayformvalue" >
            <xsl:value-of select="displayForm"/>
        </xsl:variable>
        <xsl:element name="abstract">
            <xsl:attribute name="display" select="$displayvalue"/>
            <xsl:attribute name="displayForm" select="$displayformvalue"/>
            <xsl:value-of select="normalize-space(replace($displayformvalue, '&lt;[^&gt;]+&gt;', ''))"/>
        </xsl:element>
           
    </xsl:template>
    
    
    
    <!--   physical locationshelf locator-->
    <xsl:template match="physicalLocation">
        
        <xsl:variable name="displayvalue" select="display"/>
        <xsl:variable name="displayformvalue" select="displayForm"/>
        <xsl:element name="physicalLocation">
            <xsl:attribute name="display" select="$displayvalue"/>
            <xsl:attribute name="displayForm" select="$displayformvalue"/>
            <xsl:value-of select="$displayformvalue"/>
        </xsl:element>
    </xsl:template>
    
    <!-- shelf locator-->
    <xsl:template match="shelfLocator">
        <xsl:variable name="displayvalue" select="display"/>
        <xsl:variable name="displayformvalue" select="displayForm"/>
        <xsl:element name="shelfLocator">
            <xsl:attribute name="display" select="$displayvalue"/>
            <xsl:attribute name="displayForm" select="$displayformvalue"/>
            <xsl:value-of select="$displayformvalue"/>
        </xsl:element>
    </xsl:template>   
    
    <!-- get reference-->
    <xsl:template match="reference">     
        <xsl:variable name="displayvalue" select="display"/>
        <xsl:variable name="displayformvalue" select="displayForm"/>
        <xsl:element name="reference">
            <xsl:attribute name="display" select="$displayvalue"/>
            <xsl:attribute name="displayForm" select="$displayformvalue"/>
            <xsl:value-of select="$displayformvalue"/>
        </xsl:element>
    </xsl:template>
    
    <!--    get level-->
    <xsl:template match="level">
        <xsl:variable name="displayvalue" select="display"/>
        <xsl:variable name="displayformvalue" select="displayForm"/>
        <xsl:element name="level">
            <xsl:attribute name="display" select="$displayvalue"/>
            <xsl:attribute name="displayForm" select="$displayformvalue"/>
            <xsl:value-of select="$displayformvalue"/>
        </xsl:element>
    </xsl:template>
    
    <!-- get creators -->
    <xsl:template match="creators">
        <xsl:variable name="displayvalue" select="display"/>
        <xsl:element name="creators">
            <xsl:attribute name="display" select="$displayvalue"/>
            
            <xsl:for-each select="value">
                <xsl:element name="name">
                    <xsl:attribute name="display">
                        <xsl:value-of select="display"/>
                    </xsl:attribute>
                    <xsl:attribute name="displayForm">
                        <xsl:value-of select="displayForm"/>
                    </xsl:attribute>
                
                    <xsl:if test="fullForm">
                        <xsl:element name="fullForm">
                            <xsl:value-of select="fullForm"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:element name="shortForm">
                        <xsl:value-of select="shortForm"/>
                    </xsl:element>
                    <xsl:if test="authority">
                        <xsl:element name="authority">
                            <xsl:value-of select="authority"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="valueURI">
                        <xsl:element name="valueURI">
                            <xsl:value-of select="valueURI"/>
                        </xsl:element>
                    </xsl:if>
                    
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>    
    
    <!--get authors-->
    <xsl:template match="authors">
        <xsl:element name="authors">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:for-each select="value">
                <xsl:element name="name">
                    <xsl:attribute name="display">
                        <xsl:value-of select="display"/>
                    </xsl:attribute>
                    <xsl:attribute name="displayForm">
                        <xsl:value-of select="displayForm"/>
                    </xsl:attribute>
                    <xsl:if test="fullForm">
                        <xsl:element name="fullForm">
                            <xsl:value-of select="fullForm"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="authority">
                        <xsl:element name="authority">
                            <xsl:value-of select="authority"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="authorityURI">
                        <xsl:element name="authorityURI">
                            <xsl:value-of select="authorityURI"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="valueURI">
                        <xsl:element name="valueURI">
                            <xsl:value-of select="valueURI"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="shortForm">
                        <xsl:element name="shortForm">
                            <xsl:value-of select="shortForm"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="type">
                        <xsl:element name="type">
                            <xsl:value-of select="type"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="role">
                        <xsl:element name="role">
                            <xsl:value-of select="role"/>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:for-each> 
        </xsl:element>
    </xsl:template>
    
    <!-- get material-->
    <xsl:template match="material">
        <xsl:variable name="displayvalue" select="display"/>
        <xsl:variable name="displayformvalue" select="displayForm"/>
        <xsl:element name="material">
            <xsl:attribute name="display" select="$displayvalue"/>
            <xsl:attribute name="displayForm" select="$displayformvalue"/>
            <xsl:value-of select="$displayformvalue"/>
        </xsl:element>
    </xsl:template>
    
    <!-- get donors-->
    <xsl:template match="donors">
        <xsl:element name="donors">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:element name="name">
                <xsl:attribute name="display">
                    <xsl:value-of select="value/display"/>
                </xsl:attribute>
                <xsl:attribute name="displayForm">
                    <xsl:value-of select="value/displayForm"/>
                </xsl:attribute>
                <xsl:element name="fullForm">
                    <xsl:value-of select="value/fullForm"/>
                </xsl:element>
                <xsl:element name="shortForm">
                    <xsl:value-of select="value/shortForm"/>
                </xsl:element>
                <xsl:element name="type">
                    <xsl:value-of select="value/type"/>
                </xsl:element>
                <xsl:element name="role">
                    <xsl:value-of select="value/role"/>
                </xsl:element>
            </xsl:element>
            
        </xsl:element>
    </xsl:template>
    
    <!-- get associated -->
    <xsl:template match="associated">
        <xsl:variable name="displayvalue" select="display"/>
       
        <xsl:element name="associated">
            <xsl:attribute name="display" select="$displayvalue"/>
            <xsl:for-each select="value">
                <!-- value transformed to name element -->
                <xsl:element name="name">
                    <xsl:attribute name="display" >
                        <xsl:value-of select="display"/>
                    </xsl:attribute>
                    
                    <xsl:attribute name="displayForm" >
                        <xsl:value-of select="displayForm"/>
                    </xsl:attribute>
                    
                    <!--full form -->
                    <xsl:if test="fullForm">
                        <xsl:element name="fullForm">
                            <xsl:value-of select="fullForm"/>
                        </xsl:element>
                    </xsl:if>
                    
                    <!--short form -->
                    <xsl:if test="shortForm">
                        <xsl:element name="shortForm">
                            <xsl:value-of select="shortForm"/>
                        </xsl:element>
                    </xsl:if>
                    <!--authority -->
                    <xsl:if test="authority">
                        <xsl:element name="authority">
                            <xsl:value-of select="authority"/>
                        </xsl:element>
                    </xsl:if>
                    <!--authorityURI -->
                    <xsl:if test="authorityURI">
                        <xsl:element name="authorityURI">
                            <xsl:value-of select="authorityURI"/>
                        </xsl:element>
                    </xsl:if>
                    <!--value uri -->
                    <xsl:if test="valueURI">
                        <xsl:element name="valueURI">
                            <xsl:value-of select="valueURI"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="type">
                        <xsl:element name="type">
                            <xsl:value-of select="type"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="role">
                        <xsl:element name="role">
                            <xsl:value-of select="role"/>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
              
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <!-- get  associatedCorps -->
    <xsl:template match="associatedCorps">
        <xsl:variable name="displayvalue" select="display"/>
        <xsl:element name="associatedCorps">
            <xsl:attribute name="display" select="$displayvalue"/>
            <xsl:for-each select="value">
                <xsl:element name="name">
                    <xsl:attribute name="display" select="display"/>
                    <xsl:attribute name="displayForm" select="displayForm"/>
                    <xsl:element name="fullForm">
                        <xsl:value-of select="fullForm"/>
                    </xsl:element>
                    <xsl:if test="authority">
                        <xsl:element name="authority">
                            <xsl:value-of select="authority"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="valueURI">
                        <xsl:element name="valueURI">
                            <xsl:value-of select="valueURI"/>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <!-- get places -->
    <xsl:template match="places">
        <xsl:element name="places">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:for-each select="value">
                <xsl:element name="place">
                    <xsl:attribute name="display">
                        <xsl:value-of select="display"/>
                    </xsl:attribute>
                    <xsl:attribute name="displayForm">
                        <xsl:value-of select="displayForm"/>
                    </xsl:attribute>
                    <xsl:if test="fullForm">
                        <xsl:element name="fullForm">
                            <xsl:value-of select="fullForm"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="shortForm">
                        <xsl:element name="shortForm">
                            <xsl:value-of select="shortForm"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="authority">
                        <xsl:element name="authority">
                            <xsl:value-of select="authority"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="authorityURI">
                        <xsl:element name="authorityURI">
                            <xsl:value-of select="authorityURI"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="valueURI">
                        <xsl:element name="valueURI">
                            <xsl:value-of select="valueURI"/>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <!-- temporal Coverage -->
    <xsl:template name="temporalCoverage">
        <xsl:if test="temporalCoverage">
            <xsl:element name="temporalCoverage">
                <xsl:for-each select="temporalCoverage">
                    <xsl:element name="period">
                        <xsl:element name="dateStart">
                            <xsl:value-of select="dateStart"/>
                        </xsl:element>
                        <xsl:element name="dateEnd">
                            <xsl:value-of select="dateEnd"/>
                        </xsl:element>
                        <xsl:element name="dateDisplay">
                            <xsl:attribute name="display" select="dateDisplay/display"/>
                            <xsl:attribute name="displayForm" select="dateDisplay/displayForm"/>
                            <xsl:value-of select="dateDisplay/displayForm"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <!-- item  References -->
    <xsl:template name="itemReferences">
        <xsl:if test="itemReferences">
            <xsl:element name="itemReferences">
                <xsl:for-each select="itemReferences">
                    <xsl:element name="item">
                        <xsl:element name="ID">
                            <xsl:value-of select="ID"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <!--destinations-->
    <xsl:template match="destinations">
        <xsl:element name="destinations">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:for-each select="value">
                <xsl:element name="place">
                    <xsl:attribute name="display">
                        <xsl:value-of select="display"/>
                    </xsl:attribute>
                    <xsl:attribute name="displayForm">
                        <xsl:value-of select="displayForm"/>
                    </xsl:attribute>
                    <xsl:if test="fullForm">
                        <xsl:element name="fullForm">
                            <xsl:value-of select="fullForm"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="authority">
                        <xsl:element name="authority">
                            <xsl:value-of select="authority"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="valueURI">
                        <xsl:element name="valueURI">
                            <xsl:value-of select="valueURI"/>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <!--  get subjects -->
    <xsl:template match="subjects">
        <xsl:variable name="displayvalue" select="display"/>
        <xsl:element name="subjects">
            <xsl:attribute name="display" select="$displayvalue"/>
            <xsl:for-each select="value">                  
                <!-- get the child nodes of subjects-->
                <xsl:element name="subject">
                    <xsl:attribute name="display" >
                        <xsl:value-of select="display"/>
                    </xsl:attribute>
                    <xsl:attribute name="displayForm" >
                        <xsl:value-of select="displayForm"/>
                    </xsl:attribute>
                    <xsl:element name="fullForm">
                        <xsl:value-of select="fullForm"/>
                    </xsl:element>
                    <xsl:if test="shortForm">
                        <xsl:element name="shortForm">
                            <xsl:value-of select="shortForm"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="components">
                        <xsl:element name="components">
                            <xsl:element name="component">
                                <xsl:element name="type">
                                    <xsl:value-of select="components/type"/>
                                </xsl:element>
                                <xsl:element name="fullForm">
                                    <xsl:value-of select="components/fullForm"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="authority">
                        <xsl:element name="authority">
                            <xsl:value-of select="authority"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="authorityURI">
                        <xsl:element name="authorityURI">
                            <xsl:value-of select="authorityURI"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="valueURI">
                        <xsl:element name="valueURI">
                            <xsl:value-of select="valueURI"/>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:for-each> 
        </xsl:element>
    </xsl:template>
    
    <!-- get creations/events -->
    <xsl:template match="creations">
        <xsl:variable name="displayvalue" select="display"/>
        <xsl:element name="creations">
            <xsl:attribute name="display" select="$displayvalue"/>
            <xsl:for-each select="value">
                <xsl:element name="event">
                    <xsl:attribute name="display" select="$displayvalue"/>
                    <xsl:element name="type">
                        <xsl:text>creation</xsl:text>
                    </xsl:element>
                    <xsl:element name="dateStart">
                        <!--                    <xsl:message>-->
                        <xsl:value-of select="dateStart"/>
                        <!--                    </xsl:message>-->
                    </xsl:element>
                    <xsl:element name="dateEnd">
                        <xsl:value-of select="dateEnd"/>
                    </xsl:element>
                    <xsl:element name="dateDisplay">
                        <xsl:variable name="displayvalue" select="dateDisplay/display"/>
                        <xsl:variable name="displayformvalue" select="dateDisplay/displayForm"/>
                        <xsl:attribute name="display" select="$displayvalue"/>
                        <xsl:attribute name="displayForm" select="$displayformvalue"/>
                        <xsl:value-of select="$displayformvalue"/>
                    </xsl:element>
                    <xsl:if test="places">
                        <xsl:element name="places">
                            <xsl:variable name="displayvalue" select="places/display"/>
                        
                            <xsl:attribute name="display" select="$displayvalue"/>
                            <xsl:element name="place">
                                <xsl:variable name="displayvalue" select="places/value/display"/>
                                <xsl:variable name="displayformvalue" select="places/value/displayForm"/>
                                <xsl:attribute name="display" select="$displayvalue"/>
                                <xsl:attribute name="displayForm" select="$displayformvalue"/>
                                <xsl:element name="fullForm">
                                    <xsl:value-of select="places/value/fullForm"/>
                                </xsl:element>
                                <xsl:if test="places/value/shortForm">
                                    <xsl:element name="shortForm">
                                        <xsl:value-of select="places/value/shortForm"/>
                                    </xsl:element>
                                </xsl:if>
                                <xsl:element name="authority">
                                    <xsl:value-of select="places/value/authority"/>
                                </xsl:element>
                                <xsl:if test="places/value/authorityURI">
                                    <xsl:element name="authorityURI">
                                        <xsl:value-of select="places/value/authorityURI"/>
                                    </xsl:element>
                                </xsl:if>
                                <xsl:element name="valueURI">
                                    <xsl:value-of select="places/value/valueURI"/>
                                </xsl:element>
                            
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <!-- get publications -->
    <xsl:template match="publications">
        <xsl:element name="publications">
            <xsl:attribute name="display" select="display"/>
            <xsl:element name="event">
                <xsl:element name="type">
                    <xsl:value-of select="value/type"/>
                </xsl:element>
                <xsl:element name="places">
                    <xsl:attribute name="display" select="value/places/display"/>
                    <xsl:for-each select="value/places/value">
                        <xsl:element name="place">
                            <xsl:attribute name="display" select="display"/>
                            <xsl:attribute name="displayForm" select="displayForm"/>
                            <xsl:if test="fullForm">
                                <xsl:element name="fullForm">
                                    <xsl:value-of select="fullForm"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:if test="authority">
                                <xsl:element name="authority">
                                    <xsl:value-of select="authority"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:if test="authorityURI">
                                <xsl:element name="authorityURI">
                                    <xsl:value-of select="authorityURI"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:if test="valueURI">
                                <xsl:element name="valueURI">
                                    <xsl:value-of select="valueURI"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:if test="shortForm">
                                <xsl:element name="shortForm">
                                    <xsl:value-of select="shortForm"/>
                                </xsl:element>
                            </xsl:if>
                        </xsl:element>
                    </xsl:for-each>
                    
                </xsl:element>
                <xsl:element name="dateStart">
                    <xsl:value-of select="value/dateStart"/>
                </xsl:element>
                
                <xsl:element name="dateEnd">
                    <xsl:value-of select="value/dateEnd"/>
                </xsl:element>
                
                <xsl:element name="dateDisplay">
                    <xsl:attribute name="display" select="value/dateDisplay/display"/>
                    <xsl:attribute name="displayForm" select="value/dateDisplay/displayForm"/>
                    <xsl:value-of select="value/dateDisplay/displayForm"/>
                </xsl:element>
                
                <xsl:element name="publishers">
                    <xsl:attribute name="display" select="value/publishers/display"/>
                    <xsl:element name="publisher">
                        <xsl:attribute name="display" select="value/publishers/value/display"/>
                        <xsl:attribute name="displayForm" select="value/publishers/value/displayForm"/>
                        <xsl:value-of select="value/publishers/value/displayForm"/>
                    </xsl:element>    
                </xsl:element>    
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!-- get acquisitions -->
    
    <xsl:template match="acquisitions">
        <xsl:element name="acquisitions">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:element name="event">
                <xsl:element name="type">
                    <xsl:value-of select="value/type"/>
                </xsl:element>
                <xsl:element name="dateStart">
                    <xsl:value-of select="value/dateStart"/>
                </xsl:element>
                <xsl:element name="dateEnd">
                    <xsl:value-of select="value/dateEnd"/>
                </xsl:element>
                <xsl:element name="dateDisplay">
                    <xsl:attribute name="display">
                        <xsl:value-of select="value/dateDisplay/display"/>
                    </xsl:attribute>
                    <xsl:attribute name="displayForm">
                        <xsl:value-of select="value/dateDisplay/displayForm"/>
                    </xsl:attribute>
                    <xsl:value-of select="value/dateDisplay/displayForm"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!--    get extent-->
    <xsl:template match="extent">
        <xsl:variable name="displayvalue" select="display"/>
        <xsl:variable name="displayformvalue" select="displayForm"/>
        <xsl:element name="extent">
            <xsl:attribute name="display" select="$displayvalue"/>
            <xsl:attribute name="displayForm" select="$displayformvalue"/>
            <xsl:value-of select="$displayformvalue"/>
        </xsl:element>
    </xsl:template>
    
    <!-- get notes -->
    <xsl:template match="notes">
        <xsl:element name="notes">
            <xsl:attribute name="display" select="display"/>
            <xsl:element name="note">
                <xsl:attribute name="display" select="value/display"/>
                <xsl:attribute name="displayForm" select="value/displayForm"/>
                <xsl:value-of select="value/displayForm"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!-- get layout-->
    <xsl:template match="layouts">
        <xsl:element name="layouts">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:element name="layout">
                <xsl:attribute name="display">
                    <xsl:value-of select="value/display"/>
                </xsl:attribute>
                <xsl:attribute name="displayForm">
                    <xsl:value-of select="value/displayForm"/>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(replace(value/displayForm, '&lt;[^&gt;]+&gt;', ''))"/>   
            </xsl:element> 
            
        </xsl:element>
    </xsl:template>
    
    <!-- get decorations-->
    <xsl:template match="decorations">
        <xsl:element name="decorations">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:element name="decoration">
                <xsl:attribute name="display">
                    <xsl:value-of select="value/display"/>
                </xsl:attribute>
                <xsl:attribute name="displayForm">
                    <xsl:value-of select="value/displayForm"/>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(replace(value/displayForm, '&lt;[^&gt;]+&gt;', ''))"/>   
            </xsl:element> 
            
        </xsl:element>
    </xsl:template>
    
    <!-- get additions-->
    <xsl:template match="additions">
        <xsl:element name="additions">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:element name="addition">
                <xsl:attribute name="display">
                    <xsl:value-of select="value/display"/>
                </xsl:attribute>
                <xsl:attribute name="displayForm">
                    <xsl:value-of select="value/displayForm"/>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(replace(value/displayForm, '&lt;[^&gt;]+&gt;', ''))"/>   
            </xsl:element> 
            
        </xsl:element>
    </xsl:template>
    
    <!-- get bindings-->
    <xsl:template match="bindings">
        <xsl:element name="bindings">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:element name="binding">
                <xsl:attribute name="display">
                    <xsl:value-of select="value/display"/>
                </xsl:attribute>
                <xsl:attribute name="displayForm">
                    <xsl:value-of select="value/displayForm"/>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(replace(value/displayForm, '&lt;[^&gt;]+&gt;', ''))"/>   
            </xsl:element> 
            
        </xsl:element>
    </xsl:template>
    
    <!-- get provenances-->
    <xsl:template match="provenances">
        <xsl:element name="provenances">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:element name="provenance">
                <xsl:attribute name="display">
                    <xsl:value-of select="value/display"/>
                </xsl:attribute>
                <xsl:variable name="displayForm">
                    <xsl:value-of select="value/displayForm"/>
                </xsl:variable>
                <xsl:attribute name="displayForm">
                    <xsl:value-of select="$displayForm"/>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(replace($displayForm, '&lt;[^&gt;]+&gt;', ''))"/>   
            </xsl:element> 
            
        </xsl:element>
    </xsl:template>
    
    <!-- bibliographies -->
    <xsl:template match="bibliographies">
        <xsl:element name="bibliographies">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:element name="bibliography">
                <xsl:attribute name="display">
                    <xsl:value-of select="value/display"/>
                </xsl:attribute>
                <xsl:attribute name="displayForm">
                    <xsl:value-of select="value/displayForm"/>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(replace(value/displayForm, '&lt;[^&gt;]+&gt;', ''))"/>   
            </xsl:element> 
            
        </xsl:element>
    </xsl:template>
    
    <!-- get calendarnum -->
    <xsl:template match="calendarnum">
        <xsl:element name="calendarnum">
            <xsl:attribute name="display" select="display"/>
            <xsl:attribute name="displayForm" select="displayForm"/>
            <xsl:value-of select="displayForm"/>
        </xsl:element>
    </xsl:template>
    
    <!-- get dataSources-->
    <xsl:template match="dataSources">
        <xsl:element name="dataSources">
            <xsl:attribute name="display">
                <xsl:value-of select="display"/>
            </xsl:attribute>
            <xsl:element name="dataSource">
                <xsl:attribute name="display">
                    <xsl:value-of select="value/display"/>
                </xsl:attribute>
                <xsl:attribute name="displayForm">
                    <xsl:value-of select="value/displayForm"/>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(replace(value/displayForm, '&lt;[^&gt;]+&gt;', ''))"/>   
            </xsl:element> 
            
        </xsl:element>
    </xsl:template>
    
    <!--   get thumbnail-->
    <xsl:template match="thumbnailUrl">
        <xsl:element name="thumbnailUrl">
            <xsl:value-of select="current()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- get thumbnailOrientation-->
    <xsl:template match="thumbnailOrientation">
        <xsl:element name="thumbnailOrientation">
            <xsl:value-of select="current()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- get image rights-->
    <xsl:template match="displayImageRights">
        <xsl:element name="displayImageRights">
            <xsl:value-of select="current()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- get download image rights-->
    <xsl:template match="downloadImageRights">
        <xsl:element name="downloadImageRights">
            <xsl:value-of select="current()"/>
        </xsl:element>
    </xsl:template> 
    
    <!-- get imageReproPageURL-->
    <xsl:template match="imageReproPageURL">
        <xsl:element name="imageReproPageURL">
            <xsl:value-of select="current()"/>
        </xsl:element>
    </xsl:template> 
    
    <!-- get metadataRights-->
    <xsl:template match="metadataRights">
        <xsl:element name="metadataRights">
            <xsl:value-of select="current()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- data revisions -->
    <xsl:template match="dataRevisions">
        <xsl:variable name="displayvalue" select="display"/>
        <xsl:variable name="displayformvalue" select="displayForm"/>
        <xsl:element name="dataRevisions">
            <xsl:attribute name="display">
                <xsl:value-of select="$displayvalue"/>
            </xsl:attribute>
            <xsl:attribute name="displayForm">
                <xsl:value-of select="$displayformvalue"/>
            </xsl:attribute>
            <xsl:value-of select="normalize-space(replace($displayformvalue, '&lt;[^&gt;]+&gt;', ''))"/>
        </xsl:element>
    </xsl:template>
    
     
    
    <!-- fundings -->
    <xsl:template match="fundings">
        <xsl:variable name="displayvalue" select="display"/>
        <xsl:element name="fundings">
            <xsl:attribute name="display">
                <xsl:value-of select="$displayvalue"/>
            </xsl:attribute>
            <xsl:element name="funding">
                <xsl:attribute name="display">
                    <xsl:value-of select="value/display"/>
                </xsl:attribute>
                <xsl:attribute name="displayForm">
                    <xsl:value-of select="value/displayForm"/>
                </xsl:attribute>
                <xsl:value-of select="value/displayForm"/>
            </xsl:element>
            
        </xsl:element> 
    </xsl:template>

    <!-- get-numberOfPages-->
    <xsl:template name="numberOfPages">
        <xsl:element name="numberOfPages">
            <xsl:value-of select="/root/numberOfPages"/>
        </xsl:element>
    </xsl:template>
    
    <!--get embeddable -->
    <xsl:template name="get-embeddable">
        <xsl:element name="embeddable">
            <xsl:value-of select="/root/embeddable"/>
        </xsl:element>
    </xsl:template>
    
    <!-- get the pages-->
    <xsl:template name="make-pages">
        <xsl:element name="pages">
            <xsl:for-each select="/root/pages">
                <xsl:element name="page">
                    <xsl:element name="label">
                        <xsl:value-of select="label"/>
                    </xsl:element>
                    <xsl:element name="physID">
                        <xsl:value-of select="physID"/>
                    </xsl:element>
                    <xsl:element name="sequence">
                        <xsl:value-of select="sequence"/>
                    </xsl:element>
                    <xsl:if test="displayImageURL">
                        <xsl:element name="displayImageURL">
                            <xsl:value-of select="displayImageURL"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="downloadImageURL">
                        <xsl:element name="downloadImageURL">
                            <xsl:value-of select="downloadImageURL"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="thumbnailImageURL">
                        <xsl:element name="thumbnailImageURL">
                            <xsl:value-of select="thumbnailImageURL"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="thumbnailImageOrientation">
                        <xsl:element name="thumbnailImageOrientation">
                            <xsl:value-of select="thumbnailImageOrientation"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="transcriptionDiplomaticURL">
                        <xsl:element name="transcriptionDiplomaticURL">
                            <!-- transcription content present so set up page extract URI  -->
                            <xsl:value-of select="transcriptionDiplomaticURL"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="transcriptionNormalisedURL">
                        <xsl:element name="transcriptionNormalisedURL">
                            <xsl:value-of select="transcriptionNormalisedURL"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="pageType">
                        <xsl:element name="pageType">
                            <xsl:value-of select="pageType"/>
                        </xsl:element>
                    </xsl:if>
                   
                    <xsl:if test="/root/pages[text()[normalize-space(.)]!='']">
                        <xsl:element name="content">
                            <xsl:for-each select="text()">
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>

    </xsl:template>
    
    <!-- content -->
    <xsl:template name="content">
        <xsl:for-each select="/root/pages">
            <xsl:if test="/root/pages[text()[normalize-space(.)]!='']">
                <xsl:element name="content">
                    <xsl:for-each select="text()">
                                                 
                        <xsl:value-of select="normalize-space(replace(., '&lt;[^&gt;]+&gt;', ''))"/>
                                             
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>    
    
    <!-- get the logicalStructures-->
    <xsl:template name="make-logicalstructures">
        <xsl:element name="logicalStructures">
            <xsl:for-each select="/root/logicalStructures">
                <xsl:element name="logicalStructure">
                    <xsl:element name="descriptiveMetadataID">
                        <xsl:value-of select="descriptiveMetadataID"/> 
                    </xsl:element>
                    <xsl:element name="label">
                        <xsl:value-of select="label"/> 
                    </xsl:element>
                    <xsl:element name="startPageLabel">
                        <xsl:value-of select="startPageLabel"/> 
                    </xsl:element> 
                    <xsl:element name="startPagePosition">
                        <xsl:value-of select="startPagePosition"/> 
                    </xsl:element>  
                    <xsl:element name="startPageID">
                        <xsl:value-of select="startPageID"/> 
                    </xsl:element>   
                    <xsl:element name="endPageLabel">
                        <xsl:value-of select="endPageLabel"/> 
                    </xsl:element>     
                    <xsl:element name="endPagePosition">
                        <xsl:value-of select="endPagePosition"/> 
                    </xsl:element>     
                    <xsl:if test="endPageID">
                        <xsl:element name="endPageID">
                            <xsl:value-of select="endPageID"/> 
                        </xsl:element> 
                    </xsl:if>
                
                    <xsl:if test="children">
                        <xsl:element name="children">
                            <xsl:for-each select="children">
                                <xsl:element name="logicalStructure">
                                    <xsl:element name="descriptiveMetadataID">
                                        <xsl:value-of select="descriptiveMetadataID"/> 
                                    </xsl:element>
                                    <xsl:element name="label">
                                        <xsl:value-of select="label"/> 
                                    </xsl:element>
                                    <xsl:element name="startPageLabel">
                                        <xsl:value-of select="startPageLabel"/> 
                                    </xsl:element> 
                                    <xsl:element name="startPagePosition">
                                        <xsl:value-of select="startPagePosition"/> 
                                    </xsl:element>  
                                    <xsl:element name="startPageID">
                                        <xsl:value-of select="startPageID"/> 
                                    </xsl:element>   
                                    <xsl:element name="endPageLabel">
                                        <xsl:value-of select="endPageLabel"/> 
                                    </xsl:element>     
                                    <xsl:element name="endPagePosition">
                                        <xsl:value-of select="endPagePosition"/> 
                                    </xsl:element> 
                                    <xsl:if test="endPageID" >    
                                        <xsl:element name="endPageID">
                                            <xsl:value-of select="endPageID"/> 
                                        </xsl:element> 
                                    </xsl:if>
                                    <!-- test if furthur childern exists-->
                                    <xsl:if test="children">
                                        <xsl:element name="children">
                                            <xsl:for-each select="children">
                                                <xsl:element name="logicalStructure">
                                                    <xsl:element name="descriptiveMetadataID">
                                                        <xsl:value-of select="descriptiveMetadataID"/> 
                                                    </xsl:element>
                                                    <xsl:element name="label">
                                                        <xsl:value-of select="label"/> 
                                                    </xsl:element>
                                                    <xsl:element name="startPageLabel">
                                                        <xsl:value-of select="startPageLabel"/> 
                                                    </xsl:element> 
                                                    <xsl:element name="startPagePosition">
                                                        <xsl:value-of select="startPagePosition"/> 
                                                    </xsl:element>  
                                                    <xsl:element name="startPageID">
                                                        <xsl:value-of select="startPageID"/> 
                                                    </xsl:element>   
                                                    <xsl:element name="endPageLabel">
                                                        <xsl:value-of select="endPageLabel"/> 
                                                    </xsl:element>     
                                                    <xsl:element name="endPagePosition">
                                                        <xsl:value-of select="endPagePosition"/> 
                                                    </xsl:element> 
                                                    <xsl:if test="endPageID" >    
                                                        <xsl:element name="endPageID">
                                                            <xsl:value-of select="endPageID"/> 
                                                        </xsl:element> 
                                                    </xsl:if>
                                                </xsl:element>
                                            </xsl:for-each>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <!-- make-list items-->
    <xsl:template name="make-listitems">
        <xsl:element name="listItemPages">
            <xsl:for-each select="/root/listItemPages">
                
                <xsl:element name="listItemPage">
                    <xsl:attribute name="xtf:subDocument" select="concat('listItem-', position())"/>
                    <xsl:element name="fileID">
                        <xsl:value-of select="$fileID"/>
                    </xsl:element>
                    <xsl:element name="dmdID">
                        <xsl:attribute name="xtf:noindex">true</xsl:attribute>
                        <xsl:value-of select="dmdID"/>
                    </xsl:element>
                    <xsl:element name="startPageLabel">
                        <xsl:value-of select="startPageLabel"/>
                    </xsl:element>
                    <xsl:element name="startPage">
                        <xsl:value-of select="startPage"/>
                    </xsl:element>
                    <xsl:element name="title">
                        <xsl:value-of select="title"/>
                    </xsl:element>
                    <xsl:element name="listItemText">
                        <xsl:value-of select="listItemText"/>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <!-- make-transcription-->
    <xsl:template name="make-transcription-pages"> 
        <xsl:if test="/root/useTranscriptions">
            <xsl:element name="useTranscriptions">
                <xsl:value-of select="/root/useTranscriptions"/>
            </xsl:element>
        </xsl:if>
        <xsl:if test="/root/useDiplomaticTranscriptions">
            
            <xsl:element name="useDiplomaticTranscriptions">
                <xsl:value-of select="/root/useDiplomaticTranscriptions"/>
            </xsl:element>
        </xsl:if>
        <xsl:if test="/root/useNormalisedTranscriptions">
            <xsl:element name="useNormalisedTranscriptions">
                <xsl:value-of select="/root/useNormalisedTranscriptions"/>
            </xsl:element>
        </xsl:if>
        <xsl:choose>
            <!-- for dcp files  -->
            <xsl:when test="/root/allTranscriptionDiplomaticURL">
                <xsl:element name="allTranscriptionDiplomaticURL">
                    <xsl:value-of select="/root/allTranscriptionDiplomaticURL"/>
                </xsl:element>
                <xsl:variable name="allTranscriptionDiplomaticURL">
                    <xsl:value-of select="/root/allTranscriptionDiplomaticURL"/>
                </xsl:variable>
                <xsl:element name="transcriptionPage">
                    <xsl:attribute name="xtf:subDocument">letter</xsl:attribute>
                    <xsl:element name="fileID">
                        <xsl:value-of select="$fileID"/>
                    </xsl:element>
                    <xsl:element name="dmdID">
                        <xsl:value-of select="/root/logicalStructures/descriptiveMetadataID"/>
                    </xsl:element>
                    <xsl:element name="startPageLabel">
                        <xsl:value-of select="/root/pages[1]/label"/>
                    </xsl:element>
                    <xsl:element name="startPage">
                        <xsl:value-of select="/root/pages[1]/sequence"/>
                    </xsl:element>
                    <xsl:element name="title">
                        <xsl:value-of select="'Letter'"/>
                    </xsl:element>
                    <xsl:element name="transcriptionText">
                        <xsl:variable name="url" >
                            <xsl:value-of select = "$allTranscriptionDiplomaticURL"/>
                        </xsl:variable>
                        <xsl:if test="$url!=''">
                            <xsl:variable name="transcriptionText">
                                <xsl:variable name="concaturl" >
                                    <xsl:value-of select="concat($services,$url)"/>
                                </xsl:variable>
                                <xsl:variable name="transcriptionAllText" select="document($concaturl)"/>
                                
                                <xsl:value-of select="$transcriptionAllText"/>
                                
                                <xsl:value-of select="normalize-space(replace($transcriptionAllText//*:body, '&lt;[^&gt;]+&gt;', ''))" />
                            </xsl:variable>
                            <xsl:value-of select="normalize-space(translate($transcriptionText, '&#xa0;', ' '))" />
                        </xsl:if>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                
           

                <xsl:element name="transcriptionPages">
                    <xsl:variable name="allTranscriptionDiplomaticURL">
                        <xsl:value-of select="/root/allTranscriptionDiplomaticURL"/>
                    </xsl:variable>
                    <xsl:for-each select="/root/pages">
                        <xsl:element name="transcriptionPage">
                            <xsl:variable name="startPageLabel">
                                <xsl:value-of select="label"/>
                            </xsl:variable>
                    
                            <xsl:attribute name="xtf:subDocument" >
                                <xsl:value-of select="concat('sub-', normalize-space(label))"/>
                            </xsl:attribute>
                            <xsl:element name="fileID">
                                <xsl:value-of select="$fileID"/>
                            </xsl:element>
                            <xsl:element name="dmdID">
                                <xsl:value-of select="/root/logicalStructures/descriptiveMetadataID"/>
                            </xsl:element>
                            <xsl:element name="startPageLabel">
                        
                                <xsl:value-of select="$startPageLabel"/>
                            </xsl:element>
                            <xsl:element name="startPage">
                                <xsl:value-of select="sequence"/>
                            </xsl:element>
                            <xsl:element name="title">
                                <xsl:value-of select="label"/>
                            </xsl:element>
                            <xsl:element name="sort-title">
                                <xsl:value-of select="label"/>
                            </xsl:element>
                   
                   
                            <xsl:element name="transcriptionText">
                                <xsl:choose>
                                    <xsl:when test="transcriptionNormalisedURL">
                               
                                        <xsl:variable name="url" >
                                            <xsl:value-of select = "transcriptionNormalisedURL"/>
                                        </xsl:variable>
                                        <xsl:if test="$url!=''">
                                            <xsl:variable name="transcriptionText">
                                                <xsl:variable name="concaturl" >
                                                    <xsl:value-of select="concat($services,$url)"/>
                                                </xsl:variable>
                                                <xsl:variable name="transcriptionAllText" select="document($concaturl)"/>
                                                <!--                                <xsl:copy-of select="$transcriptionAllText//*:body"/>-->
                                                <xsl:value-of select="normalize-space(replace($transcriptionAllText//*:body, '&lt;[^&gt;]+&gt;', ''))" />
                                            </xsl:variable>
                                            <xsl:value-of select="normalize-space(translate($transcriptionText, '&#xa0;', ' '))" />
                                        </xsl:if>
                       
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:if test="transcriptionDiplomaticURL">
                                            <xsl:variable name="url" >
                                                <xsl:value-of select = "transcriptionDiplomaticURL"/>
                                            </xsl:variable>
                                            <xsl:if test="$url!=''">
                                                <xsl:variable name="transcriptionText">
                                                    <xsl:variable name="concaturl" >
                                                        <xsl:value-of select="concat($services,$url)"/>
                                                    </xsl:variable>
                                                    <xsl:variable name="transcriptionAllText" select="document($concaturl)"/>
                                                    <!--                                <xsl:copy-of select="$transcriptionAllText//*:body"/>-->
                                                    <xsl:value-of select="normalize-space(replace($transcriptionAllText//*:body, '&lt;[^&gt;]+&gt;', ''))" />
                                                </xsl:variable>
                                                <xsl:value-of select="normalize-space(translate($transcriptionText, '&#xa0;', ' '))" />
                                            </xsl:if>
                                        </xsl:if>
                                
                               
                                    </xsl:otherwise>
                                </xsl:choose>
                        
                            </xsl:element>
                            <xsl:element name="translation">
                                <xsl:if test="translationURL">
                                    <xsl:variable name="url" >
                                        <xsl:value-of select = "translationURL"/>
                                    </xsl:variable>
                                    <xsl:if test="$url!=''">
                                        <xsl:variable name="translationText">
                                            <xsl:variable name="concaturl" >
                                                <xsl:value-of select="concat($services,$url)"/>
                                            </xsl:variable>
                                            <xsl:variable name="translationAllText" select="document($concaturl)"/>
                                            
                                            <xsl:value-of select="normalize-space(replace($translationAllText//*:body, '&lt;[^&gt;]+&gt;', ''))" />
                                        </xsl:variable>
                                        <xsl:value-of select="normalize-space(translate($translationText, '&#xa0;', ' '))" />
                                    </xsl:if>
                                </xsl:if>
                            </xsl:element>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--collection membership-->
    <xsl:template name="get-collection-memberships">
        <!-- Lookup collections of which this item is a member (from Postgres database) -->
      
        <xsl:element name="collections">
            <xsl:for-each select="cudl:get-memberships($fileID)">
                <xsl:element name="collection">
                    <xsl:value-of select="title"/>
                </xsl:element>
            </xsl:for-each>         
        </xsl:element>
      
    </xsl:template>
</xsl:stylesheet>
