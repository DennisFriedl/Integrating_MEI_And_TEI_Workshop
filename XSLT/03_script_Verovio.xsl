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
                <!-- Load the Verovio Javascript library -->
                <script src="http://www.verovio.org/javascript/latest/verovio-toolkit-wasm.js" defer=""/>
                <!-- Add the Javascript code to render the Verovio images -->
                <script> 
                    <!-- When the page finished loading initialize a Verovio toolkit. Notice that this code will not be exectuted during the transformation from TEI to HTML but only when we load the transformed HTML page in our browsers. We are only adding code to the HTML output to be executed later. -->
                    document.addEventListener("DOMContentLoaded", (event) => {
                    verovio.module.onRuntimeInitialized = () => {
                    let tk = new verovio.toolkit();
                    
                    <!-- Settings for the toolkit -->
                    tk.setOptions({
                    scale: 40,
                    // footer: "none",
                    adjustPageWidth: true,
                    adjustPageHeight: true,
                    // shrinkToFit: true,
                    pageMarginLeft: 20,
                    pageMarginRight: 20,
                    pageMarginTop: 0,
                    pageMarginBottom: 5
                    });
                    
                    <!-- Get all HTML elements with the class 'notationVerovio' (which are placholders for the old TEI elements notatedMusic). -->
                    let notationVerovioElements = document.getElementsByClassName('notationVerovio');
                    
                    <!-- Iterate over each snippet of MEI in notatedMusic (so that we can render an indefinite number of MEI snippet)  -->
                    <xsl:for-each select="//tei:notatedMusic/mei:*">  
                        <!-- Verovio expects 'complete' MEI, starting with <music> and <body>. We have to check which is the root element of our MEI snippet and wrap the missing elements around it. Then safe the result in a variable. -->
                        <xsl:variable name="completeMei">
                            <xsl:choose>
                                
                                <!-- If the root is a mdiv -->
                                <xsl:when test="./name() = 'mdiv'">
                                    <music>
                                        <body>
                                            <xsl:copy-of select="."/>
                                        </body>
                                    </music>
                                </xsl:when>
                                                               
                                <!-- If the root is a section -->
                                <xsl:when test="./name() = 'section'">
                                    <music>
                                        <body>
                                            <mdiv>
                                                <score>
                                                    <xsl:copy-of select="./mei:scoreDef"/>
                                                    <xsl:copy-of select="."/>
                                                </score>
                                            </mdiv>
                                        </body>
                                    </music>
                                </xsl:when>
                                                               
                                <!-- If the root is a layer -->
                                <xsl:when test="./name() = 'layer'">
                                    <music>
                                        <body>
                                            <mdiv>
                                                <score>
                                                    <scoreDef>
                                                        <staffGrp>
                                                            <staffDef n="1" lines="0"/>
                                                        </staffGrp>
                                                    </scoreDef>
                                                    <section>
                                                        <measure right="invis">
                                                            <staff n="1">
                                                                <xsl:copy-of select="."/>
                                                            </staff>
                                                        </measure>
                                                    </section>
                                                </score>
                                            </mdiv>
                                        </body>
                                    </music>
                                </xsl:when>
                                                                                         
                                <!-- In all other cases -->
                                <xsl:otherwise>
                                    <xsl:copy-of select="."/>
                                </xsl:otherwise>
                                
                            </xsl:choose>
                        </xsl:variable>     
                        
                        <!-- With 'renderData' we can hand over the MEI data to Verovio. It expects a string as input so we have to serialize our MEI tree first. Verovio returns the rendered images as SVG data which we can safe in a variable. -->
                        svg = tk.renderData(`<xsl:value-of select="serialize($completeMei)"/>`, {});
                        <!-- To display the image as part of our HTML page we need to insert the SVG data in our span elements. The corresponding span element is determined by the current position of the for-loop. -->
                        notationVerovioElements[<xsl:value-of select="position() - 1"/>].innerHTML = svg;      
                    </xsl:for-each>            
                    }
                    });
                </script>
            </head>
            <body>
                <h1><xsl:value-of select="//tei:titleStmt/tei:title"/></h1>
                <h2>Edited by <xsl:value-of select="//tei:titleStmt/tei:respStmt/tei:persName"/></h2>
                <!--  We want to apply the templates to the TEI body -->
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
    
    <xsl:template match="tei:div[@type='footer']">
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
    <xsl:template match="tei:hi[@rend='bold']">
        <b>
            <xsl:apply-templates/>
        </b>
    </xsl:template>
    <xsl:template match="tei:hi[@rend='superscript']">
        <sup>
            <xsl:apply-templates/>
        </sup>
    </xsl:template>
    <xsl:template match="tei:hi[@rend='underline']">
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

    <!-- Insert HTML span elements with the class 'notationVerovio' where there is notatedMusic in TEI -->
    <xsl:template match="tei:notatedMusic">
        <span class="notationVerovio"/>
    </xsl:template>

</xsl:stylesheet>
