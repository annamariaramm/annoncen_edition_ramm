<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    exclude-result-prefixes="xsl tei xs">

    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/zotero.xsl"/>

    <xsl:output
        encoding="UTF-8"
        media-type="text/html"
        method="html"
        version="5.0"
        indent="yes"
        omit-xml-declaration="yes"/>
    <xsl:param name="section" select="'project-description'"/>
    <xsl:template match="/">
        <xsl:variable name="currentSection"
            select="//tei:div[@type = $section][1]"/>
        <xsl:variable name="doc_title"
            select="string($currentSection/tei:head)"/>
        <html class="h-100" lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param
                        name="html_title"
                        select="$doc_title"/>
                </xsl:call-template>
                <xsl:call-template name="zoterMetaTags">
                    <xsl:with-param
                        name="pageId"
                        select="concat($section, '.html')"/>
                    <xsl:with-param
                        name="zoteroTitle"
                        select="$doc_title"/>
                </xsl:call-template>
            </head>
            <body class="d-flex flex-column h-100">
                <xsl:call-template name="nav_bar"/>
                <main
                    id="main"
                    tabindex="-1"
                    class="flex-shrink-0 flex-grow-1">
                    <nav
                        style="--bs-breadcrumb-divider: '>';"
                        aria-label="breadcrumb"
                        class="ps-5 p-3">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item">
                                <a href="index.html">
                                    <xsl:value-of
                                        select="$project_short_title"/>
                                </a>
                            </li>
                            <li
                                class="breadcrumb-item active"
                                aria-current="page">
                                <xsl:value-of
                                    select="$doc_title"/>
                            </li>
                        </ol>
                    </nav>
                    <div class="container">
                        <div
                            class="project-page"
                            id="{$section}">
                            <h1>
                                <xsl:value-of
                                    select="$doc_title"/>
                            </h1>
                            <xsl:apply-templates
                                select="$currentSection/tei:p"/>
                            <xsl:if
                                test="$currentSection//tei:note[@place='bottom']">
                                <section
                                    class="footnotes"
                                    aria-label="Fußnoten">
                                    <h2>Fußnoten</h2>
                                    <ol>
                                        <xsl:for-each
                                            select="$currentSection//tei:note[@place='bottom']">
                                            <li id="note-{position()}">
                                                <xsl:apply-templates
                                                    select="node()"/>
                                            </li>
                                        </xsl:for-each>
                                    </ol>
                                </section>
                            </xsl:if>
                        </div>
                    </div>
                </main>
                <xsl:call-template name="html_footer"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:head">
        <h2>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>
    <xsl:template match="tei:unclear">
        <abbr title="unclear">
            <xsl:apply-templates/>
        </abbr>
    </xsl:template>
    <xsl:template match="tei:del">
        <del>
            <xsl:apply-templates/>
        </del>
    </xsl:template>
    <xsl:template match="tei:hi[@rend='kursiv']">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>
    <xsl:template match="tei:hi">
        <span>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:note[@place='bottom']">
    <xsl:variable name="noteNumber"
        select="count(preceding::tei:note[@place='bottom'][ancestor::tei:div[@type=$section]]) + 1"/>

    <sup class="footnote-reference">
        <a href="#note-{$noteNumber}" aria-label="Fußnote">
            <xsl:value-of select="$noteNumber"/>
        </a>
    </sup>
    </xsl:template>
    <xsl:template match="tei:ref">
        <a href="{@target}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
</xsl:stylesheet>