<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:template name="nav_bar">
        <a
            class="visually-hidden-focusable"
            href="#main">
            Zum Inhalt springen
        </a>
        <header>
    <div class="edition-banner position-relative text-center">
        <a href="index.html" class="edition-banner-link">
            <img
                src="images/collage.jpg"
                alt="Stellenanzeigen, Sydsvenska Dagbladet"
                class="edition-banner-image w-100" style="max-height: 250px; object-fit: cover;"/>
        </a>
        
    </div>
    <nav
        aria-label="Primary"
        class="navbar navbar-expand-lg">
                <div class="container-fluid">
                    <a
                        class="navbar-brand"
                        href="index.html">
                        <xsl:value-of select="$project_short_title"/>
                    </a>
                    <button
                        class="navbar-toggler"
                        type="button"
                        data-bs-toggle="collapse"
                        data-bs-target="#navbarSupportedContent"
                        aria-controls="navbarSupportedContent"
                        aria-expanded="false"
                        aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span>
                    </button>
                    <div
                        class="collapse navbar-collapse"
                        id="navbarSupportedContent">
                        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                            <li class="nav-item dropdown">
                                <a
                                    class="nav-link dropdown-toggle"
                                    href="#"
                                    role="button"
                                    data-bs-toggle="dropdown"
                                    aria-expanded="false">
                                    Home
                                </a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a
                                            class="dropdown-item"
                                            href="project-description.html">
                                            Projektbeschreibung
                                        </a>
                                    </li>
                                    <li>
                                        <a
                                            class="dropdown-item"
                                            href="historical-context.html">
                                            Historischer Kontext
                                        </a>
                                    </li>
                                    <li>
                                        <a
                                            class="dropdown-item"
                                            href="data.html">
                                            Datengrundlage
                                        </a>
                                    </li>
                                    <li>
                                        <a
                                            class="dropdown-item"
                                            href="edition.html">
                                            Über die Edition
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            <li class="nav-item">
                                <a
                                    class="nav-link"
                                    href="overview.html">
                                    Annoncen
                                </a>
                            </li>
                            <li class="nav-item">
                                <a
                                    class="nav-link"
                                    href="search.html">
                                    Erweiterte Suche
                                </a>
                            </li>
                            <li class="nav-item dropdown disabled">
                                <a
                                    class="nav-link dropdown-toggle"
                                    href="#"
                                    role="button"
                                    data-bs-toggle="dropdown"
                                    aria-expanded="false">
                                    Register
                                </a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a
                                            class="dropdown-item"
                                            href="listperson.html">
                                            Personen
                                        </a>
                                    </li>
                                    <li>
                                        <a
                                            class="dropdown-item"
                                            href="listplace.html">
                                            Orte
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            <li class="nav-item">
                                <a
                                    class="nav-link"
                                    href="statistics.html">
                                    Statistiken
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
        </header>
    </xsl:template>
</xsl:stylesheet>
