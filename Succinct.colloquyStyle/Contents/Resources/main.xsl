<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output omit-xml-declaration="yes" indent="no" />
	<xsl:param name="consecutiveMessage" />
	<xsl:param name="bulkTransform" />
	<xsl:param name="timeFormat" />

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$consecutiveMessage = 'yes'">
				<xsl:apply-templates select="/envelope/message[last()]" mode="consecutive">
					<xsl:with-param name="fromEnvelope" select="'no'" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="message" mode="consecutive">
		<xsl:param name="fromEnvelope" select="'no'" />

		<xsl:choose>
			<xsl:when test="not( $consecutiveMessage = 'yes' ) and $fromEnvelope = 'no' and count( ../message[not( @ignored = 'yes' )] ) = 1 and not( @ignored = 'yes' )">
				<xsl:apply-templates select=".." />
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="not( @ignored = 'yes' ) and not( ../@ignored = 'yes' )">
					<xsl:variable name="messageClasses">
						<xsl:text>message message--consecutive</xsl:text>
						<xsl:if test="@highlight = 'yes'">
							<xsl:text> message--highlight</xsl:text>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="../sender/@self = 'yes'">
								<xsl:text> message--outgoing</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text> message--incoming</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="@action = 'yes'">
							<xsl:text> message--action</xsl:text>
						</xsl:if>
						<xsl:if test="@type = 'notice'">
							<xsl:text> message--notice</xsl:text>
						</xsl:if>
						<xsl:if test="@ignored = 'yes' or ../@ignored = 'yes'">
							<xsl:text> message--ignore</xsl:text>
						</xsl:if>
					</xsl:variable>

					<xsl:variable name="datetime">
						<xsl:call-template name="iso-datetime">
							<xsl:with-param name="date" select="@received" />
						</xsl:call-template>
					</xsl:variable>

					<xsl:variable name="timestamp">
						<xsl:call-template name="short-time">
							<xsl:with-param name="date" select="@received" />
						</xsl:call-template>
					</xsl:variable>

					<xsl:variable name="memberClasses">
						<xsl:text>member</xsl:text>
						<xsl:if test="../sender/@self = 'yes'">
							<xsl:text> member--self</xsl:text>
						</xsl:if>
					</xsl:variable>

					<xsl:variable name="memberLink">
						<xsl:choose>
							<xsl:when test="../sender/@identifier">
								<xsl:text>member:identifier:</xsl:text><xsl:value-of select="../sender/@identifier" />
							</xsl:when>
							<xsl:when test="../sender/@nickname">
								<xsl:text>member:</xsl:text><xsl:value-of select="../sender/@nickname" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>member:</xsl:text><xsl:value-of select="../sender" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:variable name="hostmask" select="../sender/@hostmask" />

				<xsl:variable name="senderNick" select="sender | ../sender"/>
				 <xsl:variable name="senderHostmask" select="sender/@hostmask | ../sender/@hostmask"/>
				 <xsl:variable name="senderHash"
						select="number(
									substring(
										translate(
											$senderHostmask,
											'abcdefghijklmnopqrstuvwxyzABCDEFGHIKJLMNOPQRSTUVWXYZ-_.@~',
											'123456789012345678901234567890123456789012345678901234567'
										),
										2,
										7
									)
								)"
				 />

				 <xsl:variable name="senderColor">
					<xsl:choose>
						<xsl:when test="sender/@self = 'yes'">colorself</xsl:when>
						<xsl:when test="../sender/@self = 'yes'">colorself</xsl:when>
						<xsl:when test="string-length(sender/text()) &gt; 0">
							<xsl:value-of select="concat('color', $senderHash mod 70 )" />
						</xsl:when>
						<xsl:when test="string-length(../sender/text()) &gt; 0">
							<xsl:value-of select="concat('color', $senderHash mod 70)" />
						</xsl:when>
					</xsl:choose>
				 </xsl:variable>

					<article id="{@id}" class="{$messageClasses} table__row">
						<p class="message__sender table__cell">
							<a href="{$memberLink}" title="{$hostmask}" class="{$memberClasses} {$senderColor}"><xsl:value-of select="../sender" /></a><span class="hidden">: </span>
						</p>
						<p class="message__content table__cell">
							<xsl:if test="@action = 'yes'">
								<xsl:text>• </xsl:text>
								<a href="{$memberLink}" title="{$hostmask}" class="action {$memberClasses} {$senderColor}">
									<xsl:value-of select="../sender" />
								</a>
								<xsl:text> </xsl:text>
							</xsl:if>
							<xsl:apply-templates select="child::node()" mode="copy" />
						</p>
						<time class="message__timestamp table__cell" datetime="{$datetime}"> <xsl:value-of select="$timestamp" /></time>
					</article>

					<xsl:if test="not( $bulkTransform = 'yes' )">
						<xsl:if test="$fromEnvelope = 'no'">
							<xsl:processing-instruction name="message">type="consecutive"</xsl:processing-instruction>
						</xsl:if>
					</xsl:if>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="envelope">
		<xsl:if test="not( @ignored = 'yes' ) and count( message[not( @ignored = 'yes' )] ) &gt;= 1">
			<xsl:variable name="messageClasses">
				<xsl:text>message</xsl:text>
				<xsl:if test="message[not( @ignored = 'yes' )][1]/@highlight = 'yes'">
					<xsl:text> message--highlight</xsl:text>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="sender/@self = 'yes'">
						<xsl:text> message--outgoing</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> message--incoming</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="message[not( @ignored = 'yes' )][1]/@action = 'yes'">
					<xsl:text> message--action</xsl:text>
				</xsl:if>
				<xsl:if test="message[not( @ignored = 'yes' )][1]/@type = 'notice'">
					<xsl:text> message--notice</xsl:text>
				</xsl:if>
				<xsl:if test="message[not( @ignored = 'yes' )][1]/@ignored = 'yes' or @ignored = 'yes'">
					<xsl:text> message--ignore</xsl:text>
				</xsl:if>
			</xsl:variable>

			<xsl:variable name="datetime">
				<xsl:call-template name="iso-datetime">
					<xsl:with-param name="date" select="message[not( @ignored = 'yes' )][1]/@received" />
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="timestamp">
				<xsl:call-template name="short-time">
					<xsl:with-param name="date" select="message[not( @ignored = 'yes' )][1]/@received" />
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="memberClasses">
				<xsl:text>member</xsl:text>
				<xsl:if test="sender/@self = 'yes'">
					<xsl:text> member--self</xsl:text>
				</xsl:if>
			</xsl:variable>

			<xsl:variable name="memberLink">
				<xsl:choose>
					<xsl:when test="sender/@identifier">
						<xsl:text>member:identifier:</xsl:text><xsl:value-of select="sender/@identifier" />
					</xsl:when>
					<xsl:when test="sender/@nickname">
						<xsl:text>member:</xsl:text><xsl:value-of select="sender/@nickname" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>member:</xsl:text><xsl:value-of select="sender" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="hostmask" select="sender/@hostmask" />

			<xsl:variable name="senderNick" select="sender | ../sender"/>
				 <xsl:variable name="senderHostmask" select="sender/@hostmask | ../sender/@hostmask"/>
				 <xsl:variable name="senderHash"
						select="number(
									substring(
										translate(
											$senderHostmask,
											'abcdefghijklmnopqrstuvwxyzABCDEFGHIKJLMNOPQRSTUVWXYZ-_.@~',
											'123456789012345678901234567890123456789012345678901234567'
										),
										2,
										7
									)
								)"
				 />

				 <xsl:variable name="senderColor">
					<xsl:choose>
						<xsl:when test="sender/@self = 'yes'">colorself</xsl:when>
						<xsl:when test="../sender/@self = 'yes'">colorself</xsl:when>
						<xsl:when test="string-length(sender/text()) &gt; 0">
							<xsl:value-of select="concat('color', $senderHash mod 70 )" />
						</xsl:when>
						<xsl:when test="string-length(../sender/text()) &gt; 0">
							<xsl:value-of select="concat('color', $senderHash mod 70)" />
						</xsl:when>
					</xsl:choose>
				 </xsl:variable>

			<article id="{message[not( @ignored = 'yes' )][1]/@id}" class="{$messageClasses} table__row">
				<p class="message__sender table__cell">
					<a href="{$memberLink}" title="{$hostmask}" class="{$memberClasses} {$senderColor}"><xsl:value-of select="sender" /></a><span class="hidden">: </span>
				</p>
				<p class="message__content table__cell">
					<xsl:if test="message[not( @ignored = 'yes' )][1]/@action = 'yes'">
						<xsl:text>• </xsl:text>
						<a href="{$memberLink}" title="{$hostmask}" class="action {$memberClasses} {$senderColor}">
							<xsl:value-of select="sender" />
						</a>
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:apply-templates select="message[not( @ignored = 'yes' )][1]/child::node()" mode="copy" />
				</p>
				<time class="message__timestamp table__cell" datetime="{$datetime}"> <xsl:value-of select="$timestamp" /></time>
			</article>

			<xsl:apply-templates select="message[not( @ignored = 'yes' )][position() &gt; 1]" mode="consecutive">
				<xsl:with-param name="fromEnvelope" select="'yes'" />
			</xsl:apply-templates>

		</xsl:if>
	</xsl:template>

	<xsl:template match="event">
		<xsl:variable name="datetime">
			<xsl:call-template name="iso-datetime">
				<xsl:with-param name="date" select="@occurred" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="timestamp">
			<xsl:call-template name="short-time">
				<xsl:with-param name="date" select="@occurred" />
			</xsl:call-template>
		</xsl:variable>

		<div class="event table__row">
			<p class="event__sender table__cell"></p>
			<p class="event__content table__cell">
				<xsl:apply-templates select="message/child::node()" mode="event" />
				<xsl:if test="string-length( reason )">
					<span class="event__reason reason">
						<xsl:text> (</xsl:text>
						<xsl:apply-templates select="reason/child::node()" mode="copy" />
						<xsl:text>)</xsl:text>
					</span>
				</xsl:if>
			</p>
			<time class="event__timestamp table__cell" datetime="{$datetime}"> <xsl:value-of select="$timestamp" /></time>
		</div>
	</xsl:template>

	<xsl:template match="a" mode="copy">
		<xsl:variable name="extension" select="substring(@href,string-length(@href) - 3, 4)" />
		<xsl:variable name="extensionLong" select="substring(@href,string-length(@href) - 4, 5)" />
		<xsl:choose>
			<xsl:when test="$extension = '.jpg' or $extension = '.JPG' or $extensionLong = '.jpeg' or $extensionLong = '.JPEG'
											or $extension = '.gif' or $extension = '.GIF'
											or $extension = '.png' or $extension = '.PNG'
											or $extension = '.tif' or $extension = '.TIF' or $extensionLong = '.tiff' or $extensionLong = '.TIFF'
											or $extension = '.bmp' or $extension = '.BMP'
			">
				<a href="{@href}" title="{@href}" class="image"><img src="{@href}" alt="Loading Image…" onload="scrollToBottom()" onerror="scrollToBottom()" class="image__img" /><span class="image__url"><xsl:value-of select="@href" /></span></a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="current()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="span[contains(@class,'member')]" mode="event">
		<xsl:variable name="nickname" select="current()" />
		<xsl:choose>
			<xsl:when test="../../node()[node() = $nickname]/@hostmask">
				<xsl:variable name="hostmask" select="../../node()[node() = $nickname]/@hostmask" />
				<a href="member:{$nickname}" title="{$hostmask}" class="member"><xsl:copy-of select="@*" /><xsl:value-of select="$nickname" /></a>
				<xsl:if test="../../@name = 'memberJoined' or ../../@name = 'memberParted'">
					<span class="hostmask">
						<xsl:text> (</xsl:text>
						<xsl:value-of select="$hostmask" />
						<xsl:text>) </xsl:text>
					</span>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<a href="member:{$nickname}" class="member"><xsl:copy-of select="@*" /><xsl:apply-templates select="current()/child::node()" mode="copy" /></a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="span[contains(@class,'member')]" mode="copy">
		<a href="member:{current()}" class="member"><xsl:copy-of select="@*" /><xsl:apply-templates select="current()/child::node()" mode="copy" /></a>
	</xsl:template>

	<xsl:template match="@*|*" mode="event">
		<xsl:copy><xsl:apply-templates select="@*|node()" mode="event" /></xsl:copy>
	</xsl:template>

	<xsl:template match="@*|*" mode="copy">
		<xsl:copy><xsl:apply-templates select="@*|node()" mode="copy" /></xsl:copy>
	</xsl:template>

	<xsl:template name="short-time">
		<xsl:param name="date" /> <!-- YYYY-MM-DD HH:MM:SS +/-HHMM -->
		<xsl:variable name='hour' select='substring($date, 12, 2)' />
		<xsl:variable name='minute' select='substring($date, 15, 2)' />
		<xsl:choose>
			<xsl:when test="not(contains($timeFormat,'AM')) and not(contains($timeFormat,'PM'))">
				<!-- 24hr format -->
				<xsl:value-of select="concat($hour,':',$minute)" />
			</xsl:when>
			<xsl:otherwise>
				<!-- am/pm format -->
				<xsl:choose>
					<xsl:when test="number($hour) &gt; 12">
						<xsl:value-of select="number($hour) - 12" />
					</xsl:when>
					<xsl:when test="number($hour) = 0">
						<xsl:text>12</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="number($hour)" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="$minute" />
				<xsl:choose>
					<xsl:when test="number($hour) &gt;= 12">
						<xsl:text>p</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>a</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="iso-datetime">
		<xsl:param name="date" /> <!-- YYYY-MM-DD HH:MM:SS +/-HHMM -->
		<xsl:variable name='day' select='substring($date, 1, 10)' />
		<xsl:variable name='time' select='substring($date, 12, 8)' />
		<xsl:variable name='offset' select='substring($date, 21, 5)' />
		<!-- ISO 8601 format -->
		<xsl:value-of select="$day" /><xsl:text>T</xsl:text><xsl:value-of select="$time" /><xsl:value-of select="$offset" />
	</xsl:template>
</xsl:transform>
