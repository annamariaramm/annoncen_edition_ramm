<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    exclude-result-prefixes="xsl tei xs">

    <!-- Gemeinsame Seitenelemente -->
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>


    <xsl:output
        method="html"
        encoding="UTF-8"
        indent="yes"
        omit-xml-declaration="yes"
        version="5.0"/>


    <!-- Alle TEI-Annoncen -->
    <xsl:variable
        name="all-ads"
        select="
            collection(
                '../data/editions?select=*.xml;recurse=no'
            )
        "/>


    <xsl:template match="/">

        <html
            class="h-100"
            lang="{$default_lang}">

            <head>

                <xsl:call-template name="html_head">
                    <xsl:with-param
                        name="html_title"
                        select="'Statistiken'"/>
                </xsl:call-template>


                <style>

                    .statistik-section {
                        margin-bottom: 3rem;
                    }

                    .statistik-container {
                        width: 100%;
                        max-width: 900px;
                        margin: 0 auto;
                    }

                    .chart-wrapper {
                        width: 100%;
                        overflow-x: auto;
                    }

                    .chart {
                        width: 100%;
                        min-height: 500px;
                    }

                    .chart svg {
                        display: block;
                        margin: 0 auto;
                    }

                    .chart-title {
                        margin-bottom: 1rem;
                    }

                    .chart-description {
                        color: #6c757d;
                        margin-bottom: 1.5rem;
                    }

                    .pie-slice {
                        cursor: pointer;
                    }

                    .pie-slice:hover {
                        opacity: 0.8;
                    }

                    .chart-legend {
                        display: flex;
                        flex-wrap: wrap;
                        justify-content: center;
                        gap: 0.75rem 1.5rem;
                        margin-top: 1rem;
                    }

                    .legend-item {
                        display: flex;
                        align-items: center;
                        gap: 0.4rem;
                    }

                    .legend-symbol {
                        width: 14px;
                        height: 14px;
                        display: inline-block;
                        border: 1px solid #999;
                    }

                    .chart-tooltip {
                        position: absolute;
                        pointer-events: none;
                        background: rgba(0, 0, 0, 0.8);
                        color: white;
                        padding: 0.5rem 0.75rem;
                        border-radius: 0.25rem;
                        font-size: 0.9rem;
                        opacity: 0;
                    }

                </style>

            </head>


            <body
                class="d-flex flex-column h-100">

                <!-- Navigation -->
                <xsl:call-template name="nav_bar"/>


                <main
                    id="main"
                    class="flex-shrink-0 flex-grow-1 container my-4">


                    <!-- =========================================
                         Überschrift und Einführung
                         ========================================= -->

                    <h1 class="mb-3">
                        Statistiken
                    </h1>

                    <p class="lead text-muted mb-5">
                        Hier werden beispielhaft statistische Auswertungen des Materials gezeigt.
                        Die erste Visualisierung zeigt
                        das Verhältnis von Stellenanzeigen und
                        Personalangeboten. Die zweite Visualisierung zeigt
                        die in den Annoncen angegebenen Anstellungsdaten.
                    </p>


                    <!-- =========================================
                         Statistik 1
                         ========================================= -->

                    <section
                        class="statistik-section">

                        <div
                            class="statistik-container">

                            <h2 class="chart-title">
                                Stellenanzeigen und Personalangebote
                            </h2>

                            <p class="chart-description">
                                Verteilung der Annoncen auf
                                Stellenanzeigen und
                                Personalangebote.
                            </p>

                            <div
                                id="chart-annoncen"
                                class="chart">
                            </div>

                        </div>

                    </section>


                    <!-- =========================================
                         Statistik 2
                         ========================================= -->

                    <section
                        class="statistik-section">

                        <div
                            class="statistik-container">

                            <h2 class="chart-title">
                                Anstellungsdaten
                            </h2>

                            <p class="chart-description">
                                Verteilung der in den Annoncen angegebenen
                                Anstellungsdaten.
                            </p>

                            <div
                                id="chart-anstellungsdaten"
                                class="chart">
                            </div>

                        </div>

                    </section>


                    <!-- Daten für D3 -->

                    <script type="text/javascript">

                        const STATISTIKEN = {

                            annoncen: {
                                stellenanzeigen:
                                    <xsl:value-of
                                        select="
                                            count(
                                                $all-ads//tei:TEI[
                                                    .//tei:div[
                                                        contains(
                                                            @xml:id,
                                                            '_LP_'
                                                        )
                                                    ]
                                                ]
                                            )
                                        "/>,

                                personalangebote:
                                    <xsl:value-of
                                        select="
                                            count(
                                                $all-ads//tei:TEI[
                                                    .//tei:div[
                                                        contains(
                                                            @xml:id,
                                                            '_PS_'
                                                        )
                                                    ]
                                                ]
                                            )
                                        "/>
                            },


                            anstellungsdaten: [

    <xsl:for-each-group
        select="
            $all-ads//
            tei:date[
                @type='begin'
                and @when
                and matches(
                    string(@when),
                    '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
                )
            ]
        "
        group-by="string(@when)">

        {
            "datum":
                "<xsl:value-of
                    select="
                        format-date(
                            xs:date(current-grouping-key()),
                            '[D01].[M01].[Y0001]'
                        )
                    "/>",

            "iso":
                "<xsl:value-of
                    select="current-grouping-key()"/>",

            "anzahl":
                <xsl:value-of
                    select="count(current-group())"/>
        }

        <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
        </xsl:if>

    </xsl:for-each-group>

]

                        };

                    </script>


                </main>


                <!-- Footer -->
                <xsl:call-template name="html_footer"/>


                <!-- D3 -->
                <script src="vendor/d3/d3.min.js"></script>

                <!-- Eigene Statistik-JavaScript-Datei -->
                <script src="js/statistics.js"></script>


            </body>

        </html>

    </xsl:template>

</xsl:stylesheet>
