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

    <!-- Selected month -->
    <xsl:param name="month" as="xs:integer" select="1"/>

    <!-- Month names -->
    <xsl:variable name="month-names"
        as="xs:string*"
        select="(
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
        )"/>

    <xsl:variable name="month-name"
        as="xs:string"
        select="$month-names[$month]"/>

    <!-- All TEI advertisements -->
    <xsl:variable name="ads"
        select="collection('../data/editions?select=*.xml;recurse=no')"/>

    <!-- Advertisements from the selected month of 1906 -->
    <xsl:variable name="month-ads"
        select="$ads[
            substring(
                string(.//tei:sourceDesc//tei:date/@when),
                1,
                4
            ) = '1906'
            and
            xs:integer(
                substring(
                    string(.//tei:sourceDesc//tei:date/@when),
                    6,
                    2
                )
            ) = $month
        ]"/>

    <!-- First day of selected month -->
    <xsl:variable name="first-of-month"
        as="xs:date"
        select="xs:date(
            concat(
                '1906-',
                format-integer($month, '00'),
                '-01'
            )
        )"/>

    <!-- Last day of selected month -->
    <xsl:variable name="last-of-month"
        as="xs:date"
        select="
            $first-of-month
            + xs:yearMonthDuration('P1M')
            - xs:dayTimeDuration('P1D')
        "/>

    <!-- Number of days in selected month -->
    <xsl:variable name="days-in-month"
        as="xs:integer"
        select="day-from-date($last-of-month)"/>


    <xsl:template match="/">

        <xsl:variable name="doc-title"
            select="concat($month-name, ' 1906 – Annoncen')"/>

        <html class="h-100" lang="{$default_lang}">

            <head>

                <xsl:call-template name="html_head">
                    <xsl:with-param
                        name="html_title"
                        select="$doc-title"/>
                </xsl:call-template>

            </head>


            <body class="d-flex flex-column h-100">

                <xsl:call-template name="nav_bar"/>


                <main id="main"
                      tabindex="-1"
                      class="flex-shrink-0 flex-grow-1">


                    <div class="container-fluid month-page">


                        <!-- MONTH HEADER -->

                        <div class="month-navigation">

                            <div class="month-navigation-prev">

                                <xsl:if test="$month &gt; 1">

                                    <a href="{if ($month - 1 = 1)
                                              then 'overview.html'
                                              else concat(
                                                  'overview-',
                                                  format-integer(
                                                      $month - 1,
                                                      '00'
                                                  ),
                                                  '.html'
                                              )}">

                                        <i class="bi bi-arrow-left"
                                           aria-hidden="true"></i>

                                        vorheriger Monat

                                    </a>

                                </xsl:if>

                            </div>


                            <div class="month-title">

                                <h1>
                                    <xsl:value-of select="$month-name"/>
                                    <xsl:text> 1906</xsl:text>
                                </h1>

                            </div>


                            <div class="month-navigation-next">

                                <xsl:if test="$month &lt; 12">

                                    <a href="{concat(
                                        'overview-',
                                        format-integer(
                                            $month + 1,
                                            '00'
                                        ),
                                        '.html'
                                    )}">

                                        nächster Monat

                                        <i class="bi bi-arrow-right"
                                           aria-hidden="true"></i>

                                    </a>

                                </xsl:if>

                            </div>

                        </div>


                        <!-- FILTER BUTTONS -->

                        <div class="month-filters"
                             role="group"
                             aria-label="Annoncen filtern">

                            <button type="button"
                                    class="month-filter active"
                                    data-filter="all">

                                Alle anzeigen

                            </button>


                            <button type="button"
                                    class="month-filter"
                                    data-filter="LP">

                                Stellenanzeigen

                            </button>


                            <button type="button"
                                    class="month-filter"
                                    data-filter="PS">

                                Personalangebote

                            </button>

                        </div>


                        <!-- THREE-COLUMN LAYOUT -->

                        <div class="month-layout">


                            <!-- LEFT: TIMELINE -->

                            <aside class="month-timeline-column">

                                <h2 class="visually-hidden">
                                    Tage mit Annoncen
                                </h2>


                                <div id="month-timeline"
                                     class="month-timeline">

                                    <xsl:for-each-group
                                        select="$month-ads"
                                        group-by="
                                            substring(
                                                string(
                                                    .//tei:sourceDesc//tei:date/@when
                                                ),
                                                9,
                                                2
                                            )
                                        ">

                                        <xsl:sort
                                            select="
                                                xs:integer(
                                                    current-grouping-key()
                                                )
                                            "/>


                                        <xsl:variable name="day"
                                            as="xs:integer"
                                            select="
                                                xs:integer(
                                                    current-grouping-key()
                                                )
                                            "/>


                                        <xsl:variable name="date"
                                            select="concat(
                                                '1906-',
                                                format-integer(
                                                    $month,
                                                    '00'
                                                ),
                                                '-',
                                                format-integer(
                                                    $day,
                                                    '00'
                                                )
                                            )"/>


                                        <xsl:variable name="lp-count"
                                            as="xs:integer"
                                            select="
                                                count(
                                                    current-group()[
                                                        contains(
                                                            string(
                                                                .//tei:div/@xml:id
                                                            ),
                                                            '_LP_'
                                                        )
                                                    ]
                                                )
                                            "/>


                                        <xsl:variable name="ps-count"
                                            as="xs:integer"
                                            select="
                                                count(
                                                    current-group()[
                                                        contains(
                                                            string(
                                                                .//tei:div/@xml:id
                                                            ),
                                                            '_PS_'
                                                        )
                                                    ]
                                                )
                                            "/>


                                        <div class="timeline-item">

                                            <a href="{concat(
                                                'day-1906-',
                                                format-integer(
                                                    $month,
                                                    '00'
                                                ),
                                                '-',
                                                format-integer(
                                                    $day,
                                                    '00'
                                                ),
                                                '.html'
                                            )}"
                                               class="timeline-date"
                                               data-date="{$date}"
                                               data-lp="{$lp-count}"
                                               data-ps="{$ps-count}">

                                                <xsl:value-of
                                                    select="
                                                        format-integer(
                                                            $day,
                                                            '00'
                                                        )
                                                    "/>

                                                <xsl:text>.</xsl:text>

                                            </a>

                                        </div>

                                    </xsl:for-each-group>

                                </div>

                            </aside>


                            <!-- CENTER: DAY CARDS -->

                            <section class="month-cards-column">

                                <h2 class="visually-hidden">
                                    Annoncen nach Tagen
                                </h2>


                                <div id="month-cards"
                                     class="month-cards">


                                    <xsl:for-each-group
                                        select="$month-ads"
                                        group-by="
                                            substring(
                                                string(
                                                    .//tei:sourceDesc//tei:date/@when
                                                ),
                                                9,
                                                2
                                            )
                                        ">

                                        <xsl:sort
                                            select="
                                                xs:integer(
                                                    current-grouping-key()
                                                )
                                            "/>


                                        <xsl:variable name="day"
                                            as="xs:integer"
                                            select="
                                                xs:integer(
                                                    current-grouping-key()
                                                )
                                            "/>


                                        <xsl:variable name="date"
                                            select="concat(
                                                '1906-',
                                                format-integer(
                                                    $month,
                                                    '00'
                                                ),
                                                '-',
                                                format-integer(
                                                    $day,
                                                    '00'
                                                )
                                            )"/>


                                        <xsl:variable name="lp-count"
                                            as="xs:integer"
                                            select="
                                                count(
                                                    current-group()[
                                                        contains(
                                                            string(
                                                                .//tei:div/@xml:id
                                                            ),
                                                            '_LP_'
                                                        )
                                                    ]
                                                )
                                            "/>


                                        <xsl:variable name="ps-count"
                                            as="xs:integer"
                                            select="
                                                count(
                                                    current-group()[
                                                        contains(
                                                            string(
                                                                .//tei:div/@xml:id
                                                            ),
                                                            '_PS_'
                                                        )
                                                    ]
                                                )
                                            "/>


                                        <a href="{concat(
                                            'day-1906-',
                                            format-integer(
                                                $month,
                                                '00'
                                            ),
                                            '-',
                                            format-integer(
                                                $day,
                                                '00'
                                            ),
                                            '.html'
                                        )}"
                                           class="day-card"
                                           data-date="{$date}"
                                           data-lp="{$lp-count}"
                                           data-ps="{$ps-count}">


                                            <!-- IMAGE PREVIEWS -->

                                           <!-- IMAGE PREVIEW -->

