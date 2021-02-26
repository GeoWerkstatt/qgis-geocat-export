<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:che="http://www.geocat.ch/2008/che"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:exslt="http://exslt.org/common"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="msxsl">

  <!-- ***************************************************************
  This xsl transforms a 'simpleGmd'-xml file into a valid
  ISO19139che-xml file.
  **************************************************************** -->

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <!-- ***************************************************************
  Root and first level elements
  The variable 'gmdType' contains either 'data' if the read xml file
  represents a georecord or 'service' it the xml represents a service
  (product).
  **************************************************************** -->

  <xsl:variable
          name="gmdType"
          select="simpleGmd/@gmdType"/>

  <xsl:template match="/">
    <che:CHE_MD_Metadata gco:isoType="gmd:MD_Metadata">
      <xsl:apply-templates select="simpleGmd"/>
    </che:CHE_MD_Metadata>
  </xsl:template>

  <xsl:template match="simpleGmd">
    <xsl:apply-templates select="fileIdentifier" mode="named-gmd-gcocharacterstring"/>
    <xsl:call-template name="language"/>
    <xsl:call-template name="characterSet"/>
    <xsl:call-template name="hierarchyLevel"/>
    <xsl:apply-templates select="contact"/>
    <xsl:apply-templates select="dateStamp"/>
    <xsl:apply-templates select="metadataStandardName" mode="named-gmd-gcocharacterstring"/>
    <xsl:apply-templates select="spatialRepresentationInfo"/>
    <xsl:apply-templates select="referenceSystemInfo"/>
    <xsl:apply-templates select="identificationInfo"/>
    <xsl:apply-templates select="distributionInfo"/>
    <xsl:apply-templates select="contentInfo"/>
    <xsl:apply-templates select="dataQualityInfo"/>
  </xsl:template>

  <xsl:template name="language">
    <gmd:language>
      <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/" codeListValue="ger" />
    </gmd:language>
  </xsl:template>

  <xsl:template name="characterSet">
    <gmd:characterSet>
      <gmd:MD_CharacterSetCode codeListValue="utf8" codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_CharacterSetCode" />
    </gmd:characterSet>
  </xsl:template>

  <xsl:template name="hierarchyLevel">
    <gmd:hierarchyLevel>
      <xsl:choose>
        <xsl:when test="$gmdType = 'data'">
          <gmd:MD_ScopeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_ScopeCode" codeListValue="dataset"/>
        </xsl:when>
        <xsl:when test="$gmdType = 'service'">
          <gmd:MD_ScopeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_ScopeCode" codeListValue="service"/>
        </xsl:when>
      </xsl:choose>
    </gmd:hierarchyLevel>
  </xsl:template>

  <xsl:template match="contact">
    <gmd:contact xlink:show="embed">
      <xsl:apply-templates select="responsibleParty"/>
    </gmd:contact>
  </xsl:template>

  <xsl:template match="dateStamp">
    <gmd:dateStamp>
      <xsl:apply-templates select="." mode="gcodate" />
    </gmd:dateStamp>
  </xsl:template>

  <xsl:template match="referenceSystemInfo">
    <gmd:referenceSystemInfo>
      <gmd:MD_ReferenceSystem>
        <gmd:referenceSystemIdentifier>
          <gmd:RS_Identifier>
            <gmd:code xsi:type="gmd:PT_FreeText_PropertyType">
              <xsl:apply-templates select="." mode="gcocharacterstring" />
            </gmd:code>
          </gmd:RS_Identifier>
        </gmd:referenceSystemIdentifier>
      </gmd:MD_ReferenceSystem>
    </gmd:referenceSystemInfo>
  </xsl:template>


