<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mei="http://www.music-encoding.org/ns/mei" version="2.0" exclude-result-prefixes="#all">

    <!-- Output as HTML because we want to render it in our browsers -->
    <xsl:output method="html"/>

    <!-- When the document root is matched we want to build the outer structure of our HTML document -->
    <xsl:template match="/">
        <html>
            <head>
            </head>
            <body>
                <h1>
                    <xsl:value-of select="//tei:titleStmt/tei:title"/>
                </h1>
                <h2>Edited by <xsl:value-of select="//tei:titleStmt/tei:respStmt/tei:persName"/></h2>
                <!-- We want to apply the templates to the TEI body -->
                <xsl:apply-templates select="//tei:body"/>
            </body>
        </html>
    </xsl:template>

    <!-- Transfer the structure of the TEI document to HTML -->
    <xsl:template match="tei:div">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:div[@type = 'footer']">
        <footer>
            <xsl:apply-templates/>
        </footer>
    </xsl:template>

    <xsl:template match="tei:div/tei:head">
        <h2>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <xsl:template match="tei:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>

    <!-- Text Highlighting -->
    <xsl:template match="tei:hi[@rend = 'bold']">
        <b>
            <xsl:apply-templates/>
        </b>
    </xsl:template>
    <xsl:template match="tei:hi[@rend = 'superscript']">
        <sup>
            <xsl:apply-templates/>
        </sup>
    </xsl:template>
    <xsl:template match="tei:hi[@rend = 'underline']">
        <u>
            <xsl:apply-templates/>
        </u>
    </xsl:template>
    <xsl:template match="tei:del">
        <s>
            <xsl:apply-templates/>
        </s>
    </xsl:template>

    <!--  Don't copy the lyrics (that will be done by Verovio and would be redundant)  -->
    <xsl:template match="mei:*/text()"/>

    <!-- Insert an image element to display the graphic -->
    <xsl:template match="tei:notatedMusic">
        <xsl:variable name="imgURL">
            <xsl:value-of select="./tei:graphic/data(@url)"/>
        </xsl:variable>
        <img src="{$imgURL}"/>
    </xsl:template>


</xsl:stylesheet>
