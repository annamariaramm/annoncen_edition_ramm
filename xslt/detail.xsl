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

    <xsl:output
        method="html"
        encoding="UTF-8"
        indent="yes"
        omit-xml-declaration="yes"
        version="5.0"/>

    <xsl:variable name="all-ads" select="collection('../data/editions?select=*.xml;recurse=no')"/>

    <xsl:variable name="duplicates-doc" select="doc('../data/xml/duplicates.xml')"/>


    <xsl:variable name="weekday-names" select="('Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag')"/>
    <xsl:variable name="month-names" select="('Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember')"/>

    <xsl:template match="/">
        <xsl:variable name="current-id" select="string(//tei:div/@xml:id)"/>
        <xsl:variable name="file-basename" select="tokenize(document-uri(/), '/')[last()]"/>
        <xsl:variable name="xml-filename" select="$file-basename"/>
        <xsl:variable name="id-pure" select="substring-before($xml-filename, '.xml')"/>

        <xsl:variable name="date-str" select="string(//tei:sourceDesc//tei:date/@when)"/>
        <xsl:variable name="current-date" select="xs:date($date-str)"/>
        <xsl:variable name="day" select="day-from-date($current-date)"/>
        <xsl:variable name="month" select="month-from-date($current-date)"/>
        <xsl:variable name="days-since-new-year" select="xs:integer(days-from-duration($current-date - xs:date('1906-01-01')))"/>
        <xsl:variable name="weekday-number" select="($days-since-new-year mod 7) + 1"/>

        <xsl:variable name="formatted-title" select="concat($weekday-names[$weekday-number], ', ', format-integer($day, '00'), '. ', $month-names[$month], ' 1906')"/>


        <xsl:variable name="sorted-ads" as="document-node()*">
            <xsl:for-each select="$all-ads">
                <xsl:sort select="string(//tei:div/@xml:id)"/>
                <xsl:sequence select="."/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="current-pos" select="index-of($sorted-ads//tei:div/@xml:id, $current-id)[1]"/>
        <xsl:variable name="prev-ad-id" select="$sorted-ads[$current-pos - 1]//tei:div/@xml:id"/>
        <xsl:variable name="next-ad-id" select="$sorted-ads[$current-pos + 1]//tei:div/@xml:id"/>

        <xsl:variable name="translation-path" select="concat('../data/translations/translation_', $xml-filename)"/>
        <xsl:variable name="translation-doc" select="if (doc-available($translation-path)) then doc($translation-path) else ()"/>

        <html class="h-100" lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="concat('Annonce ', $id-pure, ' – ', $formatted-title)"/>
                </xsl:call-template>
                <style>
    /* Der Übersetzungs-Container ist standardmäßig ausgeblendet */
    .translation-block {
        display: none;
        transition: all 0.3s ease;
    }

    /* Sobald die Maus über die Karte/Box der Transkription fährt, 
       wird der Übersetzungsbereich darunter sichtbar */
    .transcription-card:hover .translation-block {
        display: block;
    }

    /* Stil für hervorgehobene Inline-Annotationen */
    .annotation {
        text-decoration: underline;
        text-decoration-style: dotted;
        font-weight: 500;
    }
    .person-annotation, .occupation-annotation { color: #7A263A; }
    .place-annotation { color: #D8B65A; }
    .date-annotation { color: #af1f41; }
</style>
            </head>
            <body class="d-flex flex-column h-100">
                <xsl:call-template name="nav_bar"/>

                <main id="main" class="flex-shrink-0 flex-grow-1 container-fluid my-4">
                    <div class="row align-items-center mb-4 text-center">
                        <div class="col-2 text-start">
                            <xsl:if test="exists($prev-ad-id)">
                                <a href="{concat($prev-ad-id, '.html')}" class="btn btn-outline-secondary">
                                    <i class="bi bi-arrow-left"></i> vorherige Annonce
                                </a>
                            </xsl:if>
                        </div>
                        <div class="col-8">
                            <h1 class="h2 mb-0"><xsl:value-of select="$formatted-title"/></h1>
                            <small class="text-muted"><xsl:value-of select="$id-pure"/></small>
                        </div>
                        <div class="col-2 text-end">
                            <xsl:if test="exists($next-ad-id)">
                                <a href="{concat($next-ad-id, '.html')}" class="btn btn-outline-secondary">
                                    nächste Annonce<i class="bi bi-arrow-right"></i>
                                </a>
                            </xsl:if>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-9">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <div class="card p-2">
                                        <img src="{concat('images/', $id-pure, '.jpg')}" class="img-fluid rounded" alt="Originalanzeige {$id-pure}"/>
                                    </div>
                                </div>
<div class="col-md-6 mb-3">
    <div class="card p-3 transcription-card h-100 d-flex flex-column justify-content-between">
        <div>
            <h3 class="h5 border-bottom pb-2">Transkription</h3>
            <div class="transcription-text mb-3">
                <xsl:apply-templates select="//tei:body"/>
            </div>
        </div>
        <xsl:if test="exists($translation-doc)">
            <div class="translation-block mt-3 pt-3 border-top bg-light p-2 rounded">
                <h4 class="h6 text-primary mb-1">
                    <i class="bi bi-translate"></i> Übersetzung (Deutsch)
                </h4>
                <p class="mb-0 small text-dark">
                    <xsl:value-of select="$translation-doc//tei:body"/>
                </p>
            </div>
        </xsl:if>
    </div>
</div>
                            </div>
                            <div class="row mt-3">
                                <div class="col-12 d-flex gap-2">
                                    <a href="{concat('pdf/', $id-pure, '.pdf')}" class="btn btn-primary" download="">
                                        <i class="bi bi-file-earmark-pdf"></i> PDF herunterladen
                                    </a>
                                    <a href="{concat('xml/', $id-pure, '.xml')}" class="btn btn-outline-primary" download="">
                                        <i class="bi bi-file-earmark-code"></i> XML herunterladen
                                    </a>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card p-3">
                                <h3 class="h6 border-bottom pb-2"><i class="bi bi-layers"></i> Mehrfachdrucke (Duplikate in anderen Ausgaben)</h3>
                                <xsl:variable name="target-ref" select="concat('#', $id-pure)"/>
                                <xsl:variable name="reprint-group" select="$duplicates-doc//tei:relation[tei:ptr/@target = $target-ref]"/>
                                <xsl:choose>
                                    <xsl:when test="exists($reprint-group)">
                                        <ul class="list-unstyled mb-0">
                                            <xsl:for-each select="$reprint-group/tei:ptr">
                                                <xsl:variable name="other-id" select="substring-after(@target, '#')"/>
                                                <xsl:if test="$other-id != $id-pure">
                                                    <li class="mb-2">
                                                        <a href="{concat($other-id, '.html')}" class="btn btn-sm btn-outline-info w-100 text-start">
                                                            <i class="bi bi-link-45deg"></i> <xsl:value-of select="$other-id"/>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </ul>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <p class="text-muted small mb-0">Keine weiteren Drucke verzeichnet.</p>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </div>
                    </div>
                </main>
                <xsl:call-template name="html_footer"/>
                <script src="js/detail.js"></script>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:person[@role='employee']">
        <a
            href="{concat('listperson.html?id=', @xml:id)}"
            class="annotation person-annotation"
            title="Zum Personenregister">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <xsl:template
        match="tei:person[@role='employee']/tei:occupation">
        <a
            href="{concat('listperson.html?occ=', normalize-space(.))}"
            class="annotation occupation-annotation"
            title="Zum Personenregister">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <xsl:template match="tei:placeName[@ref]">
        <a
            href="{concat('listplace.html?id=', substring-after(@ref, '#'))}"
            class="annotation place-annotation"
            title="Zum Ortsregister">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <xsl:template
        match="tei:date[
            @type='begin'
            and matches(
                string(@when),
                '^1906-[0-9]{2}-[0-9]{2}$'
            )
        ]">
        <a
            href="{concat('statistics.html?date=', @when)}"
            class="annotation date-annotation"
            title="Zu den Statistiken">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <xsl:template match="tei:p">
        <p><xsl:apply-templates/></p>
    </xsl:template>
</xsl:stylesheet>