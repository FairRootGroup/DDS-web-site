<?xml version='1.0'?> 
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/website/tabular.xsl"/>

<!-- ****** Parameters ****** -->
  <xsl:param name="paper.type" select="'A4'"/>
  <!--xsl:param name="graphic.default.extension" select="'gif'"/-->
  <xsl:param name="admon.graphics.extension" select="'.png'"/>
  <!--xsl:param name="callout.graphics.extension" select="'.gif'"/-->


<!-- ****** Website stylesheet parameters ****** -->
<xsl:template name="home.navhead">
</xsl:template>

<xsl:template name="home.navhead.upperright">
</xsl:template>

<!-- ****** DocBook stylesheet parameters ****** -->


<!-- Table titles without number labels

The local.l10n.xml parameter is used to alter the generated text. In this case, you are changing the gentext templates for the table element in
the contexts of title and xref-number-and-title, which are the contexts that all the formal objects use. The changes eliminate the use of the word
Table and the %n placeholder that generates the number. You can reword the cross reference text any way you like. Repeat the process for all the
languages you are using.
The last line of the customization makes empty the template that matches on table in mode label.markup. That mode generates the number for an element.
It is used in the table of contents when a table of tables is generated.
-->
<xsl:param name="local.l10n.xml" select="document('')"/>
<l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0">
  <l:l10n language="en">
    <l:context name="title">
      <l:template name="table" text="%t"/>
    </l:context>
    <l:context name="xref-number-and-title">
      <l:template name="table" text="the table titled &#8220;%t&#8221;"/>
    </l:context>
  </l:l10n>
</l:i18n>

<xsl:template match="table" mode="label.markup"/>

<!-- Custom tags -->
<xsl:template match="my_chart">
   <xsl:variable name="chart_name">
      <xsl:value-of select="@name" />
   </xsl:variable>
   <xsl:variable name="chart_style">
      <xsl:value-of select="@style" />
   </xsl:variable>
    <div id="{$chart_name}" style="{$chart_style}"></div>
</xsl:template>

<xsl:template match="my_video">
   <xsl:variable name="video_url">
      <xsl:value-of select="@video_url" />
   </xsl:variable>
<iframe width="640" height="385" src="{$video_url}" frameborder="0" allowfullscreen="true" type="text/html"> </iframe>
</xsl:template>


<!-- ****** Template customizations go here ****** -->
<xsl:template match="webpage">

   <!-- same as in website-2.6.0/xsl except for added Google Analytics calls -->

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="relpath">
    <xsl:call-template name="root-rel-path">
      <xsl:with-param name="webpage" select="."/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="tocentry" select="$autolayout/autolayout//*[$id=@id]"/>
  <xsl:variable name="toc" select="($tocentry/ancestor-or-self::toc
                                   |$autolayout/autolayout/toc[1])[last()]"/>

  <html>
    <xsl:apply-templates select="head" mode="head.mode"/>
    <xsl:apply-templates select="config" mode="head.mode"/>
    <body class="tabular">
      <xsl:call-template name="body.attributes"/>

      <div class="{name(.)}">
        <a name="{$id}"/>

        <xsl:call-template name="allpages.banner"/>

        <table xsl:use-attribute-sets="table.properties" border="0">
          <xsl:if test="$nav.table.summary!=''">
            <xsl:attribute name="summary">
              <xsl:value-of select="normalize-space($nav.table.summary)"/>
            </xsl:attribute>
          </xsl:if>
          <tr>
            <td xsl:use-attribute-sets="table.navigation.cell.properties">
              <img src="{$relpath}{$table.spacer.image}" alt=" " width="1" height="1"/>
            </td>
            <xsl:call-template name="hspacer">
              <xsl:with-param name="vspacer" select="1"/>
            </xsl:call-template>
            <td rowspan="2" xsl:use-attribute-sets="table.body.cell.properties">
              <xsl:if test="$navbodywidth != ''">
                <xsl:attribute name="width">
                  <xsl:value-of select="$navbodywidth"/>
                </xsl:attribute>
              </xsl:if>

              <xsl:if test="$autolayout/autolayout/toc[1]/@id = $id">
                <table border="0" summary="home page extra headers"
                       cellpadding="0" cellspacing="0" width="100%">
                  <tr>
                    <xsl:call-template name="home.navhead.cell"/>
                    <xsl:call-template name="home.navhead.upperright.cell"/>
                  </tr>
                </table>
                <xsl:call-template name="home.navhead.separator"/>
              </xsl:if>

              <xsl:if test="$autolayout/autolayout/toc[1]/@id != $id
                            or $suppress.homepage.title = 0">
                <xsl:apply-templates select="./head/title" mode="title.mode"/>
              </xsl:if>

              <xsl:apply-templates select="child::node()[not(self::webpage)]"/>
              <xsl:call-template name="process.footnotes"/>
              <br/>
            </td>
          </tr>
          <tr>
            <td xsl:use-attribute-sets="table.navigation.cell.properties">
              <xsl:if test="$navtocwidth != ''">
                <xsl:attribute name="width">
                  <xsl:choose>
                    <xsl:when test="/webpage/config[@param='navtocwidth']/@value[. != '']">
                      <xsl:value-of select="/webpage/config[@param='navtocwidth']/@value"/>
                    </xsl:when>
                    <xsl:when test="$autolayout/autolayout/config[@param='navtocwidth']/@value[. != '']">
                      <xsl:value-of select="$autolayout/autolayout/config[@param='navtocwidth']/@value"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$navtocwidth"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
              </xsl:if>
              <xsl:choose>
                <xsl:when test="$toc">
                  <p class="navtoc">
                    <xsl:apply-templates select="$toc">
                      <xsl:with-param name="pageid" select="@id"/>
                    </xsl:apply-templates>
                  </p>
                </xsl:when>
                <xsl:otherwise>&#160;</xsl:otherwise>
              </xsl:choose>
            </td>
            <xsl:call-template name="hspacer"/>
          </tr>
          <xsl:call-template name="webpage.table.footer"/>
        </table>

        <xsl:call-template name="webpage.footer"/>
      </div>

<!-- Google analytics code.
I didn't find any better solution to insert it to every page.
Let see, maybe docbook website will open some templates customizations for that 
-->

<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>

<script type="text/javascript">
try{
var pageTracker = _gat._getTracker("UA-2973985-11");
pageTracker._trackPageview();
} catch(err) {}
</script>

    </body>
  </html>
</xsl:template>


</xsl:stylesheet>  

