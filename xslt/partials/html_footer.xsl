<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:import href="./blockquote.xsl"/>
    <xsl:template name="html_footer">
        <footer class="py-4 bg-body-tertiary">
            <div class="container text-center">
                <p class="footer-copyright mb-2">
                    © 2026 Anna Maria Ramm
                </p>
                <div class="footer-citation">
                    <xsl:call-template name="blockquote">
                        <xsl:with-param name="pageId" select="''"/>
                    </xsl:call-template>
                </div>
                <div class="footer-github">
                    <a href="{$github_url}"
                       target="_blank"
                       rel="noopener noreferrer"
                       aria-label="GitHub repository">
                        <i aria-hidden="true" class="bi bi-github"></i>
                        <span class="visually-hidden">
                            GitHub repository
                        </span>
                    </a>
                </div>
            </div>
        </footer>
        <script src="vendor/jquery/jquery-3.7.1.min.js"></script>
        <script src="vendor/bootstrap-5.3.5-dist/js/bootstrap.bundle.min.js"></script>
    </xsl:template>
</xsl:stylesheet>