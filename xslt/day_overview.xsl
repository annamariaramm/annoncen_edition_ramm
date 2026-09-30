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
    encoding="UTF-8"
    media-type="text/html"
    method="html"
    version="5.0"
    indent="yes"
    omit-xml-declaration="yes"/>


<!-- ========================================================= -->
<!-- Alle Annoncen laden                                      -->
<!-- ========================================================= -->

<xsl:variable name="ads"
    select="
        collection(
            '../data/editions?select=*.xml;recurse=no'
        )
    "/>


<!-- ========================================================= -->
<!-- Alle Tage ermitteln, an denen mindestens eine Annonce    -->
<!-- vorhanden ist                                           -->
<!-- ========================================================= -->

<xsl:variable name="advertisement-dates"
    as="xs:date*"
    select="
        distinct-values(
            for $ad in $ads
            return
                xs:date(
                    string(
                        $ad//tei:sourceDesc//tei:date/@when
                    )
                )
        )
    "/>


<!-- ========================================================= -->
<!-- Wochentage                                               -->
<!-- ========================================================= -->

<xsl:variable name="weekday-names"
    as="xs:string*"
    select="
        (
            'Montag',
            'Dienstag',
            'Mittwoch',
            'Donnerstag',
            'Freitag',
            'Samstag',
            'Sonntag'
        )
    "/>


<!-- ========================================================= -->
<!-- Monatsnamen                                               -->
<!-- ========================================================= -->

<xsl:variable name="month-names"
    as="xs:string*"
    select="
        (
            'Januar',
            'Februar',
            'März',
            'April',
            'Mai',
            'Juni',
            'Juli',
            'August',
            'September',
            'Oktober',
            'November',
            'Dezember'
        )
    "/>


<!-- ========================================================= -->
<!-- HAUPTTRANSFORMATION                                      -->
<!--                                                         -->
<!-- Für jeden Tag mit mindestens einer Annonce wird eine     -->
<!-- eigene HTML-Datei erzeugt.                               -->
<!-- ========================================================= -->

<xsl:template match="/">

    <xsl:for-each select="$advertisement-dates">

        <xsl:sort select="."/>

        <xsl:variable name="current-date"
            as="xs:date"
            select="."/>

        <xsl:result-document
            href="{concat(
                'day-',
                format-date(
                    $current-date,
                    '[Y]-[M01]-[D01]'
                ),
                '.html'
            )}"
            method="html"
            encoding="UTF-8"
            indent="yes">

            <xsl:call-template name="day-page">
                <xsl:with-param
                    name="date"
                    select="$current-date"/>
            </xsl:call-template>

        </xsl:result-document>

    </xsl:for-each>

    <!--
        Das Hauptresultat selbst wird nicht benötigt.
        Die eigentlichen Seiten werden über xsl:result-document
        erzeugt.
    -->

    <html>
        <head>
            <title>Daily overview pages</title>
        </head>
        <body/>
    </html>

</xsl:template>


<!-- ========================================================= -->
<!-- TEMPLATE FÜR EINE EINZELNE TAGESSEITE                    -->
<!-- ========================================================= -->

