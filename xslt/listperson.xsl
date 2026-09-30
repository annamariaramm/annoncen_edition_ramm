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
    <xsl:variable
        name="all-ads"
        select="collection('../data/editions?select=*.xml;recurse=no')"/>
    <xsl:template match="/">
        <html class="h-100" lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param
                        name="html_title"
                        select="'Personenübersicht'"/>
                </xsl:call-template>
                <style>
                    .personen-filter {
                        margin-bottom: 1.5rem;
                    }
                    .personen-tabelle {
                        width: 100%;
                    }
                    .personen-tabelle th,
                    .personen-tabelle td {
                        vertical-align: middle;
                    }
                    .personen-tabelle tbody tr.person-zeile {
                        cursor: pointer;
                    }
                    .personen-tabelle tbody tr.person-zeile.selected {
                        background-color: rgba(13, 110, 253, 0.10);
                    }
                    .personen-tabelle tbody tr.person-zeile:hover {
                        background-color: rgba(13, 110, 253, 0.05);
                    }
                    .annoncen-links a {
                        margin-right: 0.5rem;
                        margin-bottom: 0.25rem;
                        display: inline-block;
                    }
                    .keine-ergebnisse {
                        display: none;
                    }
                </style>
            </head>
            <body class="d-flex flex-column h-100">
                <xsl:call-template name="nav_bar"/>
                <main
                    id="main"
                    class="flex-shrink-0 flex-grow-1 container my-4">
                    <h1 class="mb-2">
                        Personenübersicht (Stellenbezeichnungen)
                    </h1>
                    <p class="lead text-muted mb-4">
                        Das Personenregister listet die Stellenbezeichnungen auf, die in den Annoncen vorkommen. 
                        Über die Filter können die
                        Bezeichnungen nach Geschlecht eingegrenzt werden.
                        Durch Auswahl einer oder mehrerer Zeilen können
                        außerdem die zugehörigen Annoncen-IDs als
                        TXT-Datei heruntergeladen werden.
                    </p>
                    <div
                        class="card p-4 mb-4 shadow-sm bg-light personen-filter">
                        <div
                            class="d-flex align-items-center flex-wrap gap-3">
                            <strong>
                                Personen anzeigen:
                            </strong>
                            <label>
                                <input
                                    type="radio"
                                    name="sex-filter"
                                    value="all"
                                    checked="checked"/>
                                Alle
                            </label>
                            <label>
                                <input
                                    type="radio"
                                    name="sex-filter"
                                    value="female"/>
                                Frauen
                            </label>
                            <label>
                                <input
                                    type="radio"
                                    name="sex-filter"
                                    value="male"/>
                                Männer
                            </label>
                            <button
                                type="button"
                                id="reset-selection-btn"
                                class="btn btn-sm btn-outline-secondary">
                                Auswahl aufheben
                            </button>
                        </div>
                    </div>
                    <div
                        class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-3">
                        <div>
                            <strong>
                                Angezeigte Personen:
                            </strong>
                            <span id="personen-anzahl">
                                0
                            </span>
                        </div>
                        <div>
                            <span
                                id="auswahl-anzahl"
                                class="text-muted me-3">
                                0 ausgewählt
                            </span>
                            <button
                                type="button"
                                id="download-personen-btn"
                                class="btn btn-outline-primary">
                                <i class="bi bi-download"></i>
                                Ergebnisse als ID-Liste herunterladen (.txt)
                            </button>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table
                            class="table table-striped table-hover align-middle personen-tabelle">
                            <thead>
                                <tr>
                                    <th
                                        scope="col"
                                        style="width: 60px;">
                                        Auswahl
                                    </th>
                                    <th scope="col">
                                        Personenbezeichnung
                                    </th>
                                    <th
                                        scope="col"
                                        style="width: 120px;">
                                        Anzahl
                                    </th>
                                    <th scope="col">
                                        Zugehörige Annoncen
                                    </th>
                                </tr>
                            </thead>
                            <tbody id="personen-tabelle-body">
                                <xsl:for-each-group
    select="$all-ads//tei:person[@role='employee']"
    group-by="
        lower-case(
            normalize-space(
                string-join(
                    (
                        text()[normalize-space()],
                        tei:occupation//text()[normalize-space()]
                    ),
                    ' '
                )
            )
        )
    ">
                                    <xsl:variable
                                        name="group"
                                        select="current-group()"/>


                                    <xsl:variable
    name="display-name"
    select="
        normalize-space(
            string-join(
                (
                    $group[1]/text()[normalize-space()],
                    $group[1]/tei:occupation//text()[normalize-space()]
                ),
                ' '
            )
        )
    "/>
                                    <xsl:variable
                                        name="female-persons"
                                        select="$group[@sex='female']"/>
                                    <xsl:variable
                                        name="male-persons"
                                        select="$group[@sex='male']"/>
                                    <xsl:variable
                                        name="female-ids"
                                        select="
                                            distinct-values(
                                                $female-persons/
                                                ancestor::tei:div[1]/
                                                @xml:id
                                            )
                                        "/>
                                    <xsl:variable
                                        name="male-ids"
                                        select="
                                            distinct-values(
                                                $male-persons/
                                                ancestor::tei:div[1]/
                                                @xml:id
                                            )
                                        "/>
                                    <xsl:variable
                                        name="all-ids"
                                        select="
                                            distinct-values(
                                                $group/
                                                ancestor::tei:div[1]/
                                                @xml:id
                                            )
                                        "/>
                                    <tr
                                        class="person-zeile"
                                        data-name="{$display-name}"
                                        data-female-count="{count($female-persons)}"
                                        data-male-count="{count($male-persons)}"
                                        data-all-count="{count($group)}">
                                        <td>
                                            <input
                                                type="checkbox"
                                                class="person-auswahl"
                                                aria-label="{$display-name} auswählen"/>
                                        </td>
                                        <td>
                                            <strong>
                                                <xsl:value-of
                                                    select="$display-name"/>
                                            </strong>
                                        </td>
                                        <td
                                            class="personen-count">
                                            <xsl:value-of
                                                select="count($group)"/>
                                        </td>
                                        <td class="annoncen-links">
    <details class="links-all">
        <summary>
            <xsl:value-of select="count($all-ids)"/>
            <xsl:text> Annoncen</xsl:text>
        </summary>
        <div class="annoncen-dropdown">
            <xsl:for-each
                select="$all-ids">
                <a
                    href="{concat(., '.html')}">
                    <xsl:value-of
                        select="."/>
                </a>
            </xsl:for-each>
        </div>
    </details>
    <details
        class="links-female"
        style="display:none;">
        <summary>
            <xsl:value-of select="count($female-ids)"/>
            <xsl:text> Annoncen</xsl:text>
        </summary>
        <div class="annoncen-dropdown">
            <xsl:for-each
                select="$female-ids">
                <a
                    href="{concat(., '.html')}">

                    <xsl:value-of
                        select="."/>
                </a>
            </xsl:for-each>
        </div>
    </details>
    <details
        class="links-male"
        style="display:none;">
        <summary>
            <xsl:value-of select="count($male-ids)"/>
            <xsl:text> Annoncen</xsl:text>
        </summary>
        <div class="annoncen-dropdown">
            <xsl:for-each
                select="$male-ids">
                <a
                    href="{concat(., '.html')}">
                    <xsl:value-of
                        select="."/>
                </a>
            </xsl:for-each>
        </div>
    </details>
    <span
        class="ids-data"
        data-all-ids="{string-join($all-ids, '|')}"
        data-female-ids="{string-join($female-ids, '|')}"
        data-male-ids="{string-join($male-ids, '|')}">
    </span>
</td>

                                    </tr>
                                </xsl:for-each-group>
                            </tbody>
                        </table>
                    </div>
                    <p
                        id="keine-ergebnisse"
                        class="keine-ergebnisse text-muted mt-4">
                        Für den ausgewählten Filter wurden keine
                        Personenbezeichnungen gefunden.
                    </p>
                </main>
                <xsl:call-template name="html_footer"/>
                <script src="js/listperson.js"></script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>