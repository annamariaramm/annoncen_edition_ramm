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

    <xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" version="5.0"/>

    <xsl:variable name="all-ads" select="collection('../data/editions?select=*.xml;recurse=no')"/>

    <xsl:variable name="all-occupations" select="distinct-values($all-ads//tei:occupation/normalize-space(text()))"/>
    <xsl:variable name="all-places" select="distinct-values($all-ads//tei:placeName[@ref]/normalize-space(text()))"/>
    <xsl:variable name="all-traits" select="distinct-values($all-ads//tei:trait[@type='character']/normalize-space(text()))"/>
    <xsl:variable name="all-skills" select="distinct-values($all-ads//tei:trait[@type='skill']/normalize-space(text()))"/>
    <xsl:variable name="all-begin-dates" select="distinct-values($all-ads//tei:date[@type='begin'][@when]/@when)"/>

    <xsl:template match="/">
        
        <xsl:result-document href="js/search_index.json" method="text" encoding="UTF-8">
            <xsl:text>[</xsl:text>
            <xsl:for-each select="$all-ads">
                <xsl:sort select="string(.//tei:div/@xml:id)"/>
                
                <xsl:variable name="id" select="string(.//tei:div/@xml:id)"/>
                <xsl:variable name="type" select="if (contains($id, '_LP_')) then 'LP' else if (contains($id, '_PS_')) then 'PS' else ''"/>
                <xsl:variable name="date-pub" select="string(.//tei:sourceDesc//tei:date/@when)"/>
                
                <xsl:variable name="raw-text" select="normalize-space(string(.//tei:body))"/>
                <xsl:variable name="clean-text" select="replace(replace(replace($raw-text, '\\', '\\\\'), '&quot;', '\\&quot;'), '\n|\r|\t', ' ')"/>
                
                <xsl:text>{</xsl:text>
                <xsl:text>"id": "</xsl:text><xsl:value-of select="$id"/><xsl:text>",</xsl:text>
                <xsl:text>"type": "</xsl:text><xsl:value-of select="$type"/><xsl:text>",</xsl:text>
                <xsl:text>"pubDate": "</xsl:text><xsl:value-of select="$date-pub"/><xsl:text>",</xsl:text>
                
                <xsl:text>"sex": [</xsl:text>
                <xsl:for-each select="distinct-values(.//tei:person/@sex)">
                    <xsl:text>"</xsl:text><xsl:value-of select="."/><xsl:text>"</xsl:text>
                    <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:text>],</xsl:text>

                <xsl:text>"occupations": [</xsl:text>
                <xsl:for-each select="distinct-values(.//tei:occupation/normalize-space(text()))">
                    <xsl:text>"</xsl:text><xsl:value-of select="replace(., '&quot;', '\\&quot;')"/><xsl:text>"</xsl:text>
                    <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:text>],</xsl:text>

                <xsl:text>"places": [</xsl:text>
                <xsl:for-each select="distinct-values(.//tei:placeName[@ref]/normalize-space(text()))">
                    <xsl:text>"</xsl:text><xsl:value-of select="replace(., '&quot;', '\\&quot;')"/><xsl:text>"</xsl:text>
                    <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:text>],</xsl:text>

                <xsl:text>"traits": [</xsl:text>
                <xsl:for-each select="distinct-values(.//tei:trait[@type='character']/normalize-space(text()))">
                    <xsl:text>"</xsl:text><xsl:value-of select="replace(., '&quot;', '\\&quot;')"/><xsl:text>"</xsl:text>
                    <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:text>],</xsl:text>

                <xsl:text>"skills": [</xsl:text>
                <xsl:for-each select="distinct-values(.//tei:trait[@type='skill']/normalize-space(text()))">
                    <xsl:text>"</xsl:text><xsl:value-of select="replace(., '&quot;', '\\&quot;')"/><xsl:text>"</xsl:text>
                    <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:text>],</xsl:text>

                <xsl:text>"beginDates": [</xsl:text>
                <xsl:for-each select="distinct-values(.//tei:date[@type='begin'][@when]/@when)">
                    <xsl:text>"</xsl:text><xsl:value-of select="."/><xsl:text>"</xsl:text>
                    <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:text>],</xsl:text>

                <xsl:text>"text": "</xsl:text><xsl:value-of select="$clean-text"/><xsl:text>"</xsl:text>
                
                <xsl:text>}</xsl:text>
                <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:text>]</xsl:text>
        </xsl:result-document>

        <html class="h-100" lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="'Erweiterte Suche'"/>
                </xsl:call-template>
            </head>
            <body class="d-flex flex-column h-100">
                <xsl:call-template name="nav_bar"/>

                <main id="main" class="flex-shrink-0 flex-grow-1 container my-4">
                    <h1 class="mb-2">Erweiterte Suche</h1>
                    <p class="lead text-muted mb-4">
                        Die erweiterte Suche dient der gezielten Auswertung der Stellen- und Personalangebote. Dabei können die Freitextsuche, die Suche nach spezifischen IDs (die nach dem Muster yyyy_mm_dd_SD_LP/PS_001 aufgebaut sind) sowie granulare Annotationen (Geschlecht, Berufsbezeichnungen, Orte, Eigenschaften, Kenntnisse und das Anstellungsdatum) kombiniert werden, um relevante Quellenkorpora zu filtern. Aktuell ist ein Download der Suchergebnisse in Form der Angabe der IDs möglich. Zukünftig soll diese Funktion erweitert  und ein Download der XML-Dateien möglich gemacht werden.
                    </p>
                    <div class="card p-4 mb-4 shadow-sm bg-light">
                        <div class="row g-3">
                            <div class="col-md-8">
                                <label for="search-text" class="form-label fw-bold">Freitextsuche / Suchbegriff</label>
                                <input type="text" id="search-text" class="form-control" placeholder="z. B. flicka, Hushållerska oder Wortbestandteile..."/>
                            </div>
                            <div class="col-md-4">
                                <label for="search-id" class="form-label fw-bold">Annoncen-ID</label>
                                <input type="text" id="search-id" class="form-control" placeholder="z. B. 1906_01_22_SD_PS_001"/>
                            </div>
                            <div class="col-md-3">
                                <label for="filter-type" class="form-label fw-bold">Annoncentyp</label>
                                <select id="filter-type" class="form-select">
                                    <option value="">Alle Annoncen</option>
                                    <option value="LP">Nur Stellenanzeigen (LP)</option>
                                    <option value="PS">Nur Personalangebote (PS)</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="filter-sex" class="form-label fw-bold">Geschlecht</label>
                                <select id="filter-sex" class="form-select">
                                    <option value="">Alle</option>
                                    <option value="female">Weiblich</option>
                                    <option value="male">Männlich</option>
                                    <option value="unspecified">Unbekannt / Nicht genannt</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="filter-occupation" class="form-label fw-bold">Berufe</label>
                                <select id="filter-occupation" class="form-select" multiple="multiple" size="3">
                                    <xsl:for-each select="$all-occupations">
                                        <xsl:sort select="."/>
                                        <option value="{.}"><xsl:value-of select="."/></option>
                                    </xsl:for-each>
                                </select>
                                <small class="text-muted">Strg/Cmd gedrückt halten für Mehrfachauswahl</small>
                            </div>
                            <div class="col-md-3">
                                <label for="filter-place" class="form-label fw-bold">Orte</label>
                                <select id="filter-place" class="form-select" multiple="multiple" size="3">
                                    <xsl:for-each select="$all-places">
                                        <xsl:sort select="."/>
                                        <option value="{.}"><xsl:value-of select="."/></option>
                                    </xsl:for-each>
                                </select>
                                <small class="text-muted">Strg/Cmd gedrückt halten für Mehrfachauswahl</small>
                            </div>
                            <div class="col-md-4">
                                <label for="filter-trait" class="form-label fw-bold">Charaktereigenschaften</label>
                                <select id="filter-trait" class="form-select" multiple="multiple" size="3">
                                    <xsl:for-each select="$all-traits">
                                        <xsl:sort select="."/>
                                        <option value="{.}"><xsl:value-of select="."/></option>
                                    </xsl:for-each>
                                </select>
                                <small class="text-muted">Strg/Cmd gedrückt halten für Mehrfachauswahl</small>
                            </div>
                            <div class="col-md-4">
                                <label for="filter-skill" class="form-label fw-bold">Kenntnisse / Skills</label>
                                <select id="filter-skill" class="form-select" multiple="multiple" size="3">
                                    <xsl:for-each select="$all-skills">
                                        <xsl:sort select="."/>
                                        <option value="{.}"><xsl:value-of select="."/></option>
                                    </xsl:for-each>
                                </select>
                                <small class="text-muted">Strg/Cmd gedrückt halten für Mehrfachauswahl</small>
                            </div>
                            <div class="col-md-4">
                                <label
                                    for="filter-date"
                                    class="form-label fw-bold">
                                    Anstellungsdatum (Beginn)
                                </label>
                                <select
                                    id="filter-date"
                                    class="form-select"
                                    multiple="multiple"
                                    size="3">
                                <xsl:for-each select="$all-begin-dates">
                                    <xsl:sort select="."/>
                                    <option value="{.}">
                                        <xsl:value-of
                                            select="
                                                format-date(
                                                    xs:date(.),
                                                    '[D01].[M01].[Y0001]'
                                                    )
                                                "/>
                                    </option>
                                </xsl:for-each>
                                </select>
                                <small class="text-muted">
                                    Strg/Cmd gedrückt halten für Mehrfachauswahl
                                </small>
                        </div>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-top">
                            <button id="btn-reset" type="button" class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-counterclockwise"></i> Filter zurücksetzen
                            </button>
                            <button id="btn-download-ids" type="button" class="btn btn-outline-primary" disabled="disabled">
                                <i class="bi bi-download"></i> Ergebnisse als ID-Liste herunterladen (.txt)
                            </button>
                        </div>
                    </div>

                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h2 class="h4 mb-0">Ergebnisse</h2>
                        <span id="results-count" class="badge bg-primary fs-6">0 Annoncen gefunden</span>
                    </div>

                    <div id="results-grid" class="row row-cols-1 row-cols-md-3 g-4">
                    </div>
                </main>
                <xsl:call-template name="html_footer"/>
                <script src="js/search.js"></script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>