<xsl:template name="day-page">

    <xsl:param name="date"
        as="xs:date"/>


    <!-- ===================================================== -->
    <!-- Annoncen dieses Tages                                -->
    <!-- ===================================================== -->

    <xsl:variable name="day-ads"
        select="
            $ads[
                xs:date(
                    string(
                        .//tei:sourceDesc//tei:date/@when
                    )
                )
                =
                $date
            ]
        "/>


    <!-- ===================================================== -->
    <!-- Vorheriger Tag mit Annoncen                           -->
    <!-- ===================================================== -->

    <xsl:variable name="previous-date"
        as="xs:date?"
        select="
            max(
                $advertisement-dates[
                    . lt $date
                ]
            )
        "/>


    <!-- ===================================================== -->
    <!-- Nächster Tag mit Annoncen                             -->
    <!-- ===================================================== -->

    <xsl:variable name="next-date"
        as="xs:date?"
        select="
            min(
                $advertisement-dates[
                    . gt $date
                ]
            )
        "/>


    <!-- ===================================================== -->
    <!-- Datum aufbereiten                                     -->
    <!-- ===================================================== -->

    <xsl:variable name="day"
        as="xs:integer"
        select="day-from-date($date)"/>

    <xsl:variable name="month"
        as="xs:integer"
        select="month-from-date($date)"/>

    <xsl:variable name="month-name"
        as="xs:string"
        select="$month-names[$month]"/>


    <!-- ===================================================== -->
    <!-- Wochentag                                             -->
    <!--                                                         -->
    <!-- 01.01.1906 war ein Montag.                           -->
    <!-- ===================================================== -->

    <xsl:variable name="days-since-new-year"
        as="xs:integer"
        select="
            xs:integer(
                days-from-duration(
                    $date - xs:date('1906-01-01')
                )
            )
        "/>

    <xsl:variable name="weekday-number"
        as="xs:integer"
        select="
            ($days-since-new-year mod 7) + 1
        "/>

    <xsl:variable name="weekday-name"
        as="xs:string"
        select="$weekday-names[$weekday-number]"/>


    <!-- ===================================================== -->
    <!-- Seitentitel                                           -->
    <!-- ===================================================== -->

    <xsl:variable name="doc-title"
        as="xs:string"
        select="
            concat(
                $weekday-name,
                ', ',
                format-integer($day, '00'),
                '. ',
                $month-name,
                ' 1906'
            )
        "/>


    <!-- ===================================================== -->
    <!-- HTML                                                   -->
    <!-- ===================================================== -->

    <html class="h-100" lang="{$default_lang}">

        <head>

            <xsl:call-template name="html_head">

                <xsl:with-param
                    name="html_title"
                    select="$doc-title"/>

            </xsl:call-template>

        </head>


        <body class="d-flex flex-column h-100">


            <!-- ================================================= -->
            <!-- Navigation                                         -->
            <!-- ================================================= -->

            <xsl:call-template name="nav_bar"/>


            <!-- ================================================= -->
            <!-- Hauptinhalt                                       -->
            <!-- ================================================= -->

            <main
                id="main"
                tabindex="-1"
                class="flex-shrink-0 flex-grow-1">

                <div class="container-fluid day-page">


                    <!-- ========================================= -->
                    <!-- Tagesnavigation                           -->
                    <!-- ========================================= -->

                    <div class="day-navigation">


                        <!-- ===================================== -->
                        <!-- Vorheriger Tag                         -->
                        <!-- ===================================== -->

                        <div class="day-navigation-prev">

                            <xsl:if test="exists($previous-date)">

                                <a
                                    href="{concat(
                                        'day-',
                                        format-date(
                                            $previous-date,
                                            '[Y]-[M01]-[D01]'
                                        ),
                                        '.html'
                                    )}">

                                    <i
                                        class="bi bi-arrow-left"
                                        aria-hidden="true">
                                    </i>

                                    <xsl:text>vorheriger Tag</xsl:text>

                                </a>

                            </xsl:if>

                        </div>


                        <!-- ===================================== -->
                        <!-- Aktuelles Datum                        -->
                        <!-- ===================================== -->

                        <div class="day-title">

                            <h1>
                                <xsl:value-of
                                    select="$doc-title"/>
                            </h1>

                        </div>


                        <!-- ===================================== -->
                        <!-- Nächster Tag                           -->
                        <!-- ===================================== -->

                        <div class="day-navigation-next">

                            <xsl:if test="exists($next-date)">

                                <a
                                    href="{concat(
                                        'day-',
                                        format-date(
                                            $next-date,
                                            '[Y]-[M01]-[D01]'
                                        ),
                                        '.html'
                                    )}">

                                    <xsl:text>nächster Tag</xsl:text>

                                    <i
                                        class="bi bi-arrow-right"
                                        aria-hidden="true">
                                    </i>

                                </a>

                            </xsl:if>

                        </div>

                    </div>


                    <!-- ================================================= -->
                    <!-- Filter                                             -->
                    <!-- ================================================= -->

                    <div
                        class="day-filters"
                        role="group"
                        aria-label="Annoncen filtern">

                        <button
                            type="button"
                            class="day-filter active"
                            data-filter="all">

                            Alle anzeigen

                        </button>

                        <button
                            type="button"
                            class="day-filter"
                            data-filter="LP">

                            Stellenanzeigen

                        </button>

                        <button
                            type="button"
                            class="day-filter"
                            data-filter="PS">

                            Personalangebote

                        </button>

                    </div>


                    <!-- ================================================= -->
                    <!-- Annoncenkarten                                     -->
                    <!-- ================================================= -->

                    <section class="day-cards-section">

                        <h2 class="visually-hidden">
                            Annoncen des Tages
                        </h2>


                        <div
                            id="day-cards"
                            class="day-cards">


                            <xsl:for-each select="$day-ads">

                                <xsl:sort
                                    select="
                                        string(
                                            .//tei:div/@xml:id
                                        )
                                    "/>


                                <!-- ===================================== -->
                                <!-- ID der Annonce                        -->
                                <!-- ===================================== -->

                                <xsl:variable name="id"
                                    as="xs:string"
                                    select="
                                        string(
                                            .//tei:div/@xml:id
                                        )
                                    "/>


                                <!-- ===================================== -->
                                <!-- Annoncentyp                           -->
                                <!-- ===================================== -->

                                <xsl:variable name="is-lp"
                                    as="xs:boolean"
                                    select="
                                        contains(
                                            $id,
                                            '_LP_'
                                        )
                                    "/>

                                <xsl:variable name="is-ps"
                                    as="xs:boolean"
                                    select="
                                        contains(
                                            $id,
                                            '_PS_'
                                        )
                                    "/>


                                <xsl:variable name="ad-type"
                                    as="xs:string"
                                    select="
                                        if ($is-lp)
                                        then 'LP'
                                        else if ($is-ps)
                                        then 'PS'
                                        else ''
                                    "/>


                                <!-- ===================================== -->
                                <!-- Annoncenkarte                         -->
                                <!-- ===================================== -->

                                <a
                                    href="{concat(
                                        $id,
                                        '.html'
                                    )}"
                                    class="day-ad-card"
                                    data-type="{$ad-type}"
                                    data-id="{$id}">


                                    <!-- =============================== -->
                                    <!-- Bild                              -->
                                    <!-- =============================== -->

                                    <div class="day-ad-card-image">

                                        <img
                                            src="{concat(
                                                'images/',
                                                $id,
                                                '.jpg'
                                            )}"
                                            alt=""
                                            loading="lazy"/>

                                    </div>


                                    <!-- =============================== -->
                                    <!-- Informationen                     -->
                                    <!-- =============================== -->

                                    <div class="day-ad-card-information">

                                        <h3>
                                            <xsl:value-of
                                                select="$id"/>
                                        </h3>


                                        <p
                                            class="day-ad-card-date">

                                            <xsl:value-of
                                                select="
                                                    format-integer(
                                                        $day,
                                                        '00'
                                                    )
                                                "/>

                                            <xsl:text>. </xsl:text>

                                            <xsl:value-of
                                                select="$month-name"/>

                                            <xsl:text> 1906</xsl:text>

                                        </p>


                                        <p
                                            class="day-ad-card-type">

                                            <xsl:choose>

                                                <xsl:when test="$is-lp">

                                                    <xsl:text>
                                                        Stellenanzeige
                                                    </xsl:text>

                                                </xsl:when>

                                                <xsl:when test="$is-ps">

                                                    <xsl:text>
                                                        Personalangebot
                                                    </xsl:text>

                                                </xsl:when>

                                                <xsl:otherwise>

                                                    <xsl:text>
                                                        Annonce
                                                    </xsl:text>

                                                </xsl:otherwise>

                                            </xsl:choose>

                                        </p>

                                    </div>

                                </a>

                            </xsl:for-each>

                        </div>

                    </section>

                </div>

            </main>


            <!-- ================================================= -->
            <!-- Footer                                             -->
            <!-- ================================================= -->

            <xsl:call-template name="html_footer"/>


            <!-- ================================================= -->
            <!-- JavaScript für die Tagesfilter                   -->
            <!-- ================================================= -->

            <script src="js/day_overview.js"></script>


        </body>

    </html>

</xsl:template>
</xsl:stylesheet>
