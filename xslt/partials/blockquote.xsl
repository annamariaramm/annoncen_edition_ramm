<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:template name="blockquote">
        <xsl:param name="pageId" select="''"/>
        <xsl:param name="customUrl" select="$base_url"/>
        <xsl:variable
            name="fullUrl"
            select="concat($customUrl, $pageId)"/>
        <div class="footer-citation-content">
            <p class="footer-citation-title mb-1">
                How to cite
            </p>
            <p class="footer-citation-text mb-0">
                <xsl:value-of select="$project_title"/>,
                herausgegeben von Anna Maria Ramm, 2026
                (<a href="{$fullUrl}">
                    <xsl:value-of select="$fullUrl"/>
                </a>)
            </p>
        </div>
    </xsl:template>
</xsl:stylesheet>