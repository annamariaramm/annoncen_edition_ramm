<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    exclude-result-prefixes="xsl tei xs">

    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/zotero.xsl"/>

    <xsl:output
        encoding="UTF-8"
        media-type="text/html"
        method="html"
        version="5.0"
        indent="yes"
        omit-xml-declaration="yes"/>
    <xsl:template match="/">
        <xsl:variable
            name="doc_title"
            select="'Stellenanzeigen, Sydsvenska Dagbladet'"/>
        <xsl:variable
            name="all-ads"
            select="
                collection(
                    '../data/editions?select=*.xml;recurse=no'
                )
            "/>
        <html
            class="h-100"
            lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param
                        name="html_title"
                        select="$doc_title"/>
                </xsl:call-template>
                <xsl:call-template name="zoterMetaTags"/>
            </head>
            <body class="d-flex flex-column h-100">
                <xsl:call-template name="nav_bar"/>
                <main
                    id="main"
                    tabindex="-1"
                    class="flex-shrink-0 flex-grow-1">

                    <div class="container">
                        <h2>
                            <xsl:value-of select="$project_title"/>
                        </h2>
                        <p class="lead">
                            Die Edition erschließt rund 450 Stellenanzeigen
                            aus dem <em>Sydsvenska Dagbladet</em> des Jahres
                            1906 und macht sie für die historische und digitale
                            Analyse zugänglich.
                        </p>
                        <section class="quickstart mt-5">
                            <h2>Quickstart</h2>
                            <div class="row g-4">
                                <div class="col-md-6">
                                    <div class="quickstart-card">
                                        <h3>
                                            Heute vor 120 Jahren
                                        </h3>
                                        <div
                                            id="today-120-content">
                                            <p>
                                                Lade Annoncen …
                                            </p>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="quickstart-card">
                                        <h3>Volltextsuche</h3>
                                        <p>
                                            Durchsuche die Annoncen nach
                                            Stellenbezeichnungen, Daten, Orten
                                            und weiteren Informationen.
                                        </p>
                                        <a
                                            href="search.html"
                                            class="btn btn-primary">
                                            Zur Suche
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </section>
                    </div>
                </main>
                <xsl:call-template name="html_footer"/>
                <script type="text/javascript">
                    const EDITION_ADS = [
                        <xsl:for-each select="$all-ads">
                            <xsl:sort
                                select="
                                    .//tei:div[@xml:id][1]/@xml:id
                                "/>
                            {
                                "id":
                                "<xsl:value-of
                                    select="
                                        .//tei:div[@xml:id][1]/@xml:id
                                    "/>",
                                "date":
                                "<xsl:value-of
                                    select="
                                        .//tei:date[@when][1]/@when
                                    "/>"
                            }
                            <xsl:if test="position() != last()">
                                <xsl:text>,</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    ];
                </script>
                <script src="js/index.js"></script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>