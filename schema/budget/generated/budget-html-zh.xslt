<?xml version="1.0" encoding="UTF-8"?>
<!--
  Budget -> HTML presentation stylesheet.
  Renders a Production Budget Interchange document (urn:xopxf:budget:1.0)
  as a readable HTML page: production/revision header, a legend of the declared
  vocabularies, and the chapter > account > [item] > detail tree with totals.

  Works for both profiles: synthetic (Detail under Account) and analytic
  (Item > Detail). References (type, phase, role, vat, group, department,
  producer) are resolved to their human-readable names declared in the Header,
  exploiting the document's self-containment.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:b="urn:xopxf:budget:1.0"
                exclude-result-prefixes="b">

  <xsl:output method="html" encoding="UTF-8" indent="yes"
              doctype-system="about:legacy-compat"/>

  <!-- Keys to resolve references against the Header vocabularies -->
  <xsl:key name="kDetailType" match="b:DetailType"     use="@code"/>
  <xsl:key name="kPhase"      match="b:Phase"          use="@code"/>
  <xsl:key name="kRole"       match="b:Role"           use="@code"/>
  <xsl:key name="kDept"       match="b:Department"     use="@code"/>
  <xsl:key name="kProducer"   match="b:Producer"       use="@code"/>
  <xsl:key name="kVat"        match="b:VatRate"        use="@code"/>
  <xsl:key name="kWithhold"   match="b:WithholdingRate" use="@code"/>
  <xsl:key name="kGroup"      match="b:Group"          use="@code"/>

  <!-- ============================================================ -->
  <xsl:template match="/b:Budget">
    <html lang="{@language}">
      <head>
        <meta charset="UTF-8"/>
        <title>
          <xsl:text>预算 </xsl:text>
          <xsl:value-of select="b:Header/b:Production/b:Title"/>
        </title>
        <style>
          body { font-family: -apple-system, Segoe UI, Roboto, sans-serif;
                 color: #222; margin: 24px; font-size: 13px; }
          h1 { font-size: 20px; margin: 0 0 2px; }
          .sub { color: #666; margin-bottom: 16px; }
          .meta { display: flex; flex-wrap: wrap; gap: 24px;
                  background: #f6f8fa; border: 1px solid #e1e4e8;
                  border-radius: 6px; padding: 12px 16px; margin-bottom: 16px; }
          .meta div span { display: block; }
          .meta .lbl { color: #888; font-size: 11px; text-transform: uppercase; }
          .meta .val { font-weight: 600; }
          .badge { display: inline-block; padding: 2px 8px; border-radius: 4px;
                   font-size: 11px; font-weight: 600; }
          .badge.confirmed { background: #d4f7dd; color: #156b2e; }
          .badge.draft { background: #fff3cd; color: #856404; }
          .legend { font-size: 11px; color: #555; margin-bottom: 20px; }
          .legend b { color: #333; }
          table { border-collapse: collapse; width: 100%; }
          th { background: #2c3e50; color: #fff; text-align: left;
               padding: 6px 8px; font-size: 11px; }
          th.num, td.num { text-align: right; }
          td { padding: 5px 8px; border-bottom: 1px solid #eee; }
          tr.chapter td { background: #34495e; color: #fff; font-weight: 700;
                          font-size: 13px; }
          tr.account td { background: #ecf3f9; font-weight: 600; }
          tr.item td { background: #f8fbfd; font-style: italic; color: #16608a;
                       padding-left: 24px; }
          tr.detail td.desc { padding-left: 36px; }
          tr.detail.contingency td { color: #b1610a; }
          .code { font-family: ui-monospace, monospace; font-size: 11px;
                  background: #16a085; color: #fff; padding: 1px 6px;
                  border-radius: 3px; margin-right: 6px; }
          tr.total td { font-weight: 700; border-top: 2px solid #2c3e50;
                        background: #fafafa; }
          .tag { font-size: 10px; background: #e8eef3; color: #555;
                 padding: 1px 5px; border-radius: 3px; margin-left: 4px; }
        </style>
      </head>
      <body>
        <xsl:apply-templates select="b:Header"/>
        <xsl:call-template name="bodyTable"/>
      </body>
    </html>
  </xsl:template>

  <!-- ============================================================ -->
  <!--  HEADER                                                      -->
  <!-- ============================================================ -->
  <xsl:template match="b:Header">
    <h1>
      <xsl:value-of select="b:Production/b:Title"/>
    </h1>
    <div class="sub">
      <xsl:text>制作预算</xsl:text>
      <xsl:if test="b:Production/b:Episodes">
        <xsl:text> &#183; </xsl:text>
        <xsl:value-of select="b:Production/b:Episodes"/>
        <xsl:text> 集</xsl:text>
      </xsl:if>
    </div>

    <div class="meta">
      <div>
        <span class="lbl">Produzione</span>
        <span class="val"><xsl:value-of select="b:Production/b:Code"/></span>
      </div>
      <div>
        <span class="lbl">Revisione</span>
        <span class="val">
          <xsl:value-of select="b:Revision/@number"/>
          <xsl:text> </xsl:text>
          <span class="badge {b:Revision/@status}">
            <xsl:value-of select="b:Revision/@status"/>
          </span>
        </span>
      </div>
      <div>
        <span class="lbl">Emittente</span>
        <span class="val"><xsl:value-of select="b:Transmission/b:Sender/b:Name"/></span>
      </div>
      <xsl:if test="b:Transmission/b:Recipient">
        <div>
          <span class="lbl">Destinatario</span>
          <span class="val"><xsl:value-of select="b:Transmission/b:Recipient/b:Name"/></span>
        </div>
      </xsl:if>
      <div>
        <span class="lbl">Documento</span>
        <span class="val"><xsl:value-of select="b:Transmission/b:DocumentId"/></span>
      </div>
      <div>
        <span class="lbl">Data</span>
        <span class="val"><xsl:value-of select="b:Transmission/b:IssueDate"/></span>
      </div>
      <xsl:if test="b:Production/b:Currency">
        <div>
          <span class="lbl">Valuta</span>
          <span class="val"><xsl:value-of select="b:Production/b:Currency"/></span>
        </div>
      </xsl:if>
    </div>

    <xsl:if test="b:Groups/b:Group">
      <div class="legend">
        <b>分组: </b>
        <xsl:for-each select="b:Groups/b:Group">
          <xsl:value-of select="@code"/>
          <xsl:text> = </xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:if test="@scheme">
            <xsl:text> (</xsl:text><xsl:value-of select="@scheme"/><xsl:text>)</xsl:text>
          </xsl:if>
          <xsl:if test="position() != last()"><xsl:text> &#183; </xsl:text></xsl:if>
        </xsl:for-each>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- ============================================================ -->
  <!--  BODY TABLE                                                  -->
  <!-- ============================================================ -->
  <xsl:template name="bodyTable">
    <table>
      <thead>
        <tr>
          <th>章 / 科目 / 条目 / 明细</th>
          <th>类型</th>
          <th>阶段</th>
          <th class="num">数量</th>
          <th class="num">单价</th>
          <th class="num">净额</th>
          <th class="num">费用</th>
          <th class="num">总额</th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select="b:Body/b:Chapter"/>
        <tr class="total">
          <td colspan="5">预算合计</td>
          <td class="num">
            <xsl:call-template name="fmt">
              <xsl:with-param name="n" select="sum(//b:Detail/@netAmount)"/>
            </xsl:call-template>
          </td>
          <td class="num">
            <xsl:call-template name="fmt">
              <xsl:with-param name="n" select="sum(//b:Detail/@socialCharges)"/>
            </xsl:call-template>
          </td>
          <td class="num">
            <xsl:call-template name="fmt">
              <xsl:with-param name="n" select="sum(//b:Detail/@grossAmount)"/>
            </xsl:call-template>
          </td>
        </tr>
      </tbody>
    </table>
  </xsl:template>

  <!-- Chapter -->
  <xsl:template match="b:Chapter">
    <tr class="chapter">
      <td colspan="5">
        <span class="code"><xsl:value-of select="@code"/></span>
        <xsl:value-of select="@name"/>
        <xsl:for-each select="b:GroupRef">
          <span class="tag">
            <xsl:value-of select="key('kGroup', @group)/@name"/>
          </span>
        </xsl:for-each>
      </td>
      <td class="num">
        <xsl:call-template name="fmt">
          <xsl:with-param name="n" select="sum(.//b:Detail/@netAmount)"/>
        </xsl:call-template>
      </td>
      <td class="num">
        <xsl:call-template name="fmt">
          <xsl:with-param name="n" select="sum(.//b:Detail/@socialCharges)"/>
        </xsl:call-template>
      </td>
      <td class="num">
        <xsl:call-template name="fmt">
          <xsl:with-param name="n" select="sum(.//b:Detail/@grossAmount)"/>
        </xsl:call-template>
      </td>
    </tr>
    <xsl:apply-templates select="b:Account"/>
  </xsl:template>

  <!-- Account -->
  <xsl:template match="b:Account">
    <tr class="account">
      <td colspan="5">
        <span class="code"><xsl:value-of select="@code"/></span>
        <xsl:value-of select="@name"/>
        <xsl:if test="@externalCode">
          <span class="tag"><xsl:value-of select="@externalCode"/></span>
        </xsl:if>
      </td>
      <td class="num">
        <xsl:call-template name="fmt">
          <xsl:with-param name="n" select="sum(.//b:Detail/@netAmount)"/>
        </xsl:call-template>
      </td>
      <td class="num">
        <xsl:call-template name="fmt">
          <xsl:with-param name="n" select="sum(.//b:Detail/@socialCharges)"/>
        </xsl:call-template>
      </td>
      <td class="num">
        <xsl:call-template name="fmt">
          <xsl:with-param name="n" select="sum(.//b:Detail/@grossAmount)"/>
        </xsl:call-template>
      </td>
    </tr>
    <!-- analytic: Item rows; synthetic: Detail rows directly -->
    <xsl:apply-templates select="b:Item"/>
    <xsl:apply-templates select="b:Detail"/>
  </xsl:template>

  <!-- Item (analytic only) -->
  <xsl:template match="b:Item">
    <tr class="item">
      <td colspan="8">
        <xsl:if test="@ref">
          <span class="code"><xsl:value-of select="@ref"/></span>
        </xsl:if>
        <xsl:value-of select="@name"/>
        <xsl:if test="@department">
          <span class="tag"><xsl:value-of select="key('kDept', @department)/@name"/></span>
        </xsl:if>
        <xsl:if test="@producer">
          <span class="tag"><xsl:value-of select="key('kProducer', @producer)/@name"/></span>
        </xsl:if>
      </td>
    </tr>
    <xsl:apply-templates select="b:Detail"/>
  </xsl:template>

  <!-- Detail -->
  <xsl:template match="b:Detail">
    <tr>
      <xsl:attribute name="class">
        <xsl:text>detail</xsl:text>
        <xsl:if test="key('kDetailType', @type)/@contingency = 'true'">
          <xsl:text> contingency</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <td class="desc"><xsl:value-of select="@description"/></td>
      <td><xsl:value-of select="key('kDetailType', @type)/@name"/></td>
      <td>
        <xsl:if test="@phase">
          <xsl:value-of select="key('kPhase', @phase)/@name"/>
        </xsl:if>
      </td>
      <td class="num"><xsl:value-of select="@quantity"/></td>
      <td class="num">
        <xsl:if test="@unitPrice">
          <xsl:call-template name="fmt"><xsl:with-param name="n" select="@unitPrice"/></xsl:call-template>
        </xsl:if>
      </td>
      <td class="num">
        <xsl:call-template name="fmt"><xsl:with-param name="n" select="@netAmount"/></xsl:call-template>
      </td>
      <td class="num">
        <xsl:if test="@socialCharges">
          <xsl:call-template name="fmt"><xsl:with-param name="n" select="@socialCharges"/></xsl:call-template>
        </xsl:if>
      </td>
      <td class="num">
        <xsl:if test="@grossAmount">
          <xsl:call-template name="fmt"><xsl:with-param name="n" select="@grossAmount"/></xsl:call-template>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <!-- Number formatting: thousands sep '.', decimals ',' (Italian) -->
  <xsl:template name="fmt">
    <xsl:param name="n"/>
    <xsl:if test="$n != '' and $n != 0">
      <xsl:value-of select="format-number($n, '#.##0,00', 'eu')"/>
    </xsl:if>
  </xsl:template>

  <xsl:decimal-format name="eu" decimal-separator="," grouping-separator="."/>

</xsl:stylesheet>