<!-- ***************************************************************
Content Info element with its children.
**************************************************************** -->
  <xsl:template match="contentInfo">
    <gmd:contentInfo>
      <che:CHE_MD_FeatureCatalogueDescription gco:isoType="gmd:MD_FeatureCatalogueDescription">
        <gmd:includedWithDataset>
          <gco:Boolean>0</gco:Boolean>
        </gmd:includedWithDataset>
        <xsl:apply-templates select="featureCatalogueCitation"/>
        <xsl:apply-templates select="class"/>
        <che:modelType>
          <che:CHE_MD_modelTypeCode codeListValue="FeatureDescription" codeList=""/>
        </che:modelType>
      </che:CHE_MD_FeatureCatalogueDescription>
    </gmd:contentInfo>
  </xsl:template>


  <xsl:template match="class">
        <che:class>
          <che:CHE_MD_Class>
            <xsl:apply-templates select="name"/>
            <xsl:apply-templates select="description"/>
            <xsl:apply-templates select="attribute"/>
          </che:CHE_MD_Class>
        </che:class>
  </xsl:template>

  <xsl:template match="name">
        <che:name>
          <gco:CharacterString>
            <xsl:apply-templates select="." mode="dgcocharacterstring"/>
          </gco:CharacterString>
        </che:name>
  </xsl:template>

  <xsl:template match="description">
    <che:description>
      <gco:CharacterString>
        <xsl:apply-templates select="." mode="dgcocharacterstring"/>
      </gco:CharacterString>
    </che:description>
  </xsl:template>

  <xsl:template match="attribute">
    <che:attribute>
        <xsl:apply-templates select="name"/>
        <xsl:apply-templates select="description"/>
    </che:attribute>
  </xsl:template>

  <xsl:template match="featureCatalogueCitation">
    <gmd:featureCatalogueCitation>
      <gmd:CI_Citation>
        <gmd:title>
          <xsl:apply-templates select="title" mode="gcocharacterstring" />
        </gmd:title>
        <gmd:date>
          <gmd:CI_Date>
            <gmd:date>
              <gco:Date>
                <xsl:value-of select="date"/>
              </gco:Date>
            </gmd:date>
            <gmd:dateType>
              <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode"
                                   codeListValue="revision"/>
            </gmd:dateType>
          </gmd:CI_Date>
        </gmd:date>
      </gmd:CI_Citation>
    </gmd:featureCatalogueCitation>
  </xsl:template>
  <!-- ***************************************************************
  IdentificationInfo element with its children.
  **************************************************************** -->

  <xsl:template match="identificationInfo">
    <gmd:identificationInfo>
      <xsl:choose>
        <xsl:when test="$gmdType = 'data'">
          <che:CHE_MD_DataIdentification gco:isoType="gmd:MD_DataIdentification">
            <xsl:call-template name="generalIdentificationInfo"/>
            <xsl:apply-templates select="resourceConstraints"/>
            <xsl:apply-templates select="spatialRepresentationType"/>
            <xsl:apply-templates select="equivalentScale"/>
            <xsl:apply-templates select="distance"/>
            <gmd:language>
              <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/" codeListValue="ger"/>
            </gmd:language>
            <xsl:apply-templates select="topicCategories/topicCategory"/>
            <gmd:extent xlink:show="embed">
              <xsl:apply-templates select="extent"/>
            </gmd:extent>
          </che:CHE_MD_DataIdentification>
        </xsl:when>
        <xsl:when test="$gmdType = 'service'">
          <che:CHE_SV_ServiceIdentification gco:isoType="srv:SV_ServiceIdentification">
            <xsl:call-template name="generalIdentificationInfo"/>
            <xsl:apply-templates select="serviceType"/>
            <xsl:apply-templates select="restrictions"/>
            <xsl:apply-templates select="topicCategories/topicCategory"/>
            <srv:extent xlink:show="embed">
              <xsl:apply-templates select="extent"/>
            </srv:extent>
            <xsl:call-template name="couplingType"/>
            <!-- Element srv:containsOperations is required in target schema; also if no operations are contained -->
            <srv:containsOperations>
              <xsl:apply-templates select="containsOperations/operation"/>
            </srv:containsOperations>
          </che:CHE_SV_ServiceIdentification>
        </xsl:when>
      </xsl:choose>
    </gmd:identificationInfo>
  </xsl:template>

  <xsl:template name="generalIdentificationInfo">
    <gmd:citation>
      <gmd:CI_Citation>
        <xsl:apply-templates select="title" mode="named-gmd-ptfreetextpropertytype"/>
        <xsl:apply-templates select="alternateTitle" mode="named-gmd-ptfreetextpropertytype"/>
        <xsl:apply-templates select="creationDate"/>
        <xsl:apply-templates select="revisionDate"/>
        <xsl:apply-templates select="identifier"/>
        <xsl:apply-templates select="otherCitationDetails"/>
      </gmd:CI_Citation>
    </gmd:citation>
    <xsl:apply-templates select="abstract" mode="named-gmd-ptfreetextpropertytype"/>
    <xsl:apply-templates select="purpose" mode="named-gmd-ptfreetextpropertytype"/>
    <xsl:apply-templates select="status"/>
    <xsl:apply-templates select="pointOfContact"/>
    <xsl:apply-templates select="resourceMaintenance"/>
    <xsl:apply-templates select="graphicOverview"/>
    <xsl:apply-templates select="descriptiveKeywords"/>
  </xsl:template>

  <xsl:template match="creationDate">
    <xsl:apply-templates select="." mode="gmddate">
      <xsl:with-param name="codeListValue">creation</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="revisionDate">
    <xsl:apply-templates select="." mode="gmddate">
      <xsl:with-param name="codeListValue">revision</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="identifier">
    <gmd:identifier>
      <gmd:MD_Identifier>
        <gmd:code>
          <xsl:apply-templates select="." mode="gcocharacterstring"/>
        </gmd:code>
      </gmd:MD_Identifier>
    </gmd:identifier>
  </xsl:template>

  <xsl:template match="otherCitationDetails">
    <gmd:otherCitationDetails>
      <xsl:apply-templates select="." mode="gcocharacterstring"/>
    </gmd:otherCitationDetails>
  </xsl:template>

  <xsl:template match="status">
    <gmd:status>
      <gmd:MD_ProgressCode>
        <xsl:attribute name="codeListValue">
          <xsl:value-of select="."/>
        </xsl:attribute>
        <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_ProgressCode</xsl:attribute>
      </gmd:MD_ProgressCode>
    </gmd:status>
  </xsl:template>

  <xsl:template match="pointOfContact">
    <gmd:pointOfContact xlink:show="embed">
      <xsl:apply-templates select="responsibleParty"/>
    </gmd:pointOfContact>
  </xsl:template>

  <xsl:template match="resourceMaintenance">
    <gmd:resourceMaintenance>
      <che:CHE_MD_MaintenanceInformation gco:isoType="gmd:MD_MaintenanceInformation">
        <gmd:maintenanceAndUpdateFrequency>
          <gmd:MD_MaintenanceFrequencyCode>
            <xsl:attribute name="codeListValue">
              <xsl:value-of select="maintenanceAndUpdateFrequency"/>
            </xsl:attribute>
            <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_MaintenanceFrequencyCode</xsl:attribute>
          </gmd:MD_MaintenanceFrequencyCode>
        </gmd:maintenanceAndUpdateFrequency>
      </che:CHE_MD_MaintenanceInformation>
    </gmd:resourceMaintenance>
  </xsl:template>

  <xsl:template match="graphicOverview">
    <gmd:graphicOverview>
      <gmd:MD_BrowseGraphic>
        <gmd:fileName>
          <xsl:apply-templates select="fileName" mode="gcocharacterstring" />
        </gmd:fileName>
        <xsl:apply-templates select="fileDescription" mode="named-gmd-ptfreetextpropertytype"/>
        <gmd:fileType>
          <xsl:apply-templates select="fileType" mode="gcocharacterstring" />
        </gmd:fileType>
      </gmd:MD_BrowseGraphic>
    </gmd:graphicOverview>
  </xsl:template>

  <xsl:template match="descriptiveKeywords">
    <gmd:descriptiveKeywords>
      <gmd:MD_Keywords>
        <xsl:for-each select="keyword">
          <xsl:apply-templates select="." mode="named-gmd-ptfreetextpropertytype"/>
        </xsl:for-each>
        <xsl:apply-templates select="thesaurusName"/>
      </gmd:MD_Keywords>
    </gmd:descriptiveKeywords>
  </xsl:template>

  <xsl:template match="thesaurusName">
    <gmd:thesaurusName>
      <gmd:CI_Citation>
        <gmd:title>
          <xsl:apply-templates select="title" mode="gcocharacterstring" />
        </gmd:title>
        <gmd:date>
          <gmd:CI_Date>
            <gmd:date>
              <gco:Date>
                <xsl:value-of select="date"/>
              </gco:Date>
            </gmd:date>
            <gmd:dateType>
              <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode"
                                   codeListValue="publication"/>
            </gmd:dateType>
          </gmd:CI_Date>
        </gmd:date>
        <gmd:identifier>
          <gmd:MD_Identifier>
            <gmd:code>
              <gmx:Anchor>
                <xsl:attribute name="xlink:href">
                  <xsl:value-of select="anchorLink"/>
                </xsl:attribute>
                <xsl:apply-templates select="anchorText"/>
              </gmx:Anchor>
            </gmd:code>
          </gmd:MD_Identifier>
        </gmd:identifier>
      </gmd:CI_Citation>
    </gmd:thesaurusName>
  </xsl:template>

  <xsl:template match="serviceType">
    <srv:serviceType>
      <gco:LocalName>
        <xsl:apply-templates/>
      </gco:LocalName>
    </srv:serviceType>
  </xsl:template>

  <xsl:template match="topicCategory">
    <gmd:topicCategory>
      <gmd:MD_TopicCategoryCode>
        <xsl:apply-templates/>
      </gmd:MD_TopicCategoryCode>
    </gmd:topicCategory>
  </xsl:template>

  <xsl:template match="resourceConstraints">
    <gmd:resourceConstraints>
      <xsl:call-template name="CHE_MD_LegalConstraints"/>
    </gmd:resourceConstraints>
    <gmd:resourceConstraints>
      <xsl:call-template name="MD_SecurityConstraints"/>
    </gmd:resourceConstraints>
    <gmd:resourceConstraints>
      <xsl:call-template name="MD_Constraints"/>
    </gmd:resourceConstraints>
  </xsl:template>

  <xsl:template match="equivalentScale">
    <gmd:spatialResolution>
      <gmd:MD_Resolution>
        <gmd:equivalentScale>
          <gmd:MD_RepresentativeFraction>
            <gmd:denominator>
              <gco:Integer>
                <xsl:apply-templates/>
              </gco:Integer>
            </gmd:denominator>
          </gmd:MD_RepresentativeFraction>
        </gmd:equivalentScale>
      </gmd:MD_Resolution>
    </gmd:spatialResolution>
  </xsl:template>

  <xsl:template match="distance">
    <gmd:spatialResolution>
      <gmd:MD_Resolution>
        <gmd:distance>
          <gco:Distance>
            <xsl:attribute name="uom">
              <xsl:value-of select="unit"/>
            </xsl:attribute>
            <xsl:value-of select="value"/>
          </gco:Distance>
        </gmd:distance>
      </gmd:MD_Resolution>
    </gmd:spatialResolution>
  </xsl:template>

  <xsl:template match="spatialRepresentationType">
    <gmd:spatialRepresentationType>
      <gmd:MD_SpatialRepresentationTypeCode>
        <xsl:attribute name="codeListValue">
          <xsl:value-of select="."/>
        </xsl:attribute>
        <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_SpatialRepresentationTypeCode</xsl:attribute>
      </gmd:MD_SpatialRepresentationTypeCode>
    </gmd:spatialRepresentationType>
  </xsl:template>

  <xsl:template match="restrictions">
    <srv:restrictions>
      <che:CHE_MD_LegalConstraints gco:isoType="gmd:MD_LegalConstraints">
        <gmd:useLimitation>
          <xsl:apply-templates select="limitation" mode="gcocharacterstring"/>
        </gmd:useLimitation>
        <gmd:otherConstraints>
          <xsl:apply-templates select="authorization" mode="gcocharacterstring"/>
        </gmd:otherConstraints>
        <gmd:otherConstraints>
          <xsl:apply-templates select="registration" mode="gcocharacterstring"/>
        </gmd:otherConstraints>
      </che:CHE_MD_LegalConstraints>
    </srv:restrictions>
  </xsl:template>

  <xsl:template name="CHE_MD_LegalConstraints">
    <che:CHE_MD_LegalConstraints gco:isoType="gmd:MD_LegalConstraints">
      <gmd:accessConstraints>
        <gmd:MD_RestrictionCode codeListValue="otherRestrictions"
                                codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode"/>
      </gmd:accessConstraints>
      <gmd:otherConstraints xsi:type="gmd:PT_FreeText_PropertyType">
        <xsl:apply-templates select="authorization" mode="gcocharacterstring"/>
      </gmd:otherConstraints>
    </che:CHE_MD_LegalConstraints>
  </xsl:template>

  <xsl:template name="MD_SecurityConstraints">
    <gmd:MD_SecurityConstraints>
      <gmd:classification>
        <gmd:MD_ClassificationCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_ClassificationCode"
                                   codeListValue="unclassified"/>
      </gmd:classification>
    </gmd:MD_SecurityConstraints>
  </xsl:template>

  <xsl:template name="MD_Constraints">
    <gmd:MD_Constraints/>
  </xsl:template>

  <xsl:template match="extent">
    <gmd:EX_Extent xmlns:geonet="http://www.fao.org/geonetwork">
      <xsl:apply-templates select="description" mode="named-gmd-ptfreetextpropertytype"/>
      <gmd:geographicElement>
        <gmd:EX_GeographicBoundingBox>
          <xsl:apply-templates select="geographicBoundingBox/*"/>
        </gmd:EX_GeographicBoundingBox>
      </gmd:geographicElement>
    </gmd:EX_Extent>
  </xsl:template>

  <xsl:template name="couplingType">
    <srv:couplingType>
      <srv:SV_CouplingType codeList="http://www.isotc211.org/2005/iso19119/resources/Codelist/gmxCodelists.xml#SV_CouplingType"
                           codeListValue="tight"/>
    </srv:couplingType>
  </xsl:template>

  <xsl:template match="operation">
    <srv:SV_OperationMetadata>
      <srv:operationName>
        <xsl:apply-templates select="name" mode="gcocharacterstring"/>
      </srv:operationName>
      <srv:DCP>
        <srv:DCPList codeList="http://www.isotc211.org/2005/iso19119/resources/Codelist/gmxCodelists.xml#DCPList"
                     codeListValue="WebServices"/>
      </srv:DCP>
      <srv:connectPoint>
        <gmd:CI_OnlineResource>
          <xsl:apply-templates select="url" mode="ptfreeurlpropertytype"/>
          <gmd:protocol>
            <xsl:apply-templates select="protocol" mode="gcocharacterstring"/>
          </gmd:protocol>
        </gmd:CI_OnlineResource>
      </srv:connectPoint>
    </srv:SV_OperationMetadata>
  </xsl:template>

  <!-- ***************************************************************
  DistributionInfo element with its children.
  **************************************************************** -->

  <xsl:template match="distributionInfo">
    <gmd:distributionInfo>
      <gmd:MD_Distribution>
        <xsl:apply-templates select="mdFormats"/>
        <xsl:apply-templates select="distributor"/>
        <xsl:apply-templates select="transferOptions"/>
      </gmd:MD_Distribution>
    </gmd:distributionInfo>
  </xsl:template>

  <xsl:template match="mdFormats">
    <xsl:for-each select="mdFormat">
      <gmd:distributionFormat xlink:show="embed">
        <gmd:MD_Format>
          <gmd:name>
            <xsl:apply-templates select="name" mode="gcocharacterstring"/>
          </gmd:name>
          <gmd:version>
            <xsl:apply-templates select="version" mode="gcocharacterstring"/>
          </gmd:version>
        </gmd:MD_Format>
      </gmd:distributionFormat>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="transferOptions">
    <xsl:for-each select="transferOption">
      <gmd:transferOptions>
        <gmd:MD_DigitalTransferOptions>
          <gmd:onLine>
            <gmd:CI_OnlineResource>
              <xsl:apply-templates select="url" mode="ptfreeurlpropertytype"/>
              <xsl:apply-templates select="protocol" mode="named-gmd-gcocharacterstring"/>
              <xsl:apply-templates select="name" mode="named-gmd-ptfreetextpropertytype"/>
              <xsl:apply-templates select="description" mode="named-gmd-ptfreetextpropertytype"/>
              <xsl:apply-templates select="onlineFunction"/>
            </gmd:CI_OnlineResource>
          </gmd:onLine>
        </gmd:MD_DigitalTransferOptions>
      </gmd:transferOptions>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="onlineFunction">
    <gmd:function>
      <gmd:CI_OnLineFunctionCode>
        <xsl:attribute name="codeListValue">
          <xsl:value-of select="."/>
        </xsl:attribute>
        <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_OnLineFunctionCode</xsl:attribute>
      </gmd:CI_OnLineFunctionCode>
    </gmd:function>
  </xsl:template>

  <xsl:template match="distributor">
    <gmd:distributor>
      <gmd:MD_Distributor>
        <gmd:distributorContact xlink:show="embed">
          <xsl:apply-templates select="responsibleParty"/>
        </gmd:distributorContact>
      </gmd:MD_Distributor>
    </gmd:distributor>
  </xsl:template>

  <!-- ***************************************************************
  DataQualityInfo element with its children.
  **************************************************************** -->

  <xsl:template match="dataQualityInfo">
    <gmd:dataQualityInfo>
      <gmd:DQ_DataQuality>
        <gmd:scope>
          <gmd:DQ_Scope>
            <gmd:level>
              <gmd:MD_ScopeCode codeListValue="dataset"
                                codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_ScopeCode"/>
            </gmd:level>
          </gmd:DQ_Scope>
        </gmd:scope>
        <xsl:apply-templates select="lineage"/>
      </gmd:DQ_DataQuality>
    </gmd:dataQualityInfo>
  </xsl:template>

  <xsl:template match="lineage">
    <gmd:lineage>
      <gmd:LI_Lineage>
        <gmd:statement xsi:type="gmd:PT_FreeText_PropertyType">
          <xsl:apply-templates select="." mode="gcocharacterstring"/>
        </gmd:statement>
      </gmd:LI_Lineage>
    </gmd:lineage>
  </xsl:template>

  <!-- ***************************************************************
  spatialRepresentationInfo element.
  **************************************************************** -->

  <xsl:template match="spatialRepresentationInfo">
    <gmd:spatialRepresentationInfo>
      <gmd:MD_VectorSpatialRepresentation>
        <gmd:geometricObjects>
          <gmd:MD_GeometricObjects>
            <gmd:geometricObjectType>
              <gmd:MD_GeometricObjectTypeCode>
                <xsl:attribute name="codeListValue">
                  <xsl:value-of select="."/>
                </xsl:attribute>
                <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_GeometricObjectTypeCode</xsl:attribute>
              </gmd:MD_GeometricObjectTypeCode>
            </gmd:geometricObjectType>
          </gmd:MD_GeometricObjects>
        </gmd:geometricObjects>
      </gmd:MD_VectorSpatialRepresentation>
    </gmd:spatialRepresentationInfo>
  </xsl:template>

  <!-- ***************************************************************
  Reusable static blocks.
  **************************************************************** -->

  <xsl:template match="responsibleParty">
    <che:CHE_CI_ResponsibleParty xmlns:geonet="http://www.fao.org/geonetwork" gco:isoType="gmd:CI_ResponsibleParty">
      <xsl:apply-templates select="organisationName" mode="named-gmd-ptfreetextpropertytype"/>
      <gmd:contactInfo>
        <gmd:CI_Contact>
          <xsl:apply-templates select="phone"/>
          <xsl:apply-templates select="address"/>
          <xsl:apply-templates select="onlineResource"/>
          <xsl:apply-templates select="hoursOfService" mode="named-gmd-gcocharacterstring"/>
        </gmd:CI_Contact>
      </gmd:contactInfo>
      <gmd:role>
        <gmd:CI_RoleCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_RoleCode">
          <xsl:attribute name="codeListValue">
            <xsl:value-of select="role"/>
          </xsl:attribute>
        </gmd:CI_RoleCode>
      </gmd:role>
      <xsl:apply-templates select="individualFirstName" mode="named-che-gcocharacterstring"/>
      <xsl:apply-templates select="individualLastName" mode="named-che-gcocharacterstring"/>
      <xsl:apply-templates select="organisationAcronym" mode="named-che-ptfreetextpropertytype"/>
    </che:CHE_CI_ResponsibleParty>
  </xsl:template>

  <xsl:template match="phone">
    <gmd:phone>
      <che:CHE_CI_Telephone gco:isoType="gmd:CI_Telephone">
        <xsl:apply-templates select="voice" mode="named-gmd-gcocharacterstring"/>
        <xsl:apply-templates select="facsimile" mode="named-gmd-gcocharacterstring"/>
      </che:CHE_CI_Telephone>
    </gmd:phone>
  </xsl:template>

  <xsl:template match="address">
    <gmd:address>
      <che:CHE_CI_Address gco:isoType="gmd:CI_Address">
        <xsl:apply-templates select="city" mode="named-gmd-gcocharacterstring"/>
        <xsl:apply-templates select="postalCode" mode="named-gmd-gcocharacterstring"/>
        <xsl:apply-templates select="country" mode="named-gmd-gcocharacterstring"/>
        <xsl:apply-templates select="electronicMailAddress" mode="named-gmd-gcocharacterstring"/>
        <xsl:apply-templates select="streetName" mode="named-che-gcocharacterstring"/>
        <xsl:apply-templates select="streetNumber" mode="named-che-gcocharacterstring"/>
      </che:CHE_CI_Address>
    </gmd:address>
  </xsl:template>

  <xsl:template match="onlineResource">
    <gmd:onlineResource>
      <gmd:CI_OnlineResource>
        <xsl:apply-templates select="url" mode="ptfreeurlpropertytype"/>
        <xsl:apply-templates select="protocol" mode="named-gmd-gcocharacterstring"/>
        <xsl:apply-templates select="name" mode="named-gmd-ptfreetextpropertytype"/>
      </gmd:CI_OnlineResource>
    </gmd:onlineResource>
  </xsl:template>

  <xsl:template match="geographicBoundingBox/*">
    <xsl:element name="gmd:{local-name()}">
      <xsl:apply-templates select="." mode="decimal"/>
    </xsl:element>
  </xsl:template>

  <!-- ***************************************************************
  Generic helpers.
  **************************************************************** -->

  <xsl:template match="*" mode="gcocharacterstring">
    <gco:CharacterString>
      <xsl:apply-templates/>
    </gco:CharacterString>
  </xsl:template>

  <xsl:template match="*" mode="gcodatetime">
    <gco:DateTime>
      <xsl:apply-templates/>
    </gco:DateTime>
  </xsl:template>

  <xsl:template match="*" mode="gcodate">
    <gco:Date>
      <xsl:apply-templates/>
    </gco:Date>
  </xsl:template>

  <xsl:template match="*" mode="decimal">
    <gco:Decimal>
      <xsl:apply-templates/>
    </gco:Decimal>
  </xsl:template>

  <xsl:template match="*" mode="gmddate">
    <xsl:param name="codeListValue"/>
    <gmd:date>
      <gmd:CI_Date>
        <gmd:date>
          <xsl:apply-templates select="." mode="gcodate" />
        </gmd:date>
        <gmd:dateType>
          <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode">
            <xsl:attribute name="codeListValue">
              <xsl:value-of select="$codeListValue"/>
            </xsl:attribute>
          </gmd:CI_DateTypeCode>
        </gmd:dateType>
      </gmd:CI_Date>
    </gmd:date>
  </xsl:template>

  <xsl:template match="*" mode="named-gmd-gcocharacterstring">
    <xsl:element name="gmd:{local-name()}">
      <xsl:apply-templates select="." mode="gcocharacterstring"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*" mode="named-che-gcocharacterstring">
    <xsl:element name="che:{local-name()}">
      <xsl:apply-templates select="." mode="gcocharacterstring"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*" mode="named-gmd-ptfreetextpropertytype">
    <xsl:element name="gmd:{local-name()}">
      <xsl:apply-templates select="." mode="ptfreetext"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*" mode="named-che-ptfreetextpropertytype">
    <xsl:element name="che:{local-name()}">
      <xsl:apply-templates select="." mode="ptfreetext"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*" mode="ptfreetext">
    <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>
    <xsl:apply-templates select="." mode="gcocharacterstring"/>
    <gmd:PT_FreeText>
      <gmd:textGroup>
        <gmd:LocalisedCharacterString locale="#EN"/>
      </gmd:textGroup>
      <gmd:textGroup>
        <gmd:LocalisedCharacterString locale="#DE">
          <xsl:value-of select="."/>
        </gmd:LocalisedCharacterString>
      </gmd:textGroup>
    </gmd:PT_FreeText>
  </xsl:template>

  <xsl:template match="*" mode="ptfreeurlpropertytype">
    <gmd:linkage xsi:type="che:PT_FreeURL_PropertyType">
      <gmd:URL>
        <xsl:value-of select="."/>
      </gmd:URL>
      <che:PT_FreeURL>
        <che:URLGroup>
          <che:LocalisedURL locale="#DE">
            <xsl:value-of select="."/>
          </che:LocalisedURL>
        </che:URLGroup>
      </che:PT_FreeURL>
    </gmd:linkage>
  </xsl:template>
</xsl:stylesheet>