<div class="day-card-images">

    <span>Zu den Annoncen</span>

</div>


                                            <!-- CARD INFORMATION -->

                                            <div class="day-card-information">

                                                <h3>

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

                                                </h3>


                                                <p class="day-card-count">

                                                    <strong class="total-count">

                                                        <xsl:value-of
                                                            select="
                                                                $lp-count
                                                                +
                                                                $ps-count
                                                            "/>

                                                    </strong>

                                                    <xsl:text>
                                                        Annonce(n)
                                                    </xsl:text>

                                                </p>


                                                <p class="day-card-types">

                                                    <span class="lp-count">

                                                        <xsl:value-of
                                                            select="$lp-count"/>

                                                        <xsl:text>
                                                            Stellenanzeigen, 
                                                        </xsl:text>

                                                    </span>


                                                    <span class="ps-count">

                                                        <xsl:value-of
                                                            select="$ps-count"/>

                                                        <xsl:text>
                                                            Personalangebote
                                                        </xsl:text>

                                                    </span>

                                                </p>

                                            </div>

                                        </a>

                                    </xsl:for-each-group>

                                </div>

                            </section>


                            <!-- RIGHT: CALENDAR + CHART -->

                            <aside class="month-tools-column">


                                <!-- MONTH CALENDAR -->

                                <section class="month-calendar">

                                    <h2>Monate</h2>


                                    <div class="month-calendar-grid">

                                        <xsl:for-each
                                            select="1 to 12">

                                            <xsl:variable
                                                name="calendar-month"
                                                select="."/>

                                            <a href="{if ($calendar-month = 1)
                                                      then 'overview.html'
                                                      else concat(
                                                          'overview-',
                                                          format-integer(
                                                              $calendar-month,
                                                              '00'
                                                          ),
                                                          '.html'
                                                      )}"
                                               class="{if (
                                                   $calendar-month = $month
                                               )
                                               then 'current'
                                               else ''}">

                                                <xsl:value-of
                                                    select="
                                                        $month-names[
                                                            $calendar-month
                                                        ]
                                                    "/>

                                            </a>

                                        </xsl:for-each>

                                    </div>

                                </section>


                                <!-- D3 CHART -->

                                <section class="month-chart-section">

                                    <h2>Annoncen pro Tag</h2>


                                    <div id="month-chart"
                                         data-month="{$month}"
                                         data-month-name="{$month-name}">


                                        <xsl:for-each
                                            select="1 to $days-in-month">

                                            <xsl:variable
                                                name="day"
                                                select="."/>

                                            <xsl:variable
                                                name="date"
                                                select="concat(
                                                    '1906-',
                                                    format-integer(
                                                        $month,
                                                        '00'
                                                    ),
                                                    '-',
                                                    format-integer(
                                                        $day,
                                                        '00'
                                                    )
                                                )"/>


                                            <xsl:variable
                                                name="day-ads"
                                                select="
                                                    $month-ads[
                                                        substring(
                                                            string(
                                                                .//tei:sourceDesc
                                                                //tei:date/@when
                                                            ),
                                                            9,
                                                            2
                                                        )
                                                        =
                                                        format-integer(
                                                            $day,
                                                            '00'
                                                        )
                                                    ]
                                                "/>


                                            <span class="chart-data"
                                                  data-date="{$date}"
                                                  data-day="{$day}"
                                                  data-lp="{count(
                                                      $day-ads[
                                                          contains(
                                                              string(
                                                                  .//tei:div
                                                                  /@xml:id
                                                              ),
                                                              '_LP_'
                                                          )
                                                      ]
                                                  )}"
                                                  data-ps="{count(
                                                      $day-ads[
                                                          contains(
                                                              string(
                                                                  .//tei:div
                                                                  /@xml:id
                                                              ),
                                                              '_PS_'
                                                          )
                                                      ]
                                                  )}">
                                            </span>

                                        </xsl:for-each>

                                    </div>

                                </section>

                            </aside>

                        </div>

                    </div>

                </main>


                <xsl:call-template name="html_footer"/>


                <!-- D3 -->
                <script src="vendor/d3/d3.min.js"></script>

                <!-- Project JavaScript -->
                <script src="js/month_overview.js"></script>

            </body>

        </html>

    </xsl:template>

</xsl:stylesheet>
