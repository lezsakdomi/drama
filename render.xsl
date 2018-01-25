<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html [
	<!ENTITY nbsp "&#xA0;">
	<!ENTITY nl "<br/>">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/drama">
		<html class="hideable">
			<head>
				<script src="https://cdn.polyfill.io/v2/polyfill.min.js?features=Promise,Promise.prototype.finally,URL|gated,setImmediate&amp;flags=gated&amp;rum=1">&nbsp;</script>
				<script src="../jquery-3.2.1.js">&nbsp;</script>
				<script src="render.js">&nbsp;</script>
				<link rel="stylesheet" href="base.css"/>
			</head>
			<body>
				<header>
					<h1>
						<span id="author"><xsl:value-of select="./author"/></span>
						<span id="title"><xsl:value-of select="./title"/></span>
					</h1>
					<details open="open">
						<xsl:for-each select="./translator">
							<tranlator>
								<xsl:if test="@language">
									<xsl:attribute name="language"><xsl:value-of select="@language"/></xsl:attribute>
								</xsl:if>
								<xsl:value-of select="."/>
							</tranlator>
						</xsl:for-each>
						<xsl:if test="./comment">
							<comment><xsl:value-of select="./comment"/></comment>
						</xsl:if>
						<xsl:if test="./motto">
							<summary><xsl:value-of select="./motto"/></summary>
						</xsl:if>
					</details>
				</header>
				<xsl:apply-templates select="./casting"/>
				<xsl:apply-templates select="./acts"/>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="/drama/casting">
		<article class="casting">
			<h2>Szereposztás</h2>
			<table>
				<xsl:for-each select="./cast">
					<tr>
						<td class="cast">
							<xsl:choose>
								<xsl:when test="text() and @description">
									<xsl:value-of select="."/>, <span class="cast-description"><xsl:value-of select="@description"/></span>
								</xsl:when>
								<xsl:when test="text()">
									<xsl:value-of select="."/>
								</xsl:when>
								<xsl:when test="@description">
									<span class="cast-description"><xsl:value-of select="@description"/></span>
								</xsl:when>
								<xsl:otherwise>
									<xsl:message>/drama/casting/cast must have text() and/or @description but nothing other</xsl:message>
									<xsl:apply-templates/>
								</xsl:otherwise>
							</xsl:choose>
						</td>
						<td class="actor"><xsl:value-of select="@actor"/></td>
						<xsl:if test="@comment"><aside class="comment"><xsl:value-of select="@comment"/></aside></xsl:if>
					</tr>
				</xsl:for-each>
			</table>
		</article>
	</xsl:template>

	<xsl:template match="acts">
		<main>
			<xsl:apply-templates select="./act"/>
		</main>
	</xsl:template>
	<xsl:template match="act|scene">
		<!-- altough this is dynamic, the backing scripts and stylesheets are assuming this layout: /drama/acts/act/scene where scene or acts could be missing -->
		<!-- TODO numbering should be done by css -->
		<section>
			<xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
			<xsl:if test="@place or @comment">
				<details open="open">
					<xsl:if test="@place">
						<place><xsl:value-of select="@place"/></place>
					</xsl:if>
					<xsl:if test="@comment">
						<comment><xsl:value-of select="@comment"/></comment>
					</xsl:if>
				</details>
			</xsl:if>
			<xsl:for-each select="./scene | ./act">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
			<xsl:apply-templates select="*[not(name()='scene' or name()='act')]"/>
		</section>
	</xsl:template>

	<xsl:template match="says">
		<p>
			<xsl:attribute name="class">sentence</xsl:attribute>
			<person><xsl:value-of select="@who"/></person>
			<xsl:if test="@how">
				<manner><xsl:value-of select="@how"/></manner>
			</xsl:if>
			<span class="text"><xsl:copy-of select="."/></span>
		</p>
	</xsl:template>

	<xsl:template match="instruction">
		<p>
			<xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
			<xsl:copy-of select="."/>
		</p>
	</xsl:template>

	<xsl:template match="music">
		<aside>
			<xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
			<xsl:copy-of select="text()"/>
			<xsl:if test="@comment"><comment><xsl:value-of select="@comment"/></comment></xsl:if>
		</aside>
	</xsl:template>

	<xsl:template match="sound">
		<aside>
			<xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
			<xsl:copy-of select="text()"/>
			<xsl:if test="@comment"><comment><xsl:value-of select="@comment"/></comment></xsl:if>
		</aside>
	</xsl:template>

	<xsl:template match="move">
		<aside>
			<xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
			<xsl:copy-of select="."/>
			<person><xsl:value-of select="@who"/></person>
			<xsl:if test="@comment"><comment><xsl:value-of select="@comment"/></comment></xsl:if>
		</aside>
	</xsl:template>

	<xsl:template match="lights">
		<aside>
			<xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
			<xsl:if test="@type">
				<light-type><xsl:value-of select="@type"/></light-type>
			</xsl:if>
			<xsl:if test="@to">
				<person><xsl:value-of select="@to"/></person>
			</xsl:if>
			<xsl:value-of select="."/>
			<xsl:if test="@comment"><comment><xsl:value-of select="@comment"/></comment></xsl:if>
		</aside>
	</xsl:template>

	<xsl:template match="comment">
		<aside>
			<xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
			<xsl:value-of select="." disable-output-escaping="no"/>
		</aside>
	</xsl:template>
</xsl:stylesheet>
