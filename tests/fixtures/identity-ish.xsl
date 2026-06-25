<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

  <xsl:param name="suffix" as="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema"/>

  <xsl:template match="/">
    <result id="{root/item/@id}">
      <xsl:value-of select="concat(normalize-space(root/item), $suffix)"/>
    </result>
  </xsl:template>
</xsl:stylesheet>
