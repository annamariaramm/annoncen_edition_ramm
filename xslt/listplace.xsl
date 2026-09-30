<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl tei xs"
    version="2.0">

    <!-- Partials importieren -->
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>

    <xsl:output method="html" indent="yes" encoding="UTF-8"/>

    <!-- Alle Editionen einsammeln für die Annoncen-Vorschau -->
    <xsl:variable name="all-ads" select="collection('../data/editions?select=*.xml;recurse=no')"/>

    <xsl:template match="/">
        
        <!-- 1. JSON-Suchindex für die Annoncen im Hintergrund erzeugen -->
        <xsl:result-document href="js/search_index.json" method="text" encoding="UTF-8">
            <xsl:text>[</xsl:text>
            <xsl:for-each select="$all-ads">
                <xsl:sort select="string(.//tei:div/@xml:id)"/>
                <xsl:variable name="id" select="string(.//tei:div/@xml:id)"/>
                <xsl:variable name="date-pub" select="string(.//tei:sourceDesc//tei:date/@when)"/>
                <xsl:variable name="raw-text" select="normalize-space(string(.//tei:body))"/>
                <xsl:variable name="clean-text" select="replace(replace(replace($raw-text, '\\', '\\\\'), '&quot;', '\\&quot;'), '\n|\r|\t', ' ')"/>
                
                <!-- Orte und deren Typen extrahieren, die in dieser Annonce referenziert werden -->
                <xsl:text>{</xsl:text>
                <xsl:text>"id": "</xsl:text><xsl:value-of select="$id"/><xsl:text>",</xsl:text>
                <xsl:text>"pubDate": "</xsl:text><xsl:value-of select="$date-pub"/><xsl:text>",</xsl:text>
                <xsl:text>"text": "</xsl:text><xsl:value-of select="$clean-text"/><xsl:text>",</xsl:text>
                <xsl:text>"places": [</xsl:text>
                <xsl:for-each select=".//tei:placeName[@ref]">
                    <xsl:text>{"ref": "</xsl:text><xsl:value-of select="substring-after(@ref, '#')"/><xsl:text>", "type": "</xsl:text><xsl:value-of select="@type"/><xsl:text>"}</xsl:text>
                    <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:text>]</xsl:text>
                <xsl:text>}</xsl:text>
                <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:text>]</xsl:text>
        </xsl:result-document>

        <html class="h-100" lang="de">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="'Ortsübersicht'"/>
                </xsl:call-template>
                <!-- Leaflet CSS -->
                <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
                <style>
                    #map { height: 500px; width: 100%; margin-bottom: 20px; border-radius: 4px; }
                    .filter-bar { margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-radius: 4px; }
                    /* Farbdefinitionen nach Wunsch: Buttergelb, Beige, Weinrot */
                    .badge-employment { background-color: #800020; color: white; padding: 3px 8px; border-radius: 3px; font-size: 0.85em; margin-right: 4px; }
                    .badge-residence { background-color: #f5f5dc; color: #333; border: 1px solid #dcdcdc; padding: 3px 8px; border-radius: 3px; font-size: 0.85em; margin-right: 4px; }
                    .badge-application { background-color: #fffacd; color: #333; border: 1px solid #eedc82; padding: 3px 8px; border-radius: 3px; font-size: 0.85em; margin-right: 4px; }
                </style>
            </head>
            <body class="d-flex flex-column h-100">
                <!-- Korrekter Aufruf der Navbar via Partial -->
                <xsl:call-template name="nav_bar"/>

                <main class="flex-shrink-0 flex-grow-1 container my-4">
                    <h1 class="mb-2">Ortsübersicht</h1>
                    <p class="lead text-muted mb-4">
                        Diese Karte gibt eine Übersicht über alle in den Stellenanzeigen des <em>Sydsvenska Dagbladet</em> (1906) genannten Orte, differenziert nach Anstellungs-, Herkunfts- und Bewerbungsorten.
                    </p>

                    <!-- Filter-Bar mit "Alle auswählen"-Button -->
                    <div class="filter-bar shadow-sm">
                        <div class="d-flex flex-wrap align-items-center justify-content-between">
                            <div>
                                <strong class="me-3">Filter nach Typ: </strong>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input place-filter" type="checkbox" id="filter-employment" value="employment" checked="checked"/>
                                    <label class="form-check-label" for="filter-employment">Anstellungsorte</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input place-filter" type="checkbox" id="filter-residence" value="residence" checked="checked"/>
                                    <label class="form-check-label" for="filter-residence">Herkunftsorte</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input place-filter" type="checkbox" id="filter-application" value="application" checked="checked"/>
                                    <label class="form-check-label" for="filter-application">Bewerbungsorte</label>
                                </div>
                            </div>
                            <button id="btn-select-all" type="button" class="btn btn-outline-secondary btn-sm mt-2 mt-md-0">Alle auswählen</button>
                        </div>
                    </div>

                    <!-- Karte -->
                    <div id="map"></div>

                    <!-- Export-Button für Annonsen-IDs -->
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h2 class="h4 mb-0">Betreffende Annoncen (<span id="result-count">0</span>)</h2>
                        <button id="export-txt-btn" class="btn btn-outline-primary btn-sm" disabled="disabled">
                            <i class="bi bi-download"></i> Ergebnisse als ID-Liste herunterladen (.txt)
                        </button>
                    </div>

                    <!-- Raster für die Annoncen-Vorschau (analog zur Suche) -->
                    <div id="results-grid" class="row row-cols-1 row-cols-md-3 g-4 mb-5">
                        <div class="col-12 text-center my-3 text-muted">
                            <p>Bitte wählen Sie einen Ort auf der Karte aus oder passen Sie die Filter an.</p>
                        </div>
                    </div>
                </main>

                <!-- Korrekter Aufruf des Footers via Partial -->
                <xsl:call-template name="html_footer"/>

                <!-- Leaflet JS -->
                <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

                <!-- listplace.xml Daten unsichtbar ins JSON-Embedding für die Karte übergeben -->
                <script id="places-data" type="application/json" style="display:none;">
                [
                    <xsl:for-each select="//tei:place[tei:location/tei:geo]">
                        <xsl:variable name="id" select="@xml:id"/>
                        <xsl:variable name="name" select="tei:placeName[1]"/>
                        <xsl:variable name="coords" select="normalize-space(tei:location/tei:geo)"/>
                        <xsl:variable name="lat" select="normalize-space(substring-before($coords, ','))"/>
                        <xsl:variable name="lon" select="normalize-space(substring-after($coords, ','))"/>
                        
                        <xsl:variable name="empCount" select="sum(tei:measure[@type='frequency' and @subtype='employment']/@count)"/>
                        <xsl:variable name="resCount" select="sum(tei:measure[@type='frequency' and @subtype='residence']/@count)"/>
                        <xsl:variable name="appCount" select="sum(tei:measure[@type='frequency' and @subtype='application']/@count)"/>
                        <xsl:variable name="totalCount" select="$empCount + $resCount + $appCount"/>

                        {
                            "id": "<xsl:value-of select="$id"/>",
                            "name": "<xsl:value-of select="$name"/>",
                            "lat": <xsl:value-of select="$lat"/>,
                            "lon": <xsl:value-of select="$lon"/>,
                            "employment": <xsl:value-of select="$empCount"/>,
                            "residence": <xsl:value-of select="$resCount"/>,
                            "application": <xsl:value-of select="$appCount"/>,
                            "total": <xsl:value-of select="$totalCount"/>
                        }<xsl:if test="position() != last()">,</xsl:if>
                    </xsl:for-each>
                ]
                </script>

                <!-- Externe JavaScript-Datei einbinden -->
                <script src="js/listplace.js"></script>